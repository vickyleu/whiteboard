package com.tencent.tic.core

import android.content.Context
import com.bond.whiteboard.teb.BoardAwareInterface
import com.tencent.imsdk.v2.V2TIMMessage
import com.tencent.teduboard.TEduBoardController
import com.tencent.tic.core.impl.TICManagerImplM

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

    //IM消息回调
    interface TICMessageListener {
        //点到点消息
        fun onTICRecvTextMessage(fromUserId: String, text: String)
        fun onTICRecvCustomMessage(fromUserId: String, data: ByteArray)

        //群消息
        fun onTICRecvGroupTextMessage(fromUserId: String, text: String)
        fun onTICRecvGroupCustomMessage(fromUserId: String, data: ByteArray)

        //所有消息
        fun onTICRecvMessage(message: V2TIMMessage)
    }

    //IM状态回调
    interface TICIMStatusListener {
        fun onTICForceOffline()
        fun onTICUserSigExpired()
    }

    //TIC 事件回调
    interface TICEventListener {
        fun onTICUserVideoAvailable(userId: String, available: Boolean)
        fun onTICUserSubStreamAvailable(userId: String, available: Boolean)
        fun onTICUserAudioAvailable(userId: String, available: Boolean)
        fun onTICMemberJoin(userList: List<String>)
        fun onTICMemberQuit(userList: List<String>)
        fun onTICVideoDisconnect(errCode: Int, errMsg: String)
        fun onTICClassroomDestroy()

        /**
         * 发送离线录制对时信息通知
         *
         * @param code 错误码;0表示成功，其他值为失败;
         * @param desc 错误信息;
         * @note 进房成功后, TIC会自动发送离线录制需要的对时信息;只有成功发送对时信息的课堂才能进行课后离线录制; 注: 可能在子线程中执行此回调;
         */
        fun onTICSendOfflineRecordInfo(code: Int, desc: String)
    }
    abstract fun init(context: Context, appId: Int, userId: String, userSig: String): Int

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

//    /**
//     * 2.5 根据参数配置和课堂id加入互动课堂中
//     *
//     * @param option   加入课堂参数选项。见@{TICClassroomOption}
//     * @param callback 回调
//     */
//    abstract fun joinClassroom(option: TICClassroomOption?, callback: TICCallback<Any>?)
//
//    /**
//     * 2.6 退出课堂，退出iLiveSDK的AV房间，学生角色退出群聊和白板通道群组；老师角色则解散IM群组
//     *
//     * @param callback   回调
//     * @param clearBoard 是否把白板数据全部清除
//     */
//    abstract fun quitClassroom(clearBoard: Boolean, callback: TICCallback<Any>?)

    abstract fun  initTEduBoard(classroomOption: TICClassroomOption)
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
    abstract fun receiveData(awareManager: BoardAwareInterface)
    abstract fun quitClassroom(clearBoard: Boolean,callback: TICCallback<Any>)

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

