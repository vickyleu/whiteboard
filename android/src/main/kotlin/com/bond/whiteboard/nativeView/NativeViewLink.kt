package com.bond.whiteboard.nativeView

import android.content.Context
import android.view.View
import android.view.ViewGroup
import com.tencent.smtt.sdk.WebView

interface NativeViewLink {
    fun addView(view: View, layoutParams: ViewGroup.LayoutParams)
    fun removeView(view: View)
    fun getApplicationContext():Context?
    fun postViewInitialization(): View.OnFocusChangeListener?
    fun deallocInputConnection()
}