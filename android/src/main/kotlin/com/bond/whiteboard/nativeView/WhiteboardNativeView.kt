package com.bond.whiteboard.nativeView

import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import io.flutter.plugin.platform.PlatformView
import android.content.Context.INPUT_METHOD_SERVICE
import android.view.inputmethod.InputMethodManager


class WhiteboardNativeView(val context: Context?, val viewId: Int,val args:Any?) : PlatformView {
    var rootView = FrameLayout(context!!)

    init {
        rootView.id = viewId
        this.rootView.setPadding(0, 0, 0, 0)
        val map = args as Map<String, Any>
        val width = map["width"].toString().toDouble().toInt()
        val height = map["height"].toString().toDouble().toInt()
        rootView.minimumHeight = height
        rootView.minimumWidth = width
        rootView.setBackgroundColor(Color.TRANSPARENT)
        rootView.isFocusable = true
        rootView.isFocusableInTouchMode = true
        rootView.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
    }

    override fun getView(): View {
        return rootView
    }

    fun update(viewId: Int, args: Any?) {
        (rootView.parent as? ViewGroup)?.removeView(rootView)
        rootView.id = viewId
        this.rootView.setPadding(0, 0, 0, 0)
        val map = args as Map<String, Any>
        val width = map["width"].toString().toDouble().toInt()
        val height = map["height"].toString().toDouble().toInt()
        rootView.minimumHeight = height
        rootView.minimumWidth = width
        rootView.isFocusable = true
        rootView.isFocusableInTouchMode = true
//        rootView.layoutParams = ViewGroup.LayoutParams(width, height)
        rootView.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        rootView.requestLayout()
        rootView.postInvalidate()

    }

    override fun dispose() {
//        Log.e("你他吗的","childCount:${rootView.childCount}")
//        rootView.removeAllViews()
//        rootView.clearAnimation()
    }
}