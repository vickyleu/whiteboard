package com.bond.whiteboard.nativeView

import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import io.flutter.plugin.platform.PlatformView

class WhiteboardNativeView(val context: Context?, val viewId: Int,val args:Any?) : PlatformView {
    var rootView = FrameLayout(context!!)
    init {
        rootView.id=viewId
        this.rootView.setPadding(0,0,0,0)
        val map = args as Map<String,Any>
        val width=map["width"].toString().toDouble().toInt()
        val height=map["height"].toString().toDouble().toInt()
        rootView.minimumHeight=height
        rootView.minimumWidth=width
        rootView.setBackgroundColor(Color.TRANSPARENT)
        rootView.isFocusable=true
        rootView.isFocusableInTouchMode=true

    }
    override fun getView(): View {
        Log.e("你他吗的","childCount:${rootView.childCount}")
        return  rootView
    }
    override fun dispose() {
        Log.e("你他吗的","childCount:${rootView.childCount}")
        rootView.removeAllViews()
        rootView.clearAnimation()
    }
}