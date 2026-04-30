package com.smartthings.shaderhome.accessibility

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View
import android.view.accessibility.AccessibilityNodeProvider
import androidx.core.view.ViewCompat

/**
 * Transparent, touch-pass-through view that sits on top of the Godot fragment
 * and exposes Godot's accessibility tree to TalkBack via [HomeExploreByTouchHelper].
 *
 * Touch passthrough is handled by [onTouchEvent] returning false and
 * [dispatchTouchEvent] returning false: every MotionEvent falls through to the
 * Godot GLSurfaceView underneath, preserving pan / pinch / twist / tap. The
 * accessibility framework reaches us via a separate path
 * ([View.getAccessibilityNodeProvider]), so it's not affected by touch
 * passthrough.
 *
 * The overlay starts empty. [updateTree] is called from [com.smartthings.shaderhome.MainActivity]
 * each time Godot publishes a new tree (debounced ~50 ms in GDScript).
 */
class AccessibilityOverlayView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : View(context, attrs, defStyleAttr) {

    /**
     * Forwards focus / activate events back to the host (typically the
     * MainActivity, which then calls into the GodotPlugin).
     */
    interface Listener {
        fun onAccessibilityFocusChanged(nodeId: String)
        fun onAccessibilityActivate(nodeId: String)
    }

    private var hostListener: Listener? = null

    private val helper = HomeExploreByTouchHelper(
        this,
        object : HomeExploreByTouchHelper.Listener {
            override fun onFocusChanged(nodeId: String) {
                hostListener?.onAccessibilityFocusChanged(nodeId)
            }

            override fun onActivate(nodeId: String) {
                hostListener?.onAccessibilityActivate(nodeId)
            }
        },
    )

    init {
        // Make the overlay focusable for accessibility but not for touch.
        isClickable = false
        isFocusable = false
        isFocusableInTouchMode = false
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        // Keep the view fully transparent.
        setBackgroundColor(0x00000000)

        // ExploreByTouchHelper installs itself as the View's
        // AccessibilityDelegate; it forwards getAccessibilityNodeProvider to
        // expose virtual children to the platform.
        ViewCompat.setAccessibilityDelegate(this, helper)
    }

    fun setListener(listener: Listener?) {
        hostListener = listener
    }

    fun updateTree(tree: AccessibilityTree) {
        helper.updateTree(tree)
    }

    /**
     * Convenience wrapper for transient, polite announcements (e.g. "Light
     * turned on"). Uses the standard View API so TalkBack queues the
     * announcement without disturbing accessibility focus.
     */
    fun announce(text: String) {
        if (text.isEmpty()) return
        announceForAccessibility(text)
    }

    // --- Touch pass-through ------------------------------------------------
    //
    // The overlay must NEVER consume MotionEvents — Godot owns all touch
    // gestures (pan, pinch, twist). Returning false from both dispatchTouchEvent
    // and onTouchEvent makes Android route the event to the next View in the
    // FrameLayout's z-order, which is the GodotFragment's GLSurfaceView.

    override fun dispatchTouchEvent(event: MotionEvent?): Boolean = false

    override fun onTouchEvent(event: MotionEvent?): Boolean = false

    // --- Accessibility provider -------------------------------------------
    //
    // ExploreByTouchHelper's accessibility delegate handles getAccessibilityNodeProvider
    // for us via the ViewCompat.setAccessibilityDelegate call above. We still
    // forward hover events (touch-explore) explicitly because
    // dispatchTouchEvent / onTouchEvent both short-circuit.

    override fun dispatchHoverEvent(event: MotionEvent): Boolean {
        // Touch exploration uses ACTION_HOVER_* events; route them into the
        // helper so TalkBack can locate virtual views under the finger.
        if (helper.dispatchHoverEvent(event)) return true
        return super.dispatchHoverEvent(event)
    }
}
