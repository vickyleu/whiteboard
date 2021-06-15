package com.bond.whiteboard.nativeView

import android.content.Context
import android.view.View
import android.view.ViewGroup
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class WhiteboardViewFactory :
    PlatformViewFactory(io.flutter.plugin.common.StandardMessageCodec.INSTANCE), NativeViewLink {
    private var nativeViewContainer: WhiteboardNativeView? = null

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        if (nativeViewContainer == null) {
            nativeViewContainer = WhiteboardNativeView(context, viewId, args)
        } else {
            nativeViewContainer?.update(viewId, args)
        }
        return nativeViewContainer!!
    }

    override fun addView(view: View, layoutParams: ViewGroup.LayoutParams) {
        nativeViewContainer?.rootView?.addView(view, layoutParams)
    }

    override fun removeView(view: View) {
        nativeViewContainer?.rootView?.removeView(view)
    }

    override fun getApplicationContext(): Context? {
        return nativeViewContainer?.context
    }

    override fun postViewInitialization(): View.OnFocusChangeListener? {
        nativeViewContainer?.alloc()
        return nativeViewContainer?.rootView?.focusChangeListener
    }

    override fun deallocInputConnection() {
        nativeViewContainer?.dealloc()
    }


}
