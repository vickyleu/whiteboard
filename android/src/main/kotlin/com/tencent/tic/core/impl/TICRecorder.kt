package com.tencent.tic.core.impl

import android.text.TextUtils
import com.tencent.instacart.library.truetime.TrueTime.Companion.now
import com.tencent.liteav.basic.log.TXCLog
import com.tencent.liteav.basic.util.TXCTimeUtil
import com.tencent.teduboard.TEduBoardController.TEduBoardAuthParam
import com.tencent.tic.core.impl.NTPController.TrueTimeListener
import com.tencent.tic.core.impl.TICReporter.report
import com.tencent.tic.core.impl.utils.TXHttpRequestM
import com.tencent.tic.core.impl.utils.TXHttpRequestM.TXHttpListenner
import org.json.JSONObject
import java.lang.ref.WeakReference

class TICRecorder(tic: TICManagerImplM) : TXHttpListenner {
    private var mGroupId = 0
    private val mTicRef: WeakReference<TICManagerImplM>
    var httpRequest: TXHttpRequestM

    //NTP
    var mNtp: NTPController
    var mNtpListener: TrueTimeListener
    fun start(authParam: TEduBoardAuthParam?, roomId: Int, ntpServer: String?) {
        //1.ntp
        report(TICReporter.EventId.SEND_OFFLINE_RECORD_INFO_START)
        mGroupId = roomId
        mNtp.start(ntpServer)

        //2.
        reportGroupId(authParam, roomId)
    }

    protected fun sendTIMOffLineRecordInfo(ntpTime: Long, avSdkTime: Long, boardTime: Long) {
        TXCLog.i(
            TAG, "setTimeBaseLine base:" + ntpTime + " av:" + avSdkTime + " board:"
                    + boardTime + " diff:" + (boardTime - ntpTime)
        )
        val tic = mTicRef.get()
        if (tic != null) {
            var result = ""
            val json = JSONObject()
            try {
                json.put("type", 1008)
                json.put("time_line", ntpTime)
                json.put("avsdk_time", avSdkTime)
                json.put("board_time", boardTime)
                result = json.toString()
            } catch (e: Exception) {
                e.printStackTrace()
            }
            if (!TextUtils.isEmpty(result)) {
                tic.sendCommand(TICSDK_CONFERENCE_CMD, result.toByteArray())
            } else {
                TXCLog.i(TAG, "setTimeBaseLine error, result=null")
            }
        } else {
            TXCLog.i(TAG, "setTimeBaseLine error, tic=null")
        }
    }

    private fun reportGroupId(authParam: TEduBoardAuthParam?, roomId: Int) {
        if (authParam != null) {
            val URL = String.format(
                URL_TEMPLATE_RELEASE, authParam.sdkAppId, authParam.userId, authParam.userSig
            )
            val body = encodeRequestTokenPacket(roomId)
            if (!TextUtils.isEmpty(body)) {
                httpRequest.sendHttpsRequest(URL, body.toByteArray(), this)
            }
        }
    }

    override fun onRecvMessage(errCode: Int, msg: String?, data: ByteArray?) {
        TXCLog.i(TAG, "OnRecvMessage http code: $errCode msg:$msg")
    }

    fun encodeRequestTokenPacket(room: Int): String {
        var result = ""
        val json = JSONObject()
        try {
            json.put("cmd", "open_record_svc")
            json.put("sub_cmd", "report_group")
            json.put("group_id", room.toString())
            result = json.toString()
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return result
    }

    internal inner class MyTrueTimeListener : TrueTimeListener {
        override fun onGotTrueTimeRusult(code: Int, msg: String?) {
            if (code == NTPController.SUCC) {
                report(TICReporter.EventId.SEND_OFFLINE_RECORD_INFO_END)
                try {
                    val avsSdkTime = TXCTimeUtil.getTimeTick()
                    val ntpTime = now().time
                    val boardTime = System.currentTimeMillis()
                    TXCLog.i(
                        TAG, "TICManager: onGotTrueTimeRusult " + code + "|" + msg + "|"
                                + now().toString() + "|" + ntpTime + "|" + avsSdkTime + "|" + boardTime
                    )
                    sendTIMOffLineRecordInfo(ntpTime, avsSdkTime, boardTime)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            } else {
                TXCLog.i(
                    TAG,
                    "TICManager: onGotTrueTimeRusult failed: " + NTPController.NTP_HOST + "|" + msg
                )
                report(TICReporter.EventId.SEND_OFFLINE_RECORD_INFO_END, code, "$msg:$mNtp")
                val tic = mTicRef.get()
                tic?.trigleOffLineRecordCallback(code, msg)
            }
        }
    }

    companion object {
        //
        private const val TAG = "TICManager"
        const val TICSDK_CONFERENCE_CMD = "TXConferenceExt"
        private const val URL_TEMPLATE_TEST =
            "https://test.tim.qq.com/v4/ilvb_test/record?sdkappid=%d&identifier=%s&usersig=%s&contenttype=json"
        private const val URL_TEMPLATE_RELEASE =
            "https://yun.tim.qq.com/v4/ilvb_edu/record?sdkappid=%d&identifier=%s&usersig=%s&contenttype=json"
    }

    init {
        mTicRef = WeakReference(tic)
        httpRequest = TXHttpRequestM()
        mNtpListener = MyTrueTimeListener()
        mNtp = NTPController(mNtpListener)
    }
}