// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package com.bond.whiteboard.nativeView

import android.graphics.Rect
import android.os.Handler
import android.os.IBinder
import android.util.Log
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection

/**
 * A fake View only exposed to InputMethodManager.
 *
 *
 * This follows a similar flow to Chromium's WebView (see
 * https://cs.chromium.org/chromium/src/content/public/android/java/src/org/chromium/content/browser/input/ThreadedInputConnectionProxyView.java).
 * WebView itself bounces its InputConnection around several different threads. We follow its logic
 * here to get the same working connection.
 *
 *
 * This exists solely to forward input creation to WebView's ThreadedInputConnectionProxyView on
 * the IME thread. The way that this is created in [ ][InputAwareWebView.checkInputConnectionProxy] guarantees that we have a handle to
 * ThreadedInputConnectionProxyView and [.onCreateInputConnection] is always called on the IME
 * thread. We delegate to ThreadedInputConnectionProxyView there to get WebView's input connection.
 */
internal class ThreadedInputConnectionProxyAdapterView(
    val containerView: View,
    var targetView: View?,
    var imeHandler: Handler?
) : View(
    containerView.context
) {
    var _windowToken: IBinder?=null
    var focused=true
    val _rootView: View
    /** Returns whether or not this is currently asynchronously acquiring an input connection.  */
    var isTriggerDelayed = true
        private set
    private var isLocked = false
    private var cachedConnection: InputConnection? = null

    /** Sets whether or not this should use its previously cached input connection.  */
    fun setLocked(locked: Boolean) {
        isLocked = locked
    }

    /**
     * This is expected to be called on the IME thread. See the setup required for this in [ ][InputAwareWebView.checkInputConnectionProxy].
     *
     *
     * Delegates to ThreadedInputConnectionProxyView to get WebView's input connection.
     */
    override fun onCreateInputConnection(outAttrs: EditorInfo): InputConnection? {
        if(focused){
            Log.e("onCreateInputConnection","$targetView  $isLocked")
            isTriggerDelayed = false
            val inputConnection = if (isLocked) cachedConnection else targetView?.onCreateInputConnection(outAttrs)
            isTriggerDelayed = true
            cachedConnection = inputConnection
            return inputConnection
        }else return null
    }

    override fun checkInputConnectionProxy(view: View): Boolean {
        return focused
    }

    override fun hasWindowFocus(): Boolean {
        // None of our views here correctly report they have window focus because of how we're embedding
        // the platform view inside of a virtual display.
        return focused
    }

    override fun getRootView(): View {
        return _rootView
    }

    override fun onCheckIsTextEditor(): Boolean {
        return true
    }

    override fun isFocused(): Boolean {
        return focused
    }

    override fun getWindowToken(): IBinder? {
        return _windowToken
    }

    override fun getHandler(): Handler? {
        return imeHandler
    }
    fun dispose(){
        _windowToken=null
        cachedConnection=null
        targetView=null
        imeHandler=null
        isFocusable = false
        focused=false
    }

    init {
        _windowToken = containerView.windowToken
        _rootView = containerView.rootView
        isFocusable = true
        isFocusableInTouchMode = true
        visibility = VISIBLE
    }
}