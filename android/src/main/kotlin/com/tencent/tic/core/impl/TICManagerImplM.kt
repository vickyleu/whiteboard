package com.tencent.tic.core.impl

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.bond.whiteboard.teb.BoardAwareInterface
import com.tencent.liteav.basic.log.TXCLog
import com.tencent.teduboard.TEduBoardController
import com.tencent.teduboard.TEduBoardController.*
import com.tencent.tic.core.TICCallback
import com.tencent.tic.core.TICClassroomOption
import com.tencent.tic.core.TICManager
import com.tencent.tic.core.impl.TICReporter.report
import com.tencent.tic.core.impl.TICReporter.updateAppId
import com.tencent.tic.core.impl.TICReporter.updateUserId
import org.json.JSONObject
import java.lang.ref.WeakReference

class TICManagerImplM private constructor() : TICManager() {

    private var mMainHandler:Handler?=null
    var mIsSendSyncTime = false //

    //Board
    private var mBoard: TEduBoardController? = null
    private var mBoardCallback: BoardCallback? = null

    //Recorder
    private var mRecorder: TICRecorder? = null
    private var mAppContext: Context? = null
    private var sdkAppId = 0
    private var userInfo= UserInfo()
    private var classroomOption: TICClassroomOption? = null

    override fun init(context: Context, appId: Int, userId: String, userSig: String): Int {
        mMainHandler=Handler(Looper.getMainLooper())
        TXCLog.i(TAG, "TICManager: init, context:$context appid:$appId")
        updateAppId(appId)
        report(TICReporter.EventId.INIT_SDK_START)
        updateUserId(userId)
        // IM 登陆
        setUserInfo(userId, userSig)
        //0、给值
        sdkAppId = appId
        //0、给值
        mAppContext = context.applicationContext
        //3. TEdu Board
        if (mBoard == null) {
            mBoard = TEduBoardController(mAppContext)
            mBoardCallback = BoardCallback()
            mBoard!!.addCallback(mBoardCallback)
        }

//        //4. Recorder
//        if (mRecorder == null) {
//            mRecorder = TICRecorder(this)
//        }
        report(TICReporter.EventId.INIT_SDK_END)
        return 0
    }

    override val boardController: TEduBoardController?
        get(){
            if (mBoard == null) {
                TXCLog.e(TAG, "TICManager: getBoardController null, Do you call init?")
            }
            return mBoard
        }


    override fun switchRole(role: Int) {
        if (classroomOption!!.classScene == TICClassScene.TIC_CLASS_SCENE_LIVE
            && role == TICRoleType.TIC_ROLE_TYPE_ANCHOR
        ) {
            startSyncTimer()
        } else {
            stopSyncTimer()
        }
    }

    fun startSyncTimer() {
        TXCLog.i(TAG, "TICManager: startSyncTimer synctime: $mIsSendSyncTime")
        if (!mIsSendSyncTime) {
            mMainHandler?.postDelayed(MySyncTimeRunnable(this), 5000)
            mIsSendSyncTime = true
        }
    }

    fun stopSyncTimer() {
        mIsSendSyncTime = false
        TXCLog.i(TAG, "TICManager: stopSyncTimer synctime: $mIsSendSyncTime")
    }

    fun sendSyncTimeBySEI() {
        if (mBoard != null) {
            if (mIsSendSyncTime) {
                val time = mBoard!!.syncTime
                TXCLog.i(TAG, "TICManager: sendSyncTimeBySEI synctime: $time")
                if (time != 0L) {
                    var result = ""
                    val json = JSONObject()
                    try {
                        json.put(SYNCTIME, time)
                        result = json.toString()
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
//                    if (!TextUtils.isEmpty(result)) {
//                        mTrtcCloud!!.sendSEIMsg(result.toByteArray(), 1)
//                    }
                }
                mMainHandler?.postDelayed(MySyncTimeRunnable(this), 5000)
            }
        }
    }

    internal class MySyncTimeRunnable(ticManager: TICManagerImplM) : Runnable {
        var mTICManagerRef: WeakReference<TICManagerImplM>
        override fun run() {
            val ticManager = mTICManagerRef.get()
            ticManager?.sendSyncTimeBySEI()
        }

        init {
            mTICManagerRef = WeakReference(ticManager)
        }
    }

    override fun quitClassroom(clearBoard: Boolean,callback: TICCallback<Any>){
        TXCLog.i(TAG, "TICManager: quitClassroom $clearBoard")
        try {
            report(TICReporter.EventId.QUIT_GROUP_START)
            //2、如果clearBoard= true, 清除board中所有的历史数据，下次进来时看到的都是全新白板
            unitTEduBoard(clearBoard)
            //停止同步时间
            stopSyncTimer()
            //
            releaseClass()
            callback.onSuccess("")
        }catch (e:Exception){
            callback.onError(MODULE_IMSDK, -1, "退出教室出错:${e.message}")
        }
    }


    //Board进行初始化
    override fun initTEduBoard(option: TICClassroomOption) {
        classroomOption = option
        //生成一个继承于TEduBoardController.TEduBoardCallback事件监听，交给白板对象，用于处理白板事件响应。
        if (classroomOption != null) {
            if (classroomOption!!.boardCallback != null) {
                mBoard!!.addCallback(classroomOption!!.boardCallback)
            }
        }
        report(TICReporter.EventId.INIT_BOARD_START)
        //调用初始化函数
        val authParam = TEduBoardAuthParam(
            sdkAppId, userInfo.userId, userInfo.userSig
        )
        mBoard!!.init(authParam, classroomOption!!.classId, classroomOption!!.boardInitPara)
        startSyncTimer()
    }

    private fun unitTEduBoard(clearBoard: Boolean) {
        if (mBoard != null) {
            if (classroomOption != null && classroomOption!!.boardCallback != null) {
                mBoard!!.removeCallback(classroomOption!!.boardCallback)
            }
            if (clearBoard) {
                mBoard!!.reset()
            }
            report(TICReporter.EventId.UN_INIT_BOARD)
            mBoard!!.uninit()
        }
    }

    private fun releaseClass() {
        classroomOption = null
    }

    /////////////////
    override fun sendOfflineRecordInfo() {
        if (mRecorder != null && classroomOption != null) {
            val authParam = TEduBoardAuthParam(
                sdkAppId, userInfo.userId, userInfo.userSig
            )
            mRecorder!!.start(
                authParam,
                classroomOption!!.classId,
                classroomOption!!.ntpServer
            )
        } else {
            TXCLog.i(TAG, "TICManager: TRTC onEnterRoom: $mRecorder|$classroomOption")
        }
    }

    fun setUserInfo(userId: String?, userSig: String?) {
        userInfo.setUserInfo(userId!!, userSig!!)
    }

    fun trigleOffLineRecordCallback(code: Int, msg: String?) {

    }

    private var awareManager:BoardAwareInterface?=null
    override fun receiveData(awareManager: BoardAwareInterface) {
        this.awareManager=awareManager
    }

    fun sendCommand(extension: String, data: ByteArray) {
        awareManager?.sendMessage(data,extension)
    }

    //白板回调，用于监控事件
    internal class BoardCallback : TEduBoardCallback {
        override fun onTEBError(code: Int, msg: String) {
            report(TICReporter.EventId.ON_TEBERROR, code, msg)
        }

        override fun onTEBWarning(code: Int, msg: String) {
            report(TICReporter.EventId.ON_TEBWARNING, code, msg)
        }

        override fun onTEBInit() {
            report(TICReporter.EventId.INIT_BOARD_END)
        }

        override fun onTEBHistroyDataSyncCompleted() {
            report(TICReporter.EventId.SYNC_BOARD_HISTORY_END)
        }

        override fun onTEBSyncData(s: String) {}
        override fun onTEBUndoStatusChanged(b: Boolean) {}
        override fun onTEBRedoStatusChanged(b: Boolean) {}
        override fun onTEBImageStatusChanged(s: String, s1: String, i: Int) {}
        override fun onTEBSetBackgroundImage(s: String) {}
        override fun onTEBBackgroundH5StatusChanged(s: String, s1: String, i: Int) {}
        override fun onTEBAddBoard(list: List<String>, s: String) {}
        override fun onTEBDeleteBoard(list: List<String>, s: String) {}
        override fun onTEBGotoBoard(s: String, s1: String) {}
        override fun onTEBGotoStep(currentStep: Int, total: Int) {}
        override fun onTEBRectSelected() {}
        override fun onTEBRefresh() {}
        override fun onTEBSnapshot(path: String, code: Int, msg: String) {}
        override fun onTEBH5PPTStatusChanged(statusCode: Int, fid: String, describeMsg: String) {}
        override fun onTEBTextComponentStatusChange(
            status: String,
            id: String,
            value: String,
            left: Int,
            top: Int
        ) {
        }

        override fun onTEBAddTranscodeFile(s: String) {}
        override fun onTEBDeleteFile(s: String) {}
        override fun onTEBSwitchFile(s: String) {}
        override fun onTEBFileUploadProgress(s: String, i: Int, i1: Int, i2: Int, v: Float) {}
        override fun onTEBFileUploadStatus(s: String, i: Int, i1: Int, s1: String) {}
        override fun onTEBFileTranscodeProgress(
            s: String,
            s1: String,
            s2: String,
            tEduBoardTranscodeFileResult: TEduBoardTranscodeFileResult
        ) {
        }

        override fun onTEBH5FileStatusChanged(fileId: String, status: Int) {}
        override fun onTEBAddImagesFile(fileId: String) {}
        override fun onTEBVideoStatusChanged(
            fileId: String,
            status: Int,
            progress: Float,
            duration: Float
        ) {
        }

        override fun onTEBAudioStatusChanged(
            elementId: String,
            status: Int,
            progress: Float,
            duration: Float
        ) {
        }

        override fun onTEBAddImageElement(url: String) {}
        override fun onTEBAddElement(id: String, url: String) {}
        override fun onTEBDeleteElement(id: List<String>) {}
    }

    companion object {
        private const val TAG = "TICManager"
        private const val SYNCTIME = "syncTime"
        private const val COMPAT_SAAS_CHAT = "_chat"
        private val SYNC = ByteArray(1)

        /////////////////////////////////////////////////////////////////////////////////
        //
        //                      （一）初始和终止接口函数
        //
        /////////////////////////////////////////////////////////////////////////////////
        @Volatile
        private var instance: TICManager? = null
        @JvmStatic
        fun sharedInstance(): TICManager {
            if (instance == null) {
                synchronized(SYNC) {
                    if (instance == null) {
                        instance = com.tencent.tic.core.impl.TICManagerImplM()
                    }
                }
            }
            return instance!!
        }
    }

    init {
        TXCLog.i(TAG, "TICManager: constructor ")
    }
}