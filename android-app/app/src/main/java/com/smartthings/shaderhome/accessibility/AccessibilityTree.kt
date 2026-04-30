package com.smartthings.shaderhome.accessibility

import android.graphics.Rect
import org.json.JSONArray
import org.json.JSONObject

/**
 * Backend-agnostic accessibility tree pushed by Godot through the plugin bridge.
 *
 * The Godot side ([scripts/accessibility_tree_builder.gd]) projects the current
 * floorplan + device pins into screen-space rects and serialises them as JSON.
 * The Kotlin side parses that JSON into [A11yNode]s organised in DFS traversal
 * order so TalkBack walks them as: app → floor → room → devices in room.
 *
 * The data classes intentionally describe *what* should be exposed, not *how* —
 * [HomeExploreByTouchHelper] is the current rendering backend, but the same
 * snapshot could be replayed into the AccessKit Android adapter without
 * changing this file.
 */

/** Roles map directly to AccessibilityNodeInfo "class names" / role descriptions. */
enum class A11yRole(val className: String, val roleDescription: String?) {
    APP("android.view.ViewGroup", null),
    FLOOR("android.view.ViewGroup", "Floor"),
    ROOM("android.view.ViewGroup", "Room"),
    DEVICE("android.widget.Button", null),
    ;

    companion object {
        fun fromString(s: String?): A11yRole = when (s) {
            "app" -> APP
            "floor" -> FLOOR
            "room" -> ROOM
            "device" -> DEVICE
            else -> APP
        }
    }
}

data class A11yNode(
    val id: String,
    val parentId: String?,
    val label: String,
    val role: A11yRole,
    /** Bounds in pixel space relative to the overlay view. */
    val boundsPx: Rect,
    val activatable: Boolean,
)

data class AccessibilityTree(
    val rootId: String,
    val nodes: Map<String, A11yNode>,
    /**
     * Depth-first ordering of node IDs. TalkBack swipe-right walks this list
     * forward; swipe-left walks it backward. Crucially, container nodes (app,
     * floor, room) appear in this list *before* their children — TalkBack
     * needs the container itself to be focusable so it can speak its label
     * before descending.
     */
    val dfsOrder: List<String>,
) {
    fun findIdAt(x: Int, y: Int): String? {
        // Walk in reverse DFS so deepest (devices) win over containers (rooms).
        for (i in dfsOrder.indices.reversed()) {
            val node = nodes[dfsOrder[i]] ?: continue
            if (node.boundsPx.contains(x, y)) return node.id
        }
        return null
    }

    companion object {
        val EMPTY = AccessibilityTree("", emptyMap(), emptyList())

        /**
         * Parses the JSON published by `accessibility_tree_builder.gd`. Schema:
         *
         * ```json
         * {
         *   "root_id": "app",
         *   "nodes": [
         *     { "id": "app", "parent_id": null, "label": "Smart Home",
         *       "role": "app", "bounds": [l, t, r, b], "activatable": false },
         *     ...
         *   ],
         *   "dfs_order": ["app", "floor:1F", "room:<uuid>", "device:<uuid>", ...]
         * }
         * ```
         *
         * Bounds are integer pixels in overlay-view space. Returns
         * [AccessibilityTree.EMPTY] on any parse failure rather than throwing —
         * an empty tree means TalkBack falls back to the default view, which
         * is the safe degraded behaviour.
         */
        fun fromJson(json: String): AccessibilityTree {
            return try {
                val root = JSONObject(json)
                val rootId = root.optString("root_id", "")
                val nodesArray = root.optJSONArray("nodes") ?: JSONArray()
                val map = LinkedHashMap<String, A11yNode>(nodesArray.length())
                for (i in 0 until nodesArray.length()) {
                    val obj = nodesArray.optJSONObject(i) ?: continue
                    val id = obj.optString("id", "")
                    if (id.isEmpty()) continue
                    val bounds = obj.optJSONArray("bounds")
                    val rect = if (bounds != null && bounds.length() >= 4) {
                        Rect(
                            bounds.optInt(0),
                            bounds.optInt(1),
                            bounds.optInt(2),
                            bounds.optInt(3),
                        )
                    } else {
                        Rect()
                    }
                    map[id] = A11yNode(
                        id = id,
                        parentId = obj.optString("parent_id", "").takeIf { it.isNotEmpty() },
                        label = obj.optString("label", id),
                        role = A11yRole.fromString(obj.optString("role", "app")),
                        boundsPx = rect,
                        activatable = obj.optBoolean("activatable", false),
                    )
                }
                val orderArray = root.optJSONArray("dfs_order") ?: JSONArray()
                val order = ArrayList<String>(orderArray.length())
                for (i in 0 until orderArray.length()) {
                    val id = orderArray.optString(i, "")
                    if (id.isNotEmpty() && map.containsKey(id)) order.add(id)
                }
                AccessibilityTree(rootId, map, order)
            } catch (t: Throwable) {
                EMPTY
            }
        }
    }
}
