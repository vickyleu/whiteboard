package com.tencent.tic.core.impl

import android.os.Handler
import android.text.TextUtils
import com.tencent.instacart.library.truetime.TrueTime.Companion.build
import com.tencent.instacart.library.truetime.TrueTime.Companion.clearCachedInfo
import java.io.IOException
import java.lang.ref.WeakReference

class NTPController(listener: TrueTimeListener) {
    interface TrueTimeListener {
        fun onGotTrueTimeRusult(code: Int, msg: String?)
    }

    var mWeakListener: WeakReference<TrueTimeListener>
    var mHandler: Handler
    fun start(ntpServer: String?) {
        if (!build().isInitialized) {
            Thread(MyRunnable(this, ntpServer)).start()
        } else {
            //直接回调成功
            callback(SUCC)
        }
    }

    fun callback(result: Int) {
        mHandler.post {
            val listener = mWeakListener.get()
            listener?.onGotTrueTimeRusult(
                result,
                if (result == SUCC) "succ" else "ntp time out"
            )
        }
    }

    internal class MyRunnable(controller: NTPController, ntpServer: String?) : Runnable {
        var mRef: WeakReference<NTPController>
        val mNtpServer: String
        override fun run() {
            var result = FAILED
            for (i in 0 until MAX_RETRY) {
                try {
                    build().withNtpHost(mNtpServer).initialize()
                    result = SUCC
                    break
                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }
            val controller = mRef.get()
            controller?.callback(result)
        }

        init {
            mRef = WeakReference(controller)
            mNtpServer = if (TextUtils.isEmpty(ntpServer)) NTP_HOST else ntpServer!!
        }
    }

    companion object {
        const val SUCC = 0
        const val FAILED = 1
        const val MAX_RETRY = 5
        const val NTP_HOST = "time1.cloud.tencent.com"
    }

    init {
        clearCachedInfo()
        mHandler = Handler()
        mWeakListener = WeakReference(listener)
    }
}