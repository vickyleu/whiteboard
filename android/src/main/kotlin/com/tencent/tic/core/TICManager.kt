package com.tencent.tic.core

import android.content.Context
import com.tencent.imsdk.TIMMessage
import com.tencent.teduboard.TEduBoardController
import com.tencent.tic.core.impl.TICManagerImplM
import com.tencent.trtc.TRTCCloud

/**
 * TICSDK业务管理类，主要负责课堂资源管理，互动管理
 */
abstract class TICManager {
    /**
     * 课堂场景
     */
    interface TICClassScene {
        companion object {
            const val TIC_CLASS_SCENE_VIDEO_CALL = 0 //实时通话模式，支持1000人以下场景，低延时
            const val TIC_CLASS_SCENE_LIVE = 1 //直播模式，支持1000人以上场景，会增加600ms左右延时
        }
    }

    /**
     * 房间角色
     *
     * @brief 仅适用于直播模式（TIC_CLASS_SCENE_LIVE），角色TIC_ROLE_TYPE_ANCHOR具有上行权限
     */
    interface TICRoleType {
        companion object {
            const val TIC_ROLE_TYPE_ANCHOR = 20 //主播
            const val TIC_ROLE_TYPE_AUDIENCE = 21 //观众
        }
    }

    /**
     * 禁用模块
     *
     * @brief 如果外部使用了TRTC，可以禁用TIC内部的TRTC模块。
     * @brief 如果禁用TRTC，TRTC相关初始化参数都无效
     */
    interface TICDisableModule {
        companion object {
            const val TIC_DISABLE_MODULE_NONE = 0 //默认全部启用
            const val TIC_DISABLE_MODULE_TRTC = 1 shl 1 //禁用TRTC
        }
    }

    //IM消息回调
    interface TICMessageListener {
        //点到点消息
        fun onTICRecvTextMessage(fromUserId: String?, text: String?)
        fun onTICRecvCustomMessage(fromUserId: String?, data: ByteArray?)

        //群消息
        fun onTICRecvGroupTextMessage(fromUserId: String?, text: String?)
        fun onTICRecvGroupCustomMessage(fromUserId: String?, data: ByteArray?)

        //所有消息
        fun onTICRecvMessage(message: TIMMessage?)
    }

    //IM状态回调
    interface TICIMStatusListener {
        fun onTICForceOffline()
        fun onTICUserSigExpired()
    }

    //TIC 事件回调
    interface TICEventListener {
        fun onTICUserVideoAvailable(userId: String?, available: Boolean)
        fun onTICUserSubStreamAvailable(userId: String?, available: Boolean)
        fun onTICUserAudioAvailable(userId: String?, available: Boolean)
        fun onTICMemberJoin(userList: List<String?>?)
        fun onTICMemberQuit(userList: List<String?>?)
        fun onTICVideoDisconnect(errCode: Int, errMsg: String?)
        fun onTICClassroomDestroy()

        /**
         * 发送离线录制对时信息通知
         *
         * @param code 错误码;0表示成功，其他值为失败;
         * @param desc 错误信息;
         * @note 进房成功后, TIC会自动发送离线录制需要的对时信息;只有成功发送对时信息的课堂才能进行课后离线录制; 注: 可能在子线程中执行此回调;
         */
        fun onTICSendOfflineRecordInfo(code: Int, desc: String?)
    }



    abstract fun addEventListener(callback: TICEventListener)
    abstract fun removeEventListener(callback: TICEventListener)
    abstract fun addIMStatusListener(callback: TICIMStatusListener)
    abstract fun removeIMStatusListener(callback: TICIMStatusListener)
    abstract fun addIMMessageListener(callback: TICMessageListener)
    abstract fun removeIMMessageListener(callback: TICMessageListener)

    /**
     * 1.2 初始化
     *
     * @param context
     * @param appId   iLiveSDK appId
     */
    abstract fun init(context: Context, appId: Int): Int

    /**
     * 1.2 初始化
     *
     * @param context
     * @param appId         iLiveSDK appId
     * @param disableModule 禁用内部TIC相关模块
     */
    abstract fun init(context: Context, appId: Int, disableModule: Int): Int

    /**
     * 1.3 释放资源
     */
    abstract fun unInit(): Int

    /**
     * 1.4 获取trtc的接口
     */
    abstract val tRTCClound: TRTCCloud?

    /**
     * 1.5 获取board的接口
     */
    abstract val boardController: TEduBoardController?

    /**
     * 1.6 切换角色
     *
     * @param role 角色
     * @brief 只在classScene为TIC_CLASS_SCENE_LIVE时有效
     */
    abstract fun switchRole(role: Int)
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      （二）TIC登录/登出/创建销毁课堂/进入退出课堂接口函数
    //
    /////////////////////////////////////////////////////////////////////////////////
    /**
     * 2.1 IM登录
     *
     * @param userId   IM用户id
     * @param userSig  IM用户鉴权票据
     * @param callBack 回调
     */
    abstract fun login(userId: String, userSig: String, callBack: TICCallback<Any>?)

    /**
     * 2.2 注销登录
     *
     * @param callBack 注销登录结果回调
     */
    abstract fun logout(callBack: TICCallback<Any>?)

    /**
     * 2.3 根据参数创建课堂
     *
     * @param classId  房间ID，由业务生成和维护。
     * @param callback 回调，见@TICCallback， onSuccess，创建成功；若出错，则通过onError返回。
     */
    abstract fun createClassroom(classId: Int, scene: Int, callback: TICCallback<Any>?)

    /**
     * 2.4 销毁课堂，由课堂创建者（调用CreateClassroom者）调用
     *
     * @param classId  课堂id
     * @param callback 回调
     */
    abstract fun destroyClassroom(classId: Int, callback: TICCallback<Any>?)

    /**
     * 2.5 根据参数配置和课堂id加入互动课堂中
     *
     * @param option   加入课堂参数选项。见@{TICClassroomOption}
     * @param callback 回调
     */
    abstract fun joinClassroom(option: TICClassroomOption?, callback: TICCallback<Any>?)

    /**
     * 2.6 退出课堂，退出iLiveSDK的AV房间，学生角色退出群聊和白板通道群组；老师角色则解散IM群组
     *
     * @param callback   回调
     * @param clearBoard 是否把白板数据全部清除
     */
    abstract fun quitClassroom(clearBoard: Boolean, callback: TICCallback<Any>?)
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      （三) IM消息
    //
    /////////////////////////////////////////////////////////////////////////////////
    /**
     * 5.1 发送文本消息
     *
     * @param userId   为C2C消息接收者；
     * @param text     文本消息内容
     * @param callBack 回调
     */
    abstract fun sendTextMessage(
        userId: String,
        text: String,
        callBack: TICCallback<TIMMessage>?
    )

    /**
     * 5.2 发送自定义消息
     *
     * @param userId   为C2C消息接收者；
     * @param data     自定义消息内容
     * @param callBack 回调
     */
    abstract fun sendCustomMessage(
        userId: String,
        data: ByteArray,
        callBack: TICCallback<TIMMessage>?
    )

    /**
     * 5.3 发送通用互动消息，全接口
     *
     * @param userId   为C2C消息接收者；
     * @param message  互动消息
     * @param callBack 回调
     */
    abstract fun sendMessage(
        userId: String,
        message: TIMMessage,
        callBack: TICCallback<TIMMessage>?
    )

    /**
     * 5.4 发送群组文本消息
     *
     * @param text     文本消息内容
     * @param callBack 回调
     */
    abstract fun sendGroupTextMessage(text: String, callBack: TICCallback<Any>?)

    /**
     * 5.5 发送群组文本消息
     *
     * @param data     文本消息内容
     * @param callBack 回调
     */
    abstract fun sendGroupCustomMessage(data: ByteArray, callBack: TICCallback<Any>?)

    /**
     * 5.5 发送群组消息
     *
     * @param message  消息内容
     * @param callBack 回调
     */
    abstract fun sendGroupMessage(message: TIMMessage, callBack: TICCallback<Any>?)
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      （四) 录制消息
    //
    /////////////////////////////////////////////////////////////////////////////////
    /**
     * 发送离线录制对时信息
     *
     * @brief TIC内部进房成功后会自动发送离线录制对时信息，如果发送失败回调onTICSendOfflineRecordInfo接口且code!=0，用户可调用些接口触发重试
     */
    abstract fun sendOfflineRecordInfo()

    companion object {
        /**
         * 白板数据消息命令字
         */
        const val TICSDK_WHITEBOARD_CMD = "TXWhiteBoardExt"
        const val MODULE_TIC_SDK = "ticsdk"
        const val MODULE_IMSDK = "imsdk"
        /////////////////////////////////////////////////////////////////////////////////
        //
        //                      （一）初始和终止接口函数
        //
        /////////////////////////////////////////////////////////////////////////////////
        /**
         * 1.1 获取TicManager的实例
         */
        val instance: TICManager
            get() {
                var instance: TICManager
                synchronized(TICManager::class.java) { instance = TICManagerImplM.sharedInstance() }
                return instance
            }
    }
}

