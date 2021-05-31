package com.bond.whiteboard.nativeView

import android.content.Context
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class WhiteboardViewFactory: PlatformViewFactory(io.flutter.plugin.common.StandardMessageCodec.INSTANCE), NativeViewLink {

    private var nativeViewContainer: WhiteboardNativeView?=null

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        nativeViewContainer= WhiteboardNativeView(context, viewId,args)
        return nativeViewContainer!!
    }

    override fun addView(view: View, layoutParams: ViewGroup.LayoutParams) {
        nativeViewContainer?.rootView?.addView(view,layoutParams)
    }

    override fun removeView(view: View) {
        nativeViewContainer?.rootView?.removeView(view)
    }

    override fun getApplicationContext(): Context? {
        return  nativeViewContainer?.context
    }
}