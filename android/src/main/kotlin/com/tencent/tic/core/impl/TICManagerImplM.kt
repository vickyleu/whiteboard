package com.tencent.tic.core.impl

import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import com.tencent.imsdk.*
import com.tencent.imsdk.TIMGroupManager.CreateGroupParam
import com.tencent.liteav.basic.log.TXCLog
import com.tencent.teduboard.TEduBoardController
import com.tencent.teduboard.TEduBoardController.*
import com.tencent.tic.core.TICCallback
import com.tencent.tic.core.TICClassroomOption
import com.tencent.tic.core.TICManager
import com.tencent.tic.core.impl.TICReporter.report
import com.tencent.tic.core.impl.TICReporter.updateAppId
import com.tencent.tic.core.impl.TICReporter.updateRoomId
import com.tencent.tic.core.impl.TICReporter.updateUserId
import com.tencent.tic.core.impl.observer.TICEventObservable
import com.tencent.tic.core.impl.observer.TICIMStatusObservableM
import com.tencent.tic.core.impl.observer.TICMessageObservableM
import com.tencent.tic.core.impl.utils.CallbackUtilM.notifyError
import com.tencent.tic.core.impl.utils.CallbackUtilM.notifySuccess
import com.tencent.trtc.TRTCCloud
import com.tencent.trtc.TRTCCloudDef.*
import com.tencent.trtc.TRTCCloudListener
import com.tencent.trtc.TRTCStatistics
import org.json.JSONObject
import java.lang.ref.WeakReference
import java.util.*

class TICManagerImplM private constructor() : TICManager() {
    var mEnterRoomCallback // 进房callback
            : TICCallback<Any>? = null
    private val mMainHandler: Handler
    var mIsSendSyncTime = false //
    var mDisableModule = TICDisableModule.TIC_DISABLE_MODULE_NONE

    //TRTC
    private var mTrtcCloud /// TRTC SDK 实例对象
            : TRTCCloud? = null
    private var mTrtcListener /// TRTC SDK 回调监听
            : TRTCCloudListener? = null

    //IM
    private var mTIMListener: TIMMessageListener? = null
    private var mGroupEventListener: TIMGroupEventListener? = null

    //Board
    private var mBoard: TEduBoardController? = null
    private var mBoardCallback: BoardCallback? = null

    //Recorder
    private var mRecorder: TICRecorder? = null
    private var mAppContext: Context? = null
    private var sdkAppId = 0
    private val userInfo: UserInfo
    private var classroomOption: TICClassroomOption? = null
    private val mEventListner: TICEventObservable
    private val mStatusListner: TICIMStatusObservableM
    private val mMessageListner: TICMessageObservableM
    override fun init(context: Context, appId: Int): Int {
        return init(context, appId, mDisableModule)
    }

    override fun init(context: Context, appId: Int, disableModule: Int): Int {
        TXCLog.i(TAG, "TICManager: init, context:$context appid:$appId")
        updateAppId(appId)
        report(TICReporter.EventId.INIT_SDK_START)

        //0、给值
        sdkAppId = appId
        mAppContext = context.applicationContext

        //1、 TIM SDK初始化
        val timSdkConfig = TIMSdkConfig(appId)
            .enableLogPrint(true)
            .setLogLevel(TIMLogLevel.DEBUG) //TODO::在正式发布时，设置TIMLogLevel.OFF
        TIMManager.getInstance().init(context, timSdkConfig)
        mGroupEventListener =
            TIMGroupEventListener { timGroupTipsElem -> handleGroupTipsMessage(timGroupTipsElem) }
        mTIMListener = TIMMessageListener { list -> handleNewMessages(list) }

        //2. TRTC SDK初始化
        if (disableModule and TICDisableModule.TIC_DISABLE_MODULE_TRTC == 0) {
            if (mTrtcCloud == null) {
                mTrtcListener = TRTCCloudListenerImpl()
                mTrtcCloud = TRTCCloud.sharedInstance(mAppContext)
                mTrtcCloud?.setListener(mTrtcListener)
            }
        }

        //3. TEdu Board
        if (mBoard == null) {
            mBoard = TEduBoardController(mAppContext)
            mBoardCallback = BoardCallback()
            mBoard!!.addCallback(mBoardCallback)
        }

        //4. Recorder
        if (mRecorder == null) {
            mRecorder = TICRecorder(this)
        }
        report(TICReporter.EventId.INIT_SDK_END)
        return 0
    }


    override fun unInit(): Int {
        TXCLog.i(TAG, "TICManager: unInit")

        //1、销毁trtc
        if (mTrtcCloud != null) {
            //TRTCCloud.destroySharedInstance();
            mTrtcCloud = null
        }
        return 0
    }

    override val tRTCClound: TRTCCloud?
        get() {
            if (mTrtcCloud == null) {
                TXCLog.e(TAG, "TICManager: getTRTCClound null, Do you call init?")
            }
            return mTrtcCloud
        }

    override val boardController: TEduBoardController?
        get(){
            if (mBoard == null) {
                TXCLog.e(TAG, "TICManager: getBoardController null, Do you call init?")
            }
            return mBoard
        }


    override fun switchRole(role: Int) {
        if (mTrtcCloud != null) {
            mTrtcCloud!!.switchRole(role)
        }
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
            mMainHandler.postDelayed(MySyncTimeRunnable(this), 5000)
            mIsSendSyncTime = true
        }
    }

    fun stopSyncTimer() {
        mIsSendSyncTime = false
        TXCLog.i(TAG, "TICManager: stopSyncTimer synctime: $mIsSendSyncTime")
    }

    fun sendSyncTimeBySEI() {
        if (mTrtcCloud != null && mBoard != null) {
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
                    if (!TextUtils.isEmpty(result)) {
                        mTrtcCloud!!.sendSEIMsg(result.toByteArray(), 1)
                    }
                }
                mMainHandler.postDelayed(MySyncTimeRunnable(this), 5000)
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

    override fun addEventListener(callback: TICEventListener) {
        TXCLog.i(TAG, "TICManager: addEventListener:$callback")
        mEventListner.addObserver(callback)
    }

    override fun removeEventListener(callback: TICEventListener) {
        TXCLog.i(TAG, "TICManager: removeEventListener:$callback")
        mEventListner.removeObserver(callback)
    }

    override fun addIMStatusListener(callback: TICIMStatusListener) {
        TXCLog.i(TAG, "TICManager: addIMStatusListener:$callback")
        mStatusListner.addObserver(callback)
    }

    override fun removeIMStatusListener(callback: TICIMStatusListener) {
        TXCLog.i(TAG, "TICManager: removeIMStatusListener:$callback")
        mStatusListner.removeObserver(callback)
    }

    override fun addIMMessageListener(callback: TICMessageListener) {
        TXCLog.i(TAG, "TICManager: addIMMessageListener:$callback")
        mMessageListner.addObserver(callback)
    }

    override fun removeIMMessageListener(callback: TICMessageListener) {
        TXCLog.i(TAG, "TICManager: removeIMMessageListener:$callback")
        mMessageListner.removeObserver(callback)
    }

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      （二）TIC登录/登出/创建销毁课堂/进入退出课堂接口函数
    //
    /////////////////////////////////////////////////////////////////////////////////

    override fun login(userId: String, userSig: String, callBack: TICCallback<Any>?) {
        TXCLog.i(TAG, "TICManager: login userid:$userId sig:$userSig")
        updateRoomId(0)
        updateUserId(userId)
        report(TICReporter.EventId.LOGIN_START)
        // IM 登陆
        setUserInfo(userId, userSig)
        TIMManager.getInstance().login(userId, userSig, object : TIMCallBack {
            override fun onSuccess() {
                TXCLog.i(TAG, "TICManager: login onSuccess:$userId")
                report(TICReporter.EventId.LOGIN_END)
                //成功登录后，加入消息和状态监听
                TIMManager.getInstance().userConfig.userStatusListener = mStatusListner
                TIMManager.getInstance().addMessageListener(mTIMListener)
                TIMManager.getInstance().userConfig.groupEventListener = mGroupEventListener
                callBack?.onSuccess("")
            }

            override fun onError(errCode: Int, errMsg: String) {
                TXCLog.i(TAG, "TICManager: login onError:$errCode msg:$errMsg")
                report(TICReporter.EventId.LOGIN_END, errCode, errMsg)
                callBack?.onError(MODULE_IMSDK, errCode, "login failed: $errMsg")
            }
        })
    }

    override fun logout(callback: TICCallback<Any>?) {
        TXCLog.i(TAG, "TICManager: logout callback:$callback")
        report(TICReporter.EventId.LOGOUT_START)
        TIMManager.getInstance().logout(object : TIMCallBack {
            override fun onSuccess() {
                TXCLog.i(TAG, "TICManager: logout onSuccess")
                report(TICReporter.EventId.LOGOUT_END)
                callback?.onSuccess("")
            }

            override fun onError(errCode: Int, errMsg: String) {
                TXCLog.i(TAG, "TICManager: logout onError:$errCode msg:$errMsg")
                report(TICReporter.EventId.LOGOUT_END, errCode, errMsg)
                callback?.onError(MODULE_IMSDK, errCode, "logout failed: $errMsg")
            }
        })

        //退出登录后，去掉消息的监听
        TIMManager.getInstance().removeMessageListener(mTIMListener)
        TIMManager.getInstance().userConfig.userStatusListener = null
        TIMManager.getInstance().userConfig.groupEventListener = null
    }

    override fun createClassroom(classId: Int, scene: Int, callback: TICCallback<Any>?) {
        TXCLog.i(
            TAG,
            "TICManager: createClassroom classId:$classId scene:$scene callback:$callback"
        )
        report(TICReporter.EventId.CREATE_GROUP_START)
        // 为了减少用户操作成本（收到群进出等通知需要配置工单才生效）群组类型由ChatRoom改为Public
        val groupId = classId.toString()
        val groupName = "interact group"
        val groupType = if (scene == TICClassScene.TIC_CLASS_SCENE_LIVE) "AVChatRoom" else "Public"
        val param = CreateGroupParam(groupType, groupName)
        param.groupId = groupId
        param.addOption = TIMGroupAddOpt.TIM_GROUP_ADD_ANY //
        TIMGroupManager.getInstance().createGroup(param, object : TIMValueCallBack<String> {
            override fun onSuccess(s: String) {
                TXCLog.i(TAG, "TICManager: createClassroom onSuccess:$classId msg:$s")
                report(TICReporter.EventId.CREATE_GROUP_END)
                callback?.onSuccess(classId)
            }

            override fun onError(errCode: Int, errMsg: String) {
                if (null != callback) {
                    if (errCode == 10025) { // 群组ID已被使用，并且操作者为群主，可以直接使用。
                        TXCLog.i(TAG, "TICManager: createClassroom 10025 onSuccess:$classId")
                        callback.onSuccess(classId)
                    } else {
                        TXCLog.i(TAG, "TICManager: createClassroom onError:$errCode msg:$errMsg")
                        report(TICReporter.EventId.CREATE_GROUP_END, errCode, errMsg)
                        callback.onError(MODULE_IMSDK, errCode, errMsg)
                    }
                }
            }
        })
    }

    override fun destroyClassroom(classId: Int, callback: TICCallback<Any>?) {
        TXCLog.i(TAG, "TICManager: destroyClassroom classId:$classId callback:$callback")
        report(TICReporter.EventId.DELETE_GROUP_START)
        val groupId = classId.toString()
        TIMGroupManager.getInstance().deleteGroup(groupId, object : TIMCallBack {
            override fun onError(errorCode: Int, errInfo: String) {
                TXCLog.i(TAG, "TICManager: destroyClassroom onError:$errorCode msg:$errInfo")
                report(TICReporter.EventId.DELETE_GROUP_END, errorCode, errInfo)
                notifyError(callback, MODULE_IMSDK, errorCode, errInfo)
            }

            override fun onSuccess() {
                report(TICReporter.EventId.DELETE_GROUP_END)
                TXCLog.i(TAG, "TICManager: destroyClassroom onSuccess")
            }
        })
    }

    override fun joinClassroom(option: TICClassroomOption?, callback: TICCallback<Any>?) {
        if (option == null || option.classId < 0) {
            TXCLog.i(TAG, "TICManager: joinClassroom Para Error")
            notifyError(
                callback,
                MODULE_TIC_SDK,
                Error.ERR_INVALID_PARAMS,
                Error.ERR_MSG_INVALID_PARAMS
            )
            return
        }
        TXCLog.i(TAG, "TICManager: joinClassroom classId:$option callback:$callback")
        classroomOption = option
        val classId = classroomOption!!.classId
        var groupId = classId.toString()
        val desc = "board group"
        updateRoomId(classId)
        report(TICReporter.EventId.JOIN_GROUP_START)
        TIMGroupManager.getInstance().applyJoinGroup(groupId, desc + groupId, object : TIMCallBack {
            override fun onSuccess() {
                TXCLog.i(TAG, "TICManager: joinClassroom onSuccess ")
                report(TICReporter.EventId.JOIN_GROUP_END)
                onJoinClassroomSuccessfully(callback)
            }

            override fun onError(errCode: Int, errMsg: String) {
                if (callback != null) {
                    if (errCode == 10013) { //you are already group member.
                        TXCLog.i(TAG, "TICManager: joinClassroom 10013 onSuccess")
                        report(TICReporter.EventId.JOIN_GROUP_END)
                        onJoinClassroomSuccessfully(callback)
                    } else {
                        TXCLog.i(TAG, "TICManager: joinClassroom onError:$errCode|$errMsg")
                        report(TICReporter.EventId.JOIN_GROUP_END, errCode, errMsg)
                        callback.onError(MODULE_IMSDK, errCode, errMsg)
                    }
                }
            }
        })
        if (classroomOption!!.compatSaas) {
            groupId += COMPAT_SAAS_CHAT
            TIMGroupManager.getInstance()
                .applyJoinGroup(groupId, desc + groupId, object : TIMCallBack {
                    override fun onSuccess() {
                        TXCLog.i(TAG, "TICManager: joinClassroom compatSaas onSuccess ")
                    }

                    override fun onError(errCode: Int, errMsg: String) {
                        if (callback != null) {
                            if (errCode == 10013) { //you are already group member.
                                TXCLog.i(
                                    TAG,
                                    "TICManager: joinClassroom compatSaas 10013 onSuccess"
                                )
                            } else {
                                TXCLog.i(
                                    TAG,
                                    "TICManager: joinClassroom compatSaas onError:$errCode|$errMsg"
                                )
                            }
                        }
                    }
                })
        }
    }

    override fun quitClassroom(clearBoard: Boolean, callback: TICCallback<Any>?) {
        TXCLog.i(TAG, "TICManager: quitClassroom $clearBoard|$callback")
        if (classroomOption == null) {
            TXCLog.e(TAG, "TICManager: quitClassroom para Error.")
            notifyError(
                callback,
                MODULE_TIC_SDK,
                Error.ERR_NOT_IN_CLASS,
                Error.ERR_MSG_NOT_IN_CLASS
            )
            return
        }
        report(TICReporter.EventId.QUIT_GROUP_START)
        //1.trtc退房间
        if (mTrtcCloud != null) {
            mTrtcCloud!!.exitRoom()
        }

        //2、如果clearBoard= true, 清除board中所有的历史数据，下次进来时看到的都是全新白板
        unitTEduBoard(clearBoard)

        //3、im退房间
        val classId = classroomOption!!.classId
        var groupId = classId.toString()
        TIMGroupManager.getInstance().quitGroup(groupId, object : TIMCallBack {
            //NOTE:在被挤下线时，不会回调
            override fun onError(errorCode: Int, errInfo: String) {
                TXCLog.e(TAG, "TICManager: quitClassroom onError, err:$errorCode msg:$errInfo")
                report(TICReporter.EventId.QUIT_GROUP_END, errorCode, errInfo)
                if (callback != null) {
                    if (errorCode == 10009) {
                        callback.onSuccess(0)
                    } else {
                        callback.onError(MODULE_IMSDK, errorCode, errInfo)
                    }
                }
            }

            override fun onSuccess() {
                TXCLog.e(TAG, "TICManager: quitClassroom onSuccess")
                report(TICReporter.EventId.QUIT_GROUP_END)
                notifySuccess(callback, 0)
            }
        })
        if (classroomOption!!.compatSaas) {
            groupId += COMPAT_SAAS_CHAT
            TIMGroupManager.getInstance().quitGroup(groupId, object : TIMCallBack {
                //NOTE:在被挤下线时，不会回调
                override fun onError(errorCode: Int, errInfo: String) {
                    TXCLog.e(
                        TAG,
                        "TICManager: quitClassroom compatSaas, err:$errorCode msg:$errInfo"
                    )
                }

                override fun onSuccess() {
                    TXCLog.e(TAG, "TICManager: quitClassroom onSuccess compatSaas")
                }
            })
        }

        //停止同步时间
        stopSyncTimer()

        //
        releaseClass()
    }

    private fun onJoinClassroomSuccessfully(callback: TICCallback<Any>?) {
        if (classroomOption == null || classroomOption!!.classId < 0) {
            notifyError(
                callback,
                MODULE_TIC_SDK,
                Error.ERR_INVALID_PARAMS,
                Error.ERR_MSG_INVALID_PARAMS
            )
            return
        }

        //TRTC进房
        mEnterRoomCallback = callback
        if (mTrtcCloud != null) {
            report(TICReporter.EventId.ENTER_ROOM_START)
            val trtcParams = TRTCParams(
                sdkAppId, userInfo.userId, userInfo.userSig, classroomOption!!.classId, "", ""
            ) /// TRTC SDK 视频通话房间进入所必须的参数
            if (classroomOption!!.classScene == TICClassScene.TIC_CLASS_SCENE_LIVE) {
                trtcParams.role = classroomOption!!.roleType
            }
            mTrtcCloud!!.enterRoom(trtcParams, classroomOption!!.classScene)
        } else if (mDisableModule and TICDisableModule.TIC_DISABLE_MODULE_TRTC == 0) { //TRTC不需要进入房间.
            if (mEnterRoomCallback != null) {
                mEnterRoomCallback!!.onSuccess("succ")
            }
        }

        //Board进行初始化
        initTEduBoard()
    }

    private fun initTEduBoard() {
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

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      （五) IM消息
    //
    /////////////////////////////////////////////////////////////////////////////////

    override fun sendTextMessage(userId: String,text: String,callBack: TICCallback<TIMMessage>?) {
        TXCLog.i(TAG, "TICManager: sendTextMessage user:$userId text:$text")
        val message = TIMMessage()
        val elem = TIMTextElem()
        elem.text = text
        message.addElement(elem)
        sendMessage(userId, message, callBack)
    }

    override fun sendCustomMessage(userId: String,data: ByteArray,callBack: TICCallback<TIMMessage>?) {
        TXCLog.i(TAG, "TICManager: sendCustomMessage user:" + userId + " data:" + data.size)
        val message = TIMMessage()
        val customElem = TIMCustomElem()
        customElem.data = data
        message.addElement(customElem)
        sendMessage(userId, message, callBack)
    }

    override fun sendMessage(userId: String,message: TIMMessage,callBack: TICCallback<TIMMessage>?) {
        TXCLog.i(TAG, "TICManager: sendMessage user:$userId message:$message")
        if (classroomOption == null || classroomOption!!.classId == -1) {
            TXCLog.e(TAG, "TICManager: sendMessage: " + Error.ERR_MSG_NOT_IN_CLASS)
            notifyError(callBack, MODULE_IMSDK, Error.ERR_NOT_IN_CLASS, Error.ERR_MSG_NOT_IN_CLASS)
            return
        }
        val conversation: TIMConversation
        conversation = if (TextUtils.isEmpty(userId)) {
            TIMManager.getInstance().getConversation(
                TIMConversationType.Group, classroomOption!!.classId.toString()
            )
        } else {
            TIMManager.getInstance().getConversation(TIMConversationType.C2C, userId)
        }
        conversation.sendMessage(message, object : TIMValueCallBack<TIMMessage?> {
            override fun onError(errCode: Int, errMsg: String) {
                TXCLog.e(TAG, "TICManager: sendMessage onError:$errCode errMsg:$errMsg")
                notifyError(callBack, MODULE_IMSDK, errCode, "send im message failed: $errMsg")
            }

            override fun onSuccess(timMessage: TIMMessage?) {
                TXCLog.e(TAG, "TICManager: sendMessage onSuccess:")
                if(timMessage!=null){
                    notifySuccess(callBack, timMessage)
                }else{
                    notifyError(callBack, MODULE_IMSDK, -1, "message entity is null")
                }
            }
        })
    }

    override fun sendGroupTextMessage(text: String, callBack: TICCallback<Any>?) {
        val message = TIMMessage()
        val elem = TIMTextElem()
        elem.text = text
        message.addElement(elem)
        sendGroupMessage(message, callBack)
    }

    override fun sendGroupCustomMessage(data: ByteArray, callBack: TICCallback<Any>?) {
        sendGroupCustomMessage("", data, callBack)
    }

    fun sendGroupCustomMessage(ext: String, data: ByteArray, callBack: TICCallback<Any>?) {
        val message = TIMMessage()
        val customElem = TIMCustomElem()
        customElem.data = data
        if (!TextUtils.isEmpty(ext)) {
            customElem.ext = ext.toByteArray()
        }
        message.addElement(customElem)
        sendGroupMessage(message, callBack)
    }

    override fun sendGroupMessage(message: TIMMessage, callBack: TICCallback<Any>?) {
        if (classroomOption == null || classroomOption!!.classId == -1) {
            TXCLog.e(TAG, "TICManager: sendGroupMessage: " + Error.ERR_MSG_NOT_IN_CLASS)
            notifyError(callBack, MODULE_IMSDK, Error.ERR_NOT_IN_CLASS, Error.ERR_MSG_NOT_IN_CLASS)
            return
        }
        var groupId = classroomOption!!.classId.toString()
        if (classroomOption!!.compatSaas) {
            groupId += COMPAT_SAAS_CHAT
        }
        TXCLog.i(TAG, "TICManager: sendGroupMessage groupId:$groupId")
        val conversation =
            TIMManager.getInstance().getConversation(TIMConversationType.Group, groupId)
        conversation.sendMessage(message, object : TIMValueCallBack<TIMMessage?> {
            override fun onError(errCode: Int, errMsg: String) {
                TXCLog.e(TAG, "TICManager: sendGroupMessage onError:$errCode errMsg:$errMsg")
                notifyError(callBack, MODULE_IMSDK, errCode, "send im message failed: $errMsg")
            }

            override fun onSuccess(timMessage: TIMMessage?) {
                TXCLog.e(TAG, "TICManager: sendGroupMessage onSuccess:")
                if(timMessage!=null){
                    notifySuccess(callBack, timMessage)
                }else{
                    notifyError(callBack, MODULE_IMSDK, -1, "message entity is null")
                }
            }
        })
    }

    private fun handleNewMessages(list: List<TIMMessage>): Boolean {
        if (classroomOption == null) {
            TXCLog.e(TAG, "TICManager: handleNewMessages: not in class now.")
            return false
        }
        for (message in list) {
            TXCLog.i(TAG, "TICManager: handleNewMessages -->:$message")
            var ext = ""
            if (message.offlinePushSettings != null) {
                ext = String(message.offlinePushSettings.ext)
            }
            if (!TextUtils.isEmpty(ext) && ext == TICSDK_WHITEBOARD_CMD) {
                // 白板消息和录制对时消息过滤掉
            } else {
                val type = message.conversation.type
                if (type == TIMConversationType.C2C || type == TIMConversationType.Group) {
                    // 私聊消息
                    if (type == TIMConversationType.Group) { //过滤其他群组的消息
                        var classId = classroomOption!!.classId.toString()
                        val groupId = message.conversation.peer
                        if (classroomOption!!.compatSaas) {
                            classId += COMPAT_SAAS_CHAT
                        }
                        if (TextUtils.isEmpty(groupId) || groupId != classId) {
                            continue
                        }
                    }
                    handleChatMessage(message)
                } else if (type == TIMConversationType.System) {
                    handleGroupSystemMessage(message)
                }
                mMessageListner.onTICRecvMessage(message)
            }
        }
        return false
    }

    private fun handleGroupTipsMessage(timGroupTipsElem: TIMGroupTipsElem) {
        onGroupTipMessageReceived(timGroupTipsElem)
    }

    private fun handleGroupSystemMessage(message: TIMMessage) {
        if (classroomOption == null) {
            TXCLog.e(TAG, "TICManager: handleGroupSystemMessage: not in class now.")
            return
        }
        for (i in 0 until message.elementCount) {
            val elem = message.getElement(i)
            when (elem.type) {
                TIMElemType.GroupSystem -> {
                    val systemElem = elem as TIMGroupSystemElem
                    val groupId = systemElem.groupId
                    if (groupId != classroomOption!!.classId.toString()) {
                        TXCLog.e(TAG, "TICManager:handleGroupSystemMessage-> not in current group")
                        continue
                    }
                    val subtype = systemElem.subtype
                    if (subtype == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE
                        ||
                        subtype == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_REVOKE_GROUP_TYPE
                    ) {
                        quitClassroom(false, null)
                        mEventListner.onTICClassroomDestroy()
                    } else if (subtype == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_KICK_OFF_FROM_GROUP_TYPE) {
                        TXCLog.e(
                            TAG,
                            "TICManager: handleGroupSystemMessage TIM_GROUP_SYSTEM_KICK_OFF_FROM_GROUP_TYPE: "
                                    + groupId + "| " + systemElem.opReason
                        )
                        quitClassroom(false, null)
                        mEventListner.onTICMemberQuit(listOf(TIMManager.getInstance().loginUser))
                    }
                }
                else -> TXCLog.e(
                    TAG,
                    "TICManager: handleGroupSystemMessage: elemtype : " + elem.type
                )
            }
        }
    }

    private fun handleChatMessage(message: TIMMessage) {
        if (classroomOption == null) {
            TXCLog.e(TAG, "TICManager: onChatMessageReceived: not in class now.")
            return
        }
        for (i in 0 until message.elementCount) {
            val elem = message.getElement(i)
            when (elem.type) {
                TIMElemType.Text, TIMElemType.Custom -> onChatMessageReceived(message, elem)
                TIMElemType.GroupTips -> continue
                else -> {
                }
            }
        }
    }

    private fun onGroupTipMessageReceived(tipsElem: TIMGroupTipsElem) {
        if (classroomOption == null) {
            TXCLog.e(TAG, "TICManager: onGroupTipMessageReceived: not in class now.")
            return
        }
        val tipsType = tipsElem.tipsType
        val groupId = tipsElem.groupId
        if (groupId != classroomOption!!.classId.toString()) {
            TXCLog.e(TAG, "TICManager: onGroupTipMessageReceived-> not in current group")
            return
        }
        if (tipsType == TIMGroupTipsType.Join) {
            mEventListner.onTICMemberJoin(tipsElem.userList)
        } else if (tipsType == TIMGroupTipsType.Quit || tipsType == TIMGroupTipsType.Kick) {
            if (tipsElem.userList.size <= 0) {
                mEventListner.onTICMemberQuit(listOf(tipsElem.opUser))
            } else {
                mEventListner.onTICMemberQuit(tipsElem.userList)
            }
        }
    }

    // TODO: 2018/11/30 parse chat  message
    private fun onChatMessageReceived(message: TIMMessage, elem: TIMElem) {
        if (classroomOption == null) {
            TXCLog.e(TAG, "TICManager: onChatMessageReceived: not in class now.")
            return
        }
        when (message.conversation.type) {
            TIMConversationType.C2C -> if (elem.type == TIMElemType.Text) {
                mMessageListner.onTICRecvTextMessage(message.sender, (elem as TIMTextElem).text)
            } else if (elem.type == TIMElemType.Custom) {
                mMessageListner.onTICRecvCustomMessage(message.sender, (elem as TIMCustomElem).data)
            }
            TIMConversationType.Group ->                 // 群组义消息
                if (elem.type == TIMElemType.Text) {
                    mMessageListner.onTICRecvGroupTextMessage(
                        message.sender,
                        (elem as TIMTextElem).text
                    )
                } else if (elem.type == TIMElemType.Custom) {
                    var ext = ""
                    val customElem = elem as TIMCustomElem
                    if (customElem.ext != null) {
                        ext = String(customElem.ext)
                    }
                    if (!TextUtils.isEmpty(ext) && (ext == TICSDK_WHITEBOARD_CMD || ext == TICRecorder.TICSDK_CONFERENCE_CMD)) {
                        // 白板消息和对时消息过掉
//                        decodeBoardMsg(message.getSender(), customElem.getData());
                    } else {
                        mMessageListner.onTICRecvGroupCustomMessage(message.sender, customElem.data)
                    }
                }
            else -> TXCLog.e(
                TAG, "TICManager: onChatMessageReceived-> message type: "
                        + message.conversation.type
            )
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      （五）TRTC SDK内部状态回调
    //
    /////////////////////////////////////////////////////////////////////////////////
    internal inner class TRTCCloudListenerImpl : TRTCCloudListener() {
        override fun onEnterRoom(elapsed: Long) {
            TXCLog.i(TAG, "TICManager: TRTC onEnterRoom elapsed: $elapsed")
            report(TICReporter.EventId.ENTER_ROOM_END)
            if (mEnterRoomCallback != null) {
                //
                mEnterRoomCallback!!.onSuccess("succ")
            }
            sendOfflineRecordInfo()
            if (classroomOption!!.classScene == TICClassScene.TIC_CLASS_SCENE_LIVE
                && classroomOption!!.roleType == TICRoleType.TIC_ROLE_TYPE_ANCHOR
            ) {
                startSyncTimer()
            }
        }

        override fun onExitRoom(reason: Int) {
            TXCLog.i(TAG, "TICManager: TRTC onExitRoom :$reason")
        }

        override fun onUserVideoAvailable(userId: String, available: Boolean) {
            TXCLog.i(
                TAG, "TICManager: onUserVideoAvailable->render userId: " + userId
                        + ", available:" + available
            )
            report(
                TICReporter.EventId.ON_USER_VIDEO_AVAILABLE, msg = "userId:" + userId
                        + ",available:" + available
            )
            mEventListner.onTICUserVideoAvailable(userId, available)
        }

        override fun onUserSubStreamAvailable(userId: String, available: Boolean) {
            TXCLog.i(TAG, "TICManager: onUserSubStreamAvailable :$userId|$available")
            report(
                TICReporter.EventId.ON_USER_SUB_STREAM_AVAILABLE, msg = "userId:"
                        + userId + ",available:" + available
            )
            mEventListner.onTICUserSubStreamAvailable(userId, available)
        }

        override fun onUserAudioAvailable(userId: String, available: Boolean) {
            TXCLog.i(TAG, "TICManager: onUserAudioAvailable :$userId|$available")
            report(
                TICReporter.EventId.ON_USER_AUDIO_AVAILABLE, msg = "userId:"
                        + userId + ",available:" + available
            )
            mEventListner.onTICUserAudioAvailable(userId, available)
        }

        override fun onUserEnter(userId: String) {
            TXCLog.i(TAG, "onUserEnter: $userId")
        }

        override fun onUserExit(userId: String, reason: Int) {
            TXCLog.i(TAG, "TICManager: onUserExit: $userId")
            mEventListner.onTICUserVideoAvailable(userId, false)
            mEventListner.onTICUserAudioAvailable(userId, false)
            mEventListner.onTICUserSubStreamAvailable(userId, false)
        }

        /**
         * 1.1 错误回调: SDK不可恢复的错误，一定要监听，并分情况给用户适当的界面提示
         *
         * @param errCode   错误码 TRTCErrorCode
         * @param errMsg    错误信息
         * @param extraInfo 额外信息，如错误发生的用户，一般不需要关注，默认是本地错误
         */
        override fun onError(errCode: Int, errMsg: String, extraInfo: Bundle) {
            TXCLog.i(TAG, "TICManager: sdk callback onError:$errCode|$errMsg")

//            if(errCode == ERR_ROOM_ENTER_FAIL
//                    || errCode == ERR_ENTER_ROOM_PARAM_NULL
//                    || errCode == ERR_SDK_APPID_INVALID
//                    || errCode == ERR_ROOM_ID_INVALID
//                    || errCode == ERR_USER_ID_INVALID
//                    || errCode == ERR_USER_SIG_INVALID){
//            [[TRTCCloud sharedInstance] exitRoom];
//                TICBLOCK_SAFE_RUN(self->_enterCallback, kTICMODULE_TRTC, errCode, errMsg);
//            }
        }

        /**
         * 1.2 警告回调
         *
         * @param warningCode 错误码 TRTCWarningCode
         * @param warningMsg  警告信息
         * @param extraInfo   额外信息，如警告发生的用户，一般不需要关注，默认是本地错误
         */
        override fun onWarning(warningCode: Int, warningMsg: String, extraInfo: Bundle) {
            TXCLog.i(TAG, "TICManager: sdk callback onWarning:$warningCode|$warningMsg")
        }

        override fun onUserVoiceVolume(var1: ArrayList<TRTCVolumeInfo>, var2: Int) {}
        override fun onNetworkQuality(var1: TRTCQuality, var2: ArrayList<TRTCQuality>) {}
        override fun onStatistics(var1: TRTCStatistics) {}
        override fun onFirstAudioFrame(var1: String) {}
        override fun onConnectionLost() {}
        override fun onTryToReconnect() {}
        override fun onConnectionRecovery() {}
        override fun onSpeedTest(var1: TRTCSpeedTestResult, var2: Int, var3: Int) {}
        override fun onCameraDidReady() {}
        override fun onAudioRouteChanged(var1: Int, var2: Int) {}
        override fun onRecvSEIMsg(userid: String, bytes: ByteArray) {
            super.onRecvSEIMsg(userid, bytes)
            try {
                val str = String(bytes)
                val jsonObject = JSONObject(str)
                val isSyncTime = jsonObject.has(SYNCTIME)
                //TXCLog.i(TAG, "TICManager: onRecvSEIMsg  synctime 1: " + isSyncTime);
                if (isSyncTime) {
                    val time = jsonObject.getLong(SYNCTIME)
                    //TXCLog.i(TAG, "TICManager: onRecvSEIMsg  synctime 2: " + userid +  "|" + time);
                    if (mBoard != null) {
                        mBoard!!.syncRemoteTime(userid, time)
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
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
        mEventListner.onTICSendOfflineRecordInfo(code, msg!!)
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
        mMainHandler = Handler(Looper.getMainLooper())
        userInfo = UserInfo()
        mEventListner = TICEventObservable()
        mStatusListner = TICIMStatusObservableM()
        mMessageListner = TICMessageObservableM()
        TXCLog.i(TAG, "TICManager: constructor ")
    }
}