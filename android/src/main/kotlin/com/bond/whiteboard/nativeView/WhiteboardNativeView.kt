package com.bond.whiteboard.nativeView

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import io.flutter.plugin.platform.PlatformView

class WhiteboardNativeView(val context: Context?, val viewId: Int) : PlatformView {
    var rootView = FrameLayout(context!!)
    init {
        rootView.id=viewId
        this.rootView.setPadding(0,0,0,0)
        rootView.setBackgroundColor(Color.TRANSPARENT)
    }
    override fun getView(): View {
        return  rootView
    }
    override fun dispose() {
        rootView.removeAllViews()
        rootView.clearAnimation()
    }
}