package com.bond.whiteboard.nativeView

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.hardware.display.DisplayManager
import android.util.Log
import android.view.View
import android.view.ViewGroup
import io.flutter.plugin.platform.PlatformView


@SuppressLint("InlinedApi")
class WhiteboardNativeView(val context: Context, val viewId: Int, val args: Any?) : PlatformView {
    var rootView = KeyboardWebViewProxy(context)
    private val displayListenerProxy = DisplayListenerProxy()
    private val displayManager: DisplayManager = context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
    init {
        displayListenerProxy.onPreWebViewInitialization(displayManager)
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
        Log.e("updateupdate","update")
        try {
            (rootView.parent as? ViewGroup)?.removeView(rootView)
        }catch (e:Exception){}
        rootView.id = viewId
        this.rootView.setPadding(0, 0, 0, 0)
        val map = args as Map<String, Any>
        val width = map["width"].toString().toDouble().toInt()
        val height = map["height"].toString().toDouble().toInt()
        rootView.minimumHeight = height
        rootView.minimumWidth = width
        rootView.isFocusable = true
        rootView.isFocusableInTouchMode = true
        rootView.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        rootView.post {
            rootView.requestLayout()
            alloc()
        }
    }

    override fun dispose() {
//        Log.e("你他吗的","childCount:${rootView.childCount}")
//        rootView.removeAllViews()
//        rootView.clearAnimation()
    }

    fun alloc() {
        displayListenerProxy.onPostWebViewInitialization(displayManager)
    }

    fun dealloc() {
        rootView.clearFocus()
        rootView.removeAllViews()
    }


    // @Override
    // This is overriding a method that hasn't rolled into stable Flutter yet. Including the
    // annotation would cause compile time failures in versions of Flutter too old to include the new
    // method. However leaving it raw like this means that the method will be ignored in old versions
    // of Flutter but used as an override anyway wherever it's actually defined.
    // TODO(mklim): Add the @Override annotation once flutter/engine#9727 rolls to stable.
    override fun onInputConnectionUnlocked() {
        rootView.unlockInputConnection()
    }

    // @Override
    // This is overriding a method that hasn't rolled into stable Flutter yet. Including the
    // annotation would cause compile time failures in versions of Flutter too old to include the new
    // method. However leaving it raw like this means that the method will be ignored in old versions
    // of Flutter but used as an override anyway wherever it's actually defined.
    // TODO(mklim): Add the @Override annotation once flutter/engine#9727 rolls to stable.
    override fun onInputConnectionLocked() {
        rootView.lockInputConnection()
    }

    // @Override
    // This is overriding a method that hasn't rolled into stable Flutter yet. Including the
    // annotation would cause compile time failures in versions of Flutter too old to include the new
    // method. However leaving it raw like this means that the method will be ignored in old versions
    // of Flutter but used as an override anyway wherever it's actually defined.
    // TODO(mklim): Add the @Override annotation once stable passes v1.10.9.
    override fun onFlutterViewAttached(flutterView: View) {
        rootView.setContainerView(flutterView)
    }

    // @Override
    // This is overriding a method that hasn't rolled into stable Flutter yet. Including the
    // annotation would cause compile time failures in versions of Flutter too old to include the new
    // method. However leaving it raw like this means that the method will be ignored in old versions
    // of Flutter but used as an override anyway wherever it's actually defined.
    // TODO(mklim): Add the @Override annotation once stable passes v1.10.9.
    override fun onFlutterViewDetached() {
        rootView.setContainerView(null)
    }

}