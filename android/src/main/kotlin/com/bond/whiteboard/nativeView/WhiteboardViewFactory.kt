package com.bond.whiteboard.nativeView

import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import com.tencent.smtt.sdk.WebView
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class WhiteboardViewFactory: PlatformViewFactory(io.flutter.plugin.common.StandardMessageCodec.INSTANCE), NativeViewLink {
    private var threadedInputConnectionProxyView: View? = null
    internal var proxyAdapterView: ThreadedInputConnectionProxyAdapterView? = null

    val TAG="WhiteboardNativeView"

    var mBoardView:WebView?=null

    private var nativeViewContainer: WhiteboardNativeView?=null

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        if(nativeViewContainer==null){
            nativeViewContainer= WhiteboardNativeView(context, viewId,args)
        }else{
            nativeViewContainer?.update(viewId,args)
        }
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


    override fun managerBoardView(boardView: WebView) {
        mBoardView=boardView

    }

    /** Restore the original InputConnection, if needed.  */
    override fun releaseBoardView(boardView: WebView) {
//        resetInputConnection()
        mBoardView=null
    }

//    override fun onInputConnectionLocked() {
//        super.onInputConnectionLocked()
//        if (proxyAdapterView == null) {
//            return
//        }
//        proxyAdapterView?.setLocked(true);
//    }
//
//    override fun onInputConnectionUnlocked() {
//        super.onInputConnectionUnlocked()
//        if (proxyAdapterView == null) {
//            return
//        }
//        proxyAdapterView?.setLocked(false);
//    }
//
//    /**
//     * Creates an InputConnection from the IME thread when needed.
//     *
//     *
//     * We only need to create a [ThreadedInputConnectionProxyAdapterView] and create an
//     * InputConnectionProxy on the IME thread when WebView is doing the same thing. So we rely on the
//     * system calling this method for WebView's proxy view in order to know when we need to create our
//     * own.
//     *
//     *
//     * This method would normally be called for any View that used the InputMethodManager. We rely
//     * on flutter/engine filtering the calls we receive down to the ones in our hierarchy and the
//     * system WebView in order to know whether or not the system WebView expects an InputConnection on
//     * the IME thread.
//     */
//    fun checkInputConnectionProxy(view: View): Boolean {
//        // Check to see if the view param is WebView's ThreadedInputConnectionProxyView.
//        val previousProxy = threadedInputConnectionProxyView!!
//        threadedInputConnectionProxyView = view
//        if (previousProxy === view) {
//            // This isn't a new ThreadedInputConnectionProxyView. Ignore it.
//            return super.checkInputConnectionProxy(view)
//        }
//        if (rootView == null) {
//            Log.e(
//                TAG,
//                "Can't create a proxy view because there's no container view. Text input may not work."
//            )
//            return super.checkInputConnectionProxy(view)
//        }
//
//        // We've never seen this before, so we make the assumption that this is WebView's
//        // ThreadedInputConnectionProxyView. We are making the assumption that the only view that could
//        // possibly be interacting with the IMM here is WebView's ThreadedInputConnectionProxyView.
//        proxyAdapterView = ThreadedInputConnectionProxyAdapterView( /*rootView=*/
//            rootView,  /*targetView=*/
//            view,  /*imeHandler=*/
//            view.handler
//        )
//        setInputConnectionTarget( /*targetView=*/proxyAdapterView)
//        return super.checkInputConnectionProxy(view)
//    }
//
//    /**
//     * Ensure that input creation happens back on [.rootView]'s thread once this view no
//     * longer has focus.
//     *
//     *
//     * The logic in [.checkInputConnectionProxy] forces input creation to happen on Webview's
//     * thread for all connections. We undo it here so users will be able to go back to typing in
//     * Flutter UIs as expected.
//     */
//    fun clearFocus() {
//        super.clearFocus()
//        resetInputConnection()
//    }
//
//    /**
//     * Ensure that input creation happens back on [.rootView].
//     *
//     *
//     * The logic in [.checkInputConnectionProxy] forces input creation to happen on Webview's
//     * thread for all connections. We undo it here so users will be able to go back to typing in
//     * Flutter UIs as expected.
//     */
//    private fun resetInputConnection() {
//        if (proxyAdapterView == null) {
//            // No need to reset the InputConnection to the default thread if we've never changed it.
//            return
//        }
//        if (rootView == null) {
//            Log.e(
//                TAG,
//                "Can't reset the input connection to the container view because there is none."
//            )
//            return
//        }
//        setInputConnectionTarget( /*targetView=*/rootView)
//    }
//
//    /**
//     * This is the crucial trick that gets the InputConnection creation to happen on the correct
//     * thread pre Android N.
//     * https://cs.chromium.org/chromium/src/content/public/android/java/src/org/chromium/content/browser/input/ThreadedInputConnectionFactory.java?l=169&rcl=f0698ee3e4483fad5b0c34159276f71cfaf81f3a
//     *
//     *
//     * `targetView` should have a [View.getHandler] method with the thread that future
//     * InputConnections should be created on.
//     */
//    private fun setInputConnectionTarget(targetView: View) {
//        if (rootView == null) {
//            Log.e(
//                TAG,
//                "Can't set the input connection target because there is no rootView to use as a handler."
//            )
//            return
//        }
//        targetView.requestFocus()
//        rootView.post {
//            val imm: InputMethodManager =
//                rootView.context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
//            // This is a hack to make InputMethodManager believe that the target view now has focus.
//            // As a result, InputMethodManager will think that targetView is focused, and will call
//            // getHandler() of the view when creating input connection.
//            // Step 1: Set targetView as InputMethodManager#mNextServedView. This does not affect
//            // the real window focus.
//            targetView.onWindowFocusChanged(true)
//            // Step 2: Have InputMethodManager focus in on targetView. As a result, IMM will call
//            // onCreateInputConnection() on targetView on the same thread as
//            // targetView.getHandler(). It will also call subsequent InputConnection methods on this
//            // thread. This is the IME thread in cases where targetView is our proxyAdapterView.
//            imm.isActive(rootView)
//        }
//    }
}
