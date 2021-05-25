package com.tencent.tic.core.impl.utils

import android.os.AsyncTask
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import com.tencent.liteav.basic.log.TXCLog
import java.io.ByteArrayOutputStream
import java.io.DataOutputStream
import java.lang.ref.WeakReference
import java.net.HttpURLConnection
import java.net.URL
import javax.net.ssl.HttpsURLConnection

/**
 * Created by xkazer on 2018/10/8.
 */
class TXHttpRequestM {
    interface TXHttpListenner {
        fun onRecvMessage(errCode: Int, msg: String?, data: ByteArray?)
    }

    fun sendHttpsRequest(url: String, data: ByteArray, callback: TXHttpListenner?): Int {
        TXCLog.i(TAG, "sendHttpsRequest->enter action: " + url + ", data size: " + data.size)
        asyncPostRequest(url.toByteArray(), data, callback, null)
        return 0
    }

    fun sendHttpsRequest(
        url: String,
        data: ByteArray,
        callback: TXHttpListenner?,
        contentType: String?
    ): Int {
        TXCLog.i(TAG, "sendHttpsRequest->enter action: " + url + ", data size: " + data.size)
        asyncPostRequest(url.toByteArray(), data, callback, contentType)
        return 0
    }

    fun asyncPostRequest(
        action: ByteArray?,
        data: ByteArray?,
        callback: TXHttpListenner?,
        contentType: String?
    ) {
        val request = TXPostRequest(callback, contentType)
        request.execute(action, data)
    }

    internal class TXResult {
        var errCode = -1
        var errMsg = ""
        var data = "".toByteArray()
    }

    internal class TXPostRequest(callback: TXHttpListenner?, private val mContentType: String?) :
        AsyncTask<ByteArray, Void?, TXResult>() {
        private val mHttpRequest: WeakReference<TXHttpListenner?>
        private var mHandler: Handler? = null

        override fun doInBackground(vararg bytes: ByteArray): TXResult {
            val result = TXResult()
            try {
                if (String(bytes[0]).startsWith("https")) {
                    result.data = getHttpsPostRsp(String(bytes[0]), bytes[1], mContentType)
                } else {
                    result.data = getHttpPostRsp(String(bytes[0]), bytes[1])
                }
                result.errCode = 0
            } catch (e: Exception) {
                result.errMsg = e.toString()
            }
            TXCLog.i(TAG, "TXPostRequest->result: " + result.errCode + "|" + result.errMsg)
            return result
        }

        override fun onPostExecute(txResult: TXResult) {
            super.onPostExecute(txResult)
            val request = mHttpRequest.get()
            if (request != null) {
                if (mHandler != null) {
                    mHandler?.post {
                        request.onRecvMessage(
                            txResult.errCode,
                            txResult.errMsg,
                            txResult.data
                        )
                    }
                } else {
                    request.onRecvMessage(txResult.errCode, txResult.errMsg, txResult.data)
                }
            }
        }

        init {
            mHttpRequest = WeakReference(callback)
            val looper = Looper.myLooper()
            mHandler = if (looper != null) {
                Handler(looper)
            } else {
                null
            }
        }
    }

    companion object {
        private const val TAG = "TXHttpRequest"
        private const val CON_TIMEOUT = 1000 * 5
        private const val READ_TIMEOUT = 1000 * 5

        //Http
        @Throws(Exception::class)
        fun getHttpPostRsp(strAction: String, data: ByteArray): ByteArray {
            TXCLog.i(TAG, "getHttpPostRsp->request: $strAction")
            TXCLog.i(TAG, "getHttpPostRsp->data size: " + data.size)
            val url = URL(strAction.replace(" ", "%20"))
            val conn = url.openConnection() as HttpURLConnection
            conn.doInput = true
            conn.doOutput = true
            conn.connectTimeout = CON_TIMEOUT
            conn.readTimeout = READ_TIMEOUT
            conn.requestMethod = "POST"
            val out = DataOutputStream(conn.outputStream)
            out.write(data)
            out.flush()
            out.close()
            val rspCode = conn.responseCode
            return if (rspCode == 200) {
                val `in` = conn.inputStream
                val byBuffer = ByteArrayOutputStream()
                val byData = ByteArray(1024)
                var nRead: Int
                while (`in`.read(data, 0, data.size).also { nRead = it } != -1) {
                    byBuffer.write(data, 0, nRead)
                }
                byBuffer.flush()
                `in`.close()
                conn.disconnect()
                TXCLog.i(TAG, "getHttpsPostRsp->rsp size: " + byBuffer.size())
                byBuffer.toByteArray()
            } else {
                TXCLog.i(TAG, "getHttpPostRsp->response code: $rspCode")
                throw Exception("response: $rspCode")
            }
        }

        //HTTPS
        @Throws(Exception::class)
        fun getHttpsPostRsp(strAction: String, data: ByteArray, contentType: String?): ByteArray {
            TXCLog.i(TAG, "getHttpsPostRsp->request: $strAction")
            TXCLog.i(TAG, "getHttpsPostRsp->data: " + data.size)
            val url = URL(strAction.replace(" ", "%20"))
            val conn = url.openConnection() as HttpsURLConnection
            conn.doInput = true
            conn.doOutput = true
            conn.connectTimeout = CON_TIMEOUT
            conn.readTimeout = READ_TIMEOUT
            conn.requestMethod = "POST"
            if (!TextUtils.isEmpty(contentType)) {
                conn.setRequestProperty("Content-Type", contentType)
            }
            val out = DataOutputStream(conn.outputStream)
            out.write(data)
            out.flush()
            out.close()
            val rspCode = conn.responseCode
            return if (rspCode == 200) {
                val `in` = conn.inputStream
                val byBuffer = ByteArrayOutputStream()
                val byData = ByteArray(1024)
                var nRead: Int
                while (`in`.read(data, 0, data.size).also { nRead = it } != -1) {
                    byBuffer.write(data, 0, nRead)
                }
                byBuffer.flush()
                `in`.close()
                conn.disconnect()
                TXCLog.i(TAG, "getHttpsPostRsp->rsp size: " + byBuffer.size())
                byBuffer.toByteArray()
            } else {
                TXCLog.i(TAG, "getHttpsPostRsp->response code: $rspCode")
                throw Exception("response: $rspCode")
            }
        }
    }
}