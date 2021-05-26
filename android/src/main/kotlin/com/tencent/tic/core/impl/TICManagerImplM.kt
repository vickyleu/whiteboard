package com.tencent.tic.core.impl

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.bond.whiteboard.teb.BoardAwareInterface
import com.tencent.liteav.basic.log.TXCLog
import com.tencent.teduboard.TEduBoardController
import com.tencent.teduboard.TEduBoardController.*
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

//    override fun createClassroom(classId: Int, scene: Int, callback: TICCallback<Any>?) {
//        TXCLog.i(
//            TAG,
//            "TICManager: createClassroom classId:$classId scene:$scene callback:$callback"
//        )
//        report(TICReporter.EventId.CREATE_GROUP_START)
//        // 为了减少用户操作成本（收到群进出等通知需要配置工单才生效）群组类型由ChatRoom改为Public
//        val groupId = classId.toString()
//        val groupName = "interact group"
//        val groupType = if (scene == TICClassScene.TIC_CLASS_SCENE_LIVE) "AVChatRoom" else "Public"
//        val param = CreateGroupParam(groupType, groupName)
//        param.groupId = groupId
//        param.addOption = TIMGroupAddOpt.TIM_GROUP_ADD_ANY //
//        TIMGroupManager.getInstance().createGroup(param, object : TIMValueCallBack<String> {
//            override fun onSuccess(s: String) {
//                TXCLog.i(TAG, "TICManager: createClassroom onSuccess:$classId msg:$s")
//                report(TICReporter.EventId.CREATE_GROUP_END)
//                callback?.onSuccess(classId)
//            }
//
//            override fun onError(errCode: Int, errMsg: String) {
//                if (null != callback) {
//                    if (errCode == 10025) { // 群组ID已被使用，并且操作者为群主，可以直接使用。
//                        TXCLog.i(TAG, "TICManager: createClassroom 10025 onSuccess:$classId")
//                        callback.onSuccess(classId)
//                    } else {
//                        TXCLog.i(TAG, "TICManager: createClassroom onError:$errCode msg:$errMsg")
//                        report(TICReporter.EventId.CREATE_GROUP_END, errCode, errMsg)
//                        callback.onError(MODULE_IMSDK, errCode, errMsg)
//                    }
//                }
//            }
//        })
//    }
//
//    override fun destroyClassroom(classId: Int, callback: TICCallback<Any>?) {
//        TXCLog.i(TAG, "TICManager: destroyClassroom classId:$classId callback:$callback")
//        report(TICReporter.EventId.DELETE_GROUP_START)
//        val groupId = classId.toString()
//        TIMGroupManager.getInstance().deleteGroup(groupId, object : TIMCallBack {
//            override fun onError(errorCode: Int, errInfo: String) {
//                TXCLog.i(TAG, "TICManager: destroyClassroom onError:$errorCode msg:$errInfo")
//                report(TICReporter.EventId.DELETE_GROUP_END, errorCode, errInfo)
//                notifyError(callback, MODULE_IMSDK, errorCode, errInfo)
//            }
//
//            override fun onSuccess() {
//                report(TICReporter.EventId.DELETE_GROUP_END)
//                TXCLog.i(TAG, "TICManager: destroyClassroom onSuccess")
//            }
//        })
//    }

//    override fun joinClassroom(option: TICClassroomOption?, callback: TICCallback<Any>?) {
//        if (option == null || option.classId < 0) {
//            TXCLog.i(TAG, "TICManager: joinClassroom Para Error")
//            notifyError(
//                callback,
//                MODULE_TIC_SDK,
//                Error.ERR_INVALID_PARAMS,
//                Error.ERR_MSG_INVALID_PARAMS
//            )
//            return
//        }
//        TXCLog.i(TAG, "TICManager: joinClassroom classId:$option callback:$callback")
//        classroomOption = option
//        val classId = classroomOption!!.classId
//        var groupId = classId.toString()
//        val desc = "board group"
//
//        TIMGroupManager.getInstance().applyJoinGroup(groupId, desc + groupId, object : TIMCallBack {
//            override fun onSuccess() {
//                TXCLog.i(TAG, "TICManager: joinClassroom onSuccess ")
//                report(TICReporter.EventId.JOIN_GROUP_END)
//                onJoinClassroomSuccessfully(callback)
//            }
//
//            override fun onError(errCode: Int, errMsg: String) {
//                if (callback != null) {
//                    if (errCode == 10013) { //you are already group member.
//                        TXCLog.i(TAG, "TICManager: joinClassroom 10013 onSuccess")
//                        report(TICReporter.EventId.JOIN_GROUP_END)
//                        onJoinClassroomSuccessfully(callback)
//                    } else {
//                        TXCLog.i(TAG, "TICManager: joinClassroom onError:$errCode|$errMsg")
//                        report(TICReporter.EventId.JOIN_GROUP_END, errCode, errMsg)
//                        callback.onError(MODULE_IMSDK, errCode, errMsg)
//                    }
//                }
//            }
//        })
////        if (classroomOption!!.compatSaas) {
////            groupId += COMPAT_SAAS_CHAT
////            TIMGroupManager.getInstance()
////                .applyJoinGroup(groupId, desc + groupId, object : TIMCallBack {
////                    override fun onSuccess() {
////                        TXCLog.i(TAG, "TICManager: joinClassroom compatSaas onSuccess ")
////                    }
////
////                    override fun onError(errCode: Int, errMsg: String) {
////                        if (callback != null) {
////                            if (errCode == 10013) { //you are already group member.
////                                TXCLog.i(
////                                    TAG,
////                                    "TICManager: joinClassroom compatSaas 10013 onSuccess"
////                                )
////                            } else {
////                                TXCLog.i(
////                                    TAG,
////                                    "TICManager: joinClassroom compatSaas onError:$errCode|$errMsg"
////                                )
////                            }
////                        }
////                    }
////                })
////        }
//    }
//
//    override fun quitClassroom(clearBoard: Boolean, callback: TICCallback<Any>?) {
//        TXCLog.i(TAG, "TICManager: quitClassroom $clearBoard|$callback")
//        if (classroomOption == null) {
//            TXCLog.e(TAG, "TICManager: quitClassroom para Error.")
//            notifyError(
//                callback,
//                MODULE_TIC_SDK,
//                Error.ERR_NOT_IN_CLASS,
//                Error.ERR_MSG_NOT_IN_CLASS
//            )
//            return
//        }
//        report(TICReporter.EventId.QUIT_GROUP_START)
//        //2、如果clearBoard= true, 清除board中所有的历史数据，下次进来时看到的都是全新白板
//        unitTEduBoard(clearBoard)
//        //3、im退房间
//        val classId = classroomOption!!.classId
//        var groupId = classId.toString()
////        TIMGroupManager.getInstance().quitGroup(groupId, object : TIMCallBack {
////            //NOTE:在被挤下线时，不会回调
////            override fun onError(errorCode: Int, errInfo: String) {
////                TXCLog.e(TAG, "TICManager: quitClassroom onError, err:$errorCode msg:$errInfo")
////                report(TICReporter.EventId.QUIT_GROUP_END, errorCode, errInfo)
////                if (callback != null) {
////                    if (errorCode == 10009) {
////                        callback.onSuccess(0)
////                    } else {
////                        callback.onError(MODULE_IMSDK, errorCode, errInfo)
////                    }
////                }
////            }
////
////            override fun onSuccess() {
////                TXCLog.e(TAG, "TICManager: quitClassroom onSuccess")
////                report(TICReporter.EventId.QUIT_GROUP_END)
////                notifySuccess(callback, 0)
////            }
////        })
////        if (classroomOption!!.compatSaas) {
////            groupId += COMPAT_SAAS_CHAT
////            TIMGroupManager.getInstance().quitGroup(groupId, object : TIMCallBack {
////                //NOTE:在被挤下线时，不会回调
////                override fun onError(errorCode: Int, errInfo: String) {
////                    TXCLog.e(
////                        TAG,
////                        "TICManager: quitClassroom compatSaas, err:$errorCode msg:$errInfo"
////                    )
////                }
////
////                override fun onSuccess() {
////                    TXCLog.e(TAG, "TICManager: quitClassroom onSuccess compatSaas")
////                }
////            })
////        }
//
//        //停止同步时间
//        stopSyncTimer()
//        //
//        releaseClass()
//    }


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