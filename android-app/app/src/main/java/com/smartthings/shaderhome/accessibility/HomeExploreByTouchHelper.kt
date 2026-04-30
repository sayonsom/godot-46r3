package com.smartthings.shaderhome.accessibility

import android.graphics.Rect
import android.view.View
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat
import androidx.customview.widget.ExploreByTouchHelper

/**
 * Bridges Godot's published accessibility tree to TalkBack via virtual views.
 *
 * Each [A11yNode] becomes a virtual child whose `virtualViewId` is the node's
 * index in the tree's DFS order + 1 (ID 0 is reserved by ExploreByTouchHelper
 * for the host). That index is what TalkBack uses to pick the "next" /
 * "previous" focusable when the user swipes right / left, so the traversal
 * order is exactly: app → floor → room1 → devices in room1 → room2 →
 * devices in room2 → … (see [AccessibilityTree.dfsOrder]).
 *
 * Activation (TalkBack double-tap → ACTION_CLICK) is forwarded back to Godot
 * via [Listener.onActivate]; accessibility focus changes are forwarded via
 * [Listener.onFocusChanged] so Godot can mirror them with its existing focus
 * shader / spotlight.
 */
class HomeExploreByTouchHelper(
    private val hostView: View,
    private val listener: Listener,
) : ExploreByTouchHelper(hostView) {

    interface Listener {
        fun onFocusChanged(nodeId: String)
        fun onActivate(nodeId: String)
    }

    private var tree: AccessibilityTree = AccessibilityTree.EMPTY
    /** virtual view id (1-based DFS index) → node id. */
    private var idByVirtualView: Array<String> = emptyArray()
    /** node id → virtual view id (1-based DFS index). */
    private var virtualViewByNodeId: Map<String, Int> = emptyMap()

    fun updateTree(newTree: AccessibilityTree) {
        tree = newTree
        idByVirtualView = newTree.dfsOrder.toTypedArray()
        virtualViewByNodeId = newTree.dfsOrder
            .mapIndexed { idx, id -> id to (idx + 1) }
            .toMap()
        // Tree shape (or any node) changed → ask ExploreByTouchHelper to
        // rebuild its cached AccessibilityNodeInfo for every virtual child.
        invalidateRoot()
    }

    private fun nodeForVirtualId(virtualViewId: Int): A11yNode? {
        val idx = virtualViewId - 1
        if (idx < 0 || idx >= idByVirtualView.size) return null
        return tree.nodes[idByVirtualView[idx]]
    }

    // ------------------------------------------------------------------
    // ExploreByTouchHelper overrides
    // ------------------------------------------------------------------

    override fun getVirtualViewAt(x: Float, y: Float): Int {
        val nodeId = tree.findIdAt(x.toInt(), y.toInt()) ?: return ExploreByTouchHelper.INVALID_ID
        return virtualViewByNodeId[nodeId] ?: ExploreByTouchHelper.INVALID_ID
    }

    override fun getVisibleVirtualViews(virtualViewIds: MutableList<Int>) {
        // ExploreByTouchHelper feeds this list to TalkBack as the focusable
        // sibling order. Pushing DFS order here is what makes swipe-right
        // walk app → floor → room → devices in tree order, and swipe-left
        // walk it in reverse.
        for (i in idByVirtualView.indices) {
            virtualViewIds.add(i + 1)
        }
    }

    override fun onPopulateNodeForVirtualView(
        virtualViewId: Int,
        node: AccessibilityNodeInfoCompat,
    ) {
        val a = nodeForVirtualId(virtualViewId)
        if (a == null) {
            // ExploreByTouchHelper requires non-empty bounds and a content
            // description even for transient unknown ids.
            node.contentDescription = ""
            node.setBoundsInParent(Rect(0, 0, 1, 1))
            return
        }

        node.contentDescription = a.label
        node.className = a.role.className
        a.role.roleDescription?.let { node.roleDescription = it }
        // IMPORTANT: bounds are screen-pixel rects (Godot's
        // Camera3D.unproject_position output). We deliberately leave the
        // virtual parent at HOST_ID — when virtual parents are set,
        // ExploreByTouchHelper's screen-bounds resolver SUMS bounds up the
        // virtual chain (room → floor → app → host), which makes screen-coord
        // bounds wildly offscreen and the framework clamps them to [0,0,0,0].
        // Keeping a flat hierarchy under the host means every bounds-in-parent
        // IS the bounds-in-screen, which is what TalkBack actually wants.
        node.setBoundsInParent(if (a.boundsPx.isEmpty) Rect(0, 0, 1, 1) else a.boundsPx)
        node.isVisibleToUser = true
        node.isEnabled = true
        node.isFocusable = true

        // Activatable nodes (devices, and rooms in top-level mode) get
        // ACTION_CLICK so TalkBack appends "Double tap to activate" to the
        // spoken label automatically.
        if (a.activatable) {
            node.addAction(AccessibilityNodeInfoCompat.AccessibilityActionCompat.ACTION_CLICK)
            node.isClickable = true
        }
    }

    override fun onPerformActionForVirtualView(
        virtualViewId: Int,
        action: Int,
        arguments: android.os.Bundle?,
    ): Boolean {
        val a = nodeForVirtualId(virtualViewId) ?: return false
        return when (action) {
            AccessibilityNodeInfoCompat.ACTION_CLICK -> {
                if (a.activatable) {
                    listener.onActivate(a.id)
                    true
                } else false
            }
            // ExploreByTouchHelper routes accessibility-focus moves through
            // here too. We piggy-back to forward focus to Godot, then return
            // false so the helper still performs its own focus bookkeeping.
            AccessibilityNodeInfoCompat.ACTION_ACCESSIBILITY_FOCUS -> {
                listener.onFocusChanged(a.id)
                false
            }
            else -> false
        }
    }

    override fun onVirtualViewKeyboardFocusChanged(virtualViewId: Int, hasFocus: Boolean) {
        if (hasFocus) {
            nodeForVirtualId(virtualViewId)?.let { listener.onFocusChanged(it.id) }
        }
    }
}
