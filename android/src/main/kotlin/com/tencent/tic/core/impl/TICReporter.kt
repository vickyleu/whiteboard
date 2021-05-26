package com.tencent.tic.core.impl

import android.os.Build
import android.text.TextUtils
import android.util.Log
import com.tencent.tic.core.impl.utils.TXHttpRequestM
import org.json.JSONObject
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

object TICReporter {
    const val TAG = "TICReporter"
    const val URL = "https://ilivelog.qcloud.com/log/report?sign="
    const val Connection = "&"
    var businessHeader = BusinessHeader()
    @JvmStatic
    fun updateAppId(sdkAppid: Int) {
        businessHeader.setAppId(sdkAppid)
    }

    @JvmStatic
    fun updateUserId(userId: String?) {
        businessHeader.setUserId(userId)
    }

    @JvmStatic
    fun updateRoomId(roomid: Int) {
        businessHeader.setRoomId(roomid)
    }
//    @JvmStatic
//    fun report(event: String, data: String?) {
//        report(event, 0, null, data)
//    }

    @JvmStatic
    fun report(event: String, code: Int = 0, msg: String? = null, data: String? = null) {
        val eventBody = EventBody(event, code, msg, data, null)
        val eventStr = eventBody.toString()
        val value = businessHeader.toString()
        var kvalue = eventStr + value

        //2. 删除最后的连接符&
        val lastString = kvalue.substring(kvalue.length - 1)
        if (lastString == Connection) {
            kvalue = kvalue.substring(0, kvalue.length - 1)
        }
        val jsonBody = JsonBody(kvalue)
        val result = jsonBody.toString()

        //发送
        if (!TextUtils.isEmpty(result)) {
            val sign = md5(result)
            Log.i(TAG, "md5:$sign report:$result")
            val httpRequest = TXHttpRequestM()
            httpRequest.sendHttpsRequest(URL + sign, result.toByteArray(), null, "application/json")
        }
    }

    fun md5(string: String): String {
        if (TextUtils.isEmpty(string)) {
            return ""
        }
        var md5: MessageDigest? = null
        try {
            md5 = MessageDigest.getInstance("MD5")
            val bytes = md5.digest(string.toByteArray())
            var result = ""
            for (b in bytes) {
                var temp = Integer.toHexString(b.toInt() and (0xff).toInt())
                if (temp.length == 1) {
                    temp = "0$temp"
                }
                result += temp
            }
            return result
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        }
        return ""
    }

    object EventId {
        const val INIT_SDK_START = "initSdk_start"
        const val INIT_SDK_END = "initSdk_end"
        const val LOGIN_START = "login_start"
        const val LOGIN_END = "login_end"
        const val LOGOUT_START = "logout_start"
        const val LOGOUT_END = "logout_end"
        const val CREATE_GROUP_START = "createGroup_start"
        const val CREATE_GROUP_END = "createGroup_end"
        const val DELETE_GROUP_START = "deleteGroup_start"
        const val DELETE_GROUP_END = "deleteGroup_end"
        const val JOIN_GROUP_START = "joinGroup_start"
        const val JOIN_GROUP_END = "joinGroup_end"
        const val INIT_BOARD_START = "initBoard_start"
        const val INIT_BOARD_END = "initBoard_end"
        const val UN_INIT_BOARD = "unInitBoard"
        const val SYNC_BOARD_HISTORY_END = "syncBoardHistory_end"
        const val ENTER_ROOM_START = "enterRoom_start"
        const val ENTER_ROOM_END = "enterRoom_end"
        const val QUIT_GROUP_START = "quitGroup_start"
        const val QUIT_GROUP_END = "quitGroup_end"
        const val SEND_OFFLINE_RECORD_INFO_START = "sendOfflineRecordInfo_start"
        const val SEND_OFFLINE_RECORD_INFO_END = "sendOfflineRecordInfo_end"
        const val ON_USER_AUDIO_AVAILABLE = "onUserAudioAvailable"
        const val ON_USER_VIDEO_AVAILABLE = "onUserVideoAvailable"
        const val ON_USER_SUB_STREAM_AVAILABLE = "onUserSubStreamAvailable"
        const val ON_FORCE_OFFLINE = "onForceOffline"
        const val ON_USER_SIG_EXPIRED = "onUserSigExpired"
        const val ON_TEBERROR = "onTEBError"
        const val ON_TEBWARNING = "onTEBWarning"
    }

    internal class JsonBody(  //key-value格式的业务字段字符串，格式为“key1=value1&key2=value2“
        var kvStr: String
    ) {
        var business = "tic2.0" //固定“tic”
        var dcid = "dc0000" //固定“dc0000”
        var version = 0 //固定“0”
        override fun toString(): String {
            var result = ""
            val json = JSONObject()
            try {
                json.put("business", business)
                json.put("dcid", dcid)
                json.put("version", version)
                json.put("kv_str", kvStr)
                result = json.toString()
            } catch (e: Exception) {
                e.printStackTrace()
            }
            return result
        }
    }

    class BusinessHeader {
        var sdkAppId //应用标识
                = 0
        var userID //用户Id
                : String? = null
        var sdkVersion //sdk版本号
                : String? = null
        var devId: String? = null //设备Id
        var devType = Build.MANUFACTURER + " " + Build.MODEL //设备型号
        var netType //网络类型，"Wifi","4G","3G","2G"
                : String? = null
        var platform = "Android" //平台，"iOS","Android","macOS","Windows","Web","小程序"
        var sysVersion = Build.VERSION.RELEASE //系统版本
        var roomId //房间号
                : String? = null
        var result: String? = null
        fun setAppId(sdkAppid: Int) {
            sdkAppId = sdkAppid
            result = null
        }

        fun setUserId(userId: String?) {
            this.userID = userId
            result = null
        }

        fun setRoomId(roomid: Int) {
            roomId = roomid.toString()

            //
            result = null
        }

        override fun toString(): String {
            if (TextUtils.isEmpty(result)) {
                result = "sdkAppId=$sdkAppId$Connection"
                if (!TextUtils.isEmpty(userID)) {
                    result += "userId=$userID$Connection"
                }
                if (!TextUtils.isEmpty(sdkVersion)) {
                    result += "sdkVersion=$sdkVersion$Connection"
                }
                if (!TextUtils.isEmpty(devId)) {
                    result += "devId=$devId$Connection"
                }
                result += "devType=$devType$Connection"
                if (!TextUtils.isEmpty(netType)) {
                    result += "netType=$netType$Connection"
                }
                result += "platform=$platform$Connection"
                result += "sysVersion=$sysVersion$Connection"
                if (!TextUtils.isEmpty(roomId)) {
                    result += "roomId=$roomId$Connection"
                }
            }
            return result!!
        }
    }

    internal class EventBody(
        var event: String,
        var errorCode: Int,
        var errorDesc: String?,
        var data: String?,
        var ext: String?
    ) {
        var timestamp: Long
        var timeCost = 0
        override fun toString(): String {
            var result = "timestamp=$timestamp$Connection"
            result += "event=$event$Connection"
            result += "errorCode=$errorCode$Connection"
            if (!TextUtils.isEmpty(errorDesc)) {
                result += "errorDesc=$errorDesc$Connection"
            }
            if (!TextUtils.isEmpty(data)) {
                result += "data=$data$Connection"
            }
            if (!TextUtils.isEmpty(ext)) {
                result += "ext=$ext$Connection"
            }
            return result
        }

        init {
            timestamp = System.currentTimeMillis()
        }
    }
}