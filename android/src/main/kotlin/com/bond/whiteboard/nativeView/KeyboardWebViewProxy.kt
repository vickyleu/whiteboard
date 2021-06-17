package com.bond.whiteboard.nativeView

import android.app.ActivityManager
import android.content.Context
import android.content.Context.INPUT_METHOD_SERVICE
import android.content.res.Configuration
import android.graphics.Rect
import android.os.Build
import android.util.AttributeSet
import android.util.Log
import android.view.View
import android.view.View.OnFocusChangeListener
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.FrameLayout
import android.widget.ListPopupWindow
import androidx.annotation.RequiresApi
import com.tencent.smtt.sdk.WebView
import io.flutter.app.FlutterApplication


class KeyboardWebViewProxy : FrameLayout {

    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    )

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    constructor(
        context: Context,
        attrs: AttributeSet?,
        defStyleAttr: Int,
        defStyleRes: Int
    ) : super(context, attrs, defStyleAttr, defStyleRes)


    val focusChangeListener = OnFocusChangeListener { v, hasFocus ->
        if (v is WebView) {
            for (i in 0 until v.childCount) {
                val vv = v.getChildAt(i)
                if (vv.javaClass.simpleName.contains("InnerWebView") ||
                    vv.javaClass.superclass.canonicalName == "android.webkit.WebView") {
                    Log.e(
                        TAG,
                        "OnFocusChangeListener ${vv.javaClass.simpleName} ${vv.javaClass.superclass.canonicalName} ${hasFocus}"
                    )
                    vv.requestFocus()
                    checkInputConnectionProxy(vv)
                    return@OnFocusChangeListener
                }
            }
        }
    }

    override fun onConfigurationChanged(newConfig: Configuration?) {
        super.onConfigurationChanged(newConfig)
        val orientation = newConfig?.orientation ?: return
        if (orientation == Configuration.ORIENTATION_PORTRAIT) {
            Log.e("onConfigurationChanged", "旋转到垂直")
        } else {
            Log.e("onConfigurationChanged", "旋转到横屏")
        }
    }

    private val TAG = "InputAwareWebView"
    private var threadedInputConnectionProxyView: View? = null
    private var proxyAdapterView: ThreadedInputConnectionProxyAdapterView? = null
    private var containerView: View? = null

    constructor(context: Context, containerView: View?) : super(context) {
        this.containerView = containerView
    }

    fun setContainerView(containerView: View?) {
        this.containerView = containerView
        Log.w(TAG, "The containerView has changed.${containerView}")
        if (proxyAdapterView == null) {
            return
        }
        Log.w(TAG, "The containerView has changed while the proxyAdapterView exists.")
        if (containerView != null) {
            setInputConnectionTarget(proxyAdapterView)
        }
    }

    /**
     * Set our proxy adapter view to use its cached input connection instead of creating new ones.
     *
     *
     * This is used to avoid losing our input connection when the virtual display is resized.
     */
    fun lockInputConnection() {
        if (proxyAdapterView == null) {
            return
        }
        proxyAdapterView!!.setLocked(true)
    }

    /** Sets the proxy adapter view back to its default behavior.  */
    fun unlockInputConnection() {
        if (proxyAdapterView == null) {
            return
        }
        proxyAdapterView!!.setLocked(false)
    }

    /** Restore the original InputConnection, if needed.  */
    fun dispose() {
        hideKb()
        proxyAdapterView?.dispose()
//        clearFocus()
        proxyAdapterView = null
        threadedInputConnectionProxyView = null
//        containerView?.requestFocus()
//        resetInputConnection()
    }

    /**
     * Creates an InputConnection from the IME thread when needed.
     *
     *
     * We only need to create a [ThreadedInputConnectionProxyAdapterView] and create an
     * InputConnectionProxy on the IME thread when WebView is doing the same thing. So we rely on the
     * system calling this method for WebView's proxy view in order to know when we need to create our
     * own.
     *
     *
     * This method would normally be called for any View that used the InputMethodManager. We rely
     * on flutter/engine filtering the calls we receive down to the ones in our hierarchy and the
     * system WebView in order to know whether or not the system WebView expects an InputConnection on
     * the IME thread.
     */
    override fun checkInputConnectionProxy(view: View): Boolean {
        Log.e(
            TAG,
            "checkInputConnectionProxy create a proxy view $view."
        )
        // Check to see if the view param is WebView's ThreadedInputConnectionProxyView.
        val previousProxy = threadedInputConnectionProxyView
        threadedInputConnectionProxyView = view
        if (previousProxy === view) {
            // This isn't a new ThreadedInputConnectionProxyView. Ignore it.
            return super.checkInputConnectionProxy(view)
        }
        if (containerView == null) {
            Log.e(
                TAG,
                "Can't create a proxy view because there's no container view. Text input may not work."
            )
            return super.checkInputConnectionProxy(view)
        }
        // We've never seen this before, so we make the assumption that this is WebView's
        // ThreadedInputConnectionProxyView. We are making the assumption that the only view that could
        // possibly be interacting with the IMM here is WebView's ThreadedInputConnectionProxyView.
        if (view.handler == null) return super.checkInputConnectionProxy(view)
        Log.e("viewviewview", "${view.javaClass.simpleName}")
        proxyAdapterView = ThreadedInputConnectionProxyAdapterView( /*containerView=*/
            containerView!!,  /*targetView=*/
            view,  /*imeHandler=*/
            view.handler
        )
        setInputConnectionTarget( /*targetView=*/proxyAdapterView)
        return super.checkInputConnectionProxy(view)
    }

    /**
     * Ensure that input creation happens back on [.containerView]'s thread once this view no
     * longer has focus.
     *
     *
     * The logic in [.checkInputConnectionProxy] forces input creation to happen on Webview's
     * thread for all connections. We undo it here so users will be able to go back to typing in
     * Flutter UIs as expected.
     */
    override fun clearFocus() {
        super.clearFocus()
        resetInputConnection()
    }

    /**
     * Ensure that input creation happens back on [.containerView].
     *
     *
     * The logic in [.checkInputConnectionProxy] forces input creation to happen on Webview's
     * thread for all connections. We undo it here so users will be able to go back to typing in
     * Flutter UIs as expected.
     */
    private fun resetInputConnection() {
        if (proxyAdapterView == null) {
            // No need to reset the InputConnection to the default thread if we've never changed it.
            return
        }
        if (containerView == null) {
            Log.e(
                TAG,
                "Can't reset the input connection to the container view because there is none."
            )
            return
        }
        setInputConnectionTarget( /*targetView=*/containerView)
    }

    /**
     * This is the crucial trick that gets the InputConnection creation to happen on the correct
     * thread pre Android N.
     * https://cs.chromium.org/chromium/src/content/public/android/java/src/org/chromium/content/browser/input/ThreadedInputConnectionFactory.java?l=169&rcl=f0698ee3e4483fad5b0c34159276f71cfaf81f3a
     *
     *
     * `targetView` should have a [View.getHandler] method with the thread that future
     * InputConnections should be created on.
     */
    private fun setInputConnectionTarget(targetView: View?) {
        if (containerView == null) {
            Log.e(
                TAG,
                "Can't set the input connection target because there is no containerView to use as a handler."
            )
            return
        }
        targetView?.requestFocus()
        containerView?.post {
            val imm: InputMethodManager =
                context.getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
            targetView?.onWindowFocusChanged(true)
            try {
                val value = imm.isActive(containerView)
                if (!value) {
                    imm.toggleSoftInput(
                        InputMethodManager.SHOW_FORCED,
                        InputMethodManager.HIDE_IMPLICIT_ONLY
                    )
                }
                Log.e("激活", "$containerView")
            } catch (e: Exception) {
                Log.e("Exception", "${e.message}")
            }
        }
    }

    fun onTextFocusChange(focus: Boolean) {
        if (focus) {
            showKb()
        } else {
            hideKb()
        }
    }

    private fun showKb() {
        if (containerView == null) {
            Log.e(
                TAG,
                "Can't set the input connection target because there is no containerView to use as a handler."
            )
            return
        }
        proxyAdapterView?.requestFocus()
        containerView?.post {
            val imm: InputMethodManager =
                context.getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
            proxyAdapterView?.onWindowFocusChanged(true)
            try {
                val value = imm.isActive(containerView)
                if (!value) {
                    val appContext = context.applicationContext

                    if (appContext is FlutterApplication) {
                        val currentActivity = appContext.currentActivity
                        Log.e("currentActivity","${currentActivity}")
                        if (currentActivity != null) {
                            Log.e("currentActivity","${currentActivity.javaClass.simpleName}")
                            imm.showSoftInputFromInputMethod(currentActivity.window.decorView.windowToken,0)
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e("Exception", "${e.message}")
            }
        }
        //            lockInputConnection()
    }

    private fun hideKb() {
        if (containerView == null) {
            Log.e(
                TAG,
                "Can't set the input connection target because there is no containerView to use as a handler."
            )
            return
        }
        proxyAdapterView?.clearFocus()
        containerView?.post {
            val imm: InputMethodManager =
                context.getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
            proxyAdapterView?.onWindowFocusChanged(false)
            val value = imm.hideSoftInputFromWindow(proxyAdapterView?.windowToken, 0)
        }
        unlockInputConnection()
    }

    fun onActiveFocus() {
        val rootview = this.rootView
        val view = rootview.findFocus()
        if (view != null && view is WebView) {
            view.onFocusChangeListener?.onFocusChange(view, true)
            view.view.requestFocus()
        }
    }


    override fun onFocusChanged(focused: Boolean, direction: Int, previouslyFocusedRect: Rect?) {
        // This works around a crash when old (<67.0.3367.0) Chromium versions are used.

        // Prior to Chromium 67.0.3367 the following sequence happens when a select drop down is shown
        // on tablets:
        //
        //  - WebView is calling ListPopupWindow#show
        //  - buildDropDown is invoked, which sets mDropDownList to a DropDownListView.
        //  - showAsDropDown is invoked - resulting in mDropDownList being added to the window and is
        //    also synchronously performing the following sequence:
        //    - WebView's focus change listener is loosing focus (as mDropDownList got it)
        //    - WebView is hiding all popups (as it lost focus)
        //    - WebView's SelectPopupDropDown#hide is invoked.
        //    - DropDownPopupWindow#dismiss is invoked setting mDropDownList to null.
        //  - mDropDownList#setSelection is invoked and is throwing a NullPointerException (as we just set mDropDownList to null).
        //
        // To workaround this, we drop the problematic focus lost call.
        // See more details on: https://github.com/flutter/flutter/issues/54164
        //
        // We don't do this after Android P as it shipped with a new enough WebView version, and it's
        // better to not do this on all future Android versions in case DropDownListView's code changes.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P && isCalledFromListPopupWindowShow()
            && !focused
        ) {
            return
        }
        super.onFocusChanged(focused, direction, previouslyFocusedRect)
    }

    private fun isCalledFromListPopupWindowShow(): Boolean {
        val stackTraceElements = Thread.currentThread().stackTrace
        for (stackTraceElement in stackTraceElements) {
            if (stackTraceElement.className == ListPopupWindow::class.java.getCanonicalName() && stackTraceElement.methodName == "show") {
                return true
            }
        }
        return false
    }
}