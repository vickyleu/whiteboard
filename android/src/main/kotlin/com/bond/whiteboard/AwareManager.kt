package com.bond.whiteboard

import android.content.Context
import android.util.Log
import android.widget.FrameLayout
import com.bond.whiteboard.board.BoardAware
import com.bond.whiteboard.nativeView.NativeViewLink
import com.bond.whiteboard.rtc.RtcAware
import com.bond.whiteboard.teb.BoardAwareInterface
import com.bond.whiteboard.teb.MyBoardCallback
import com.pigeon.PigeonPlatformMessage
import com.tencent.teduboard.TEduBoardController.TEduBoardFileInfo
import com.tencent.tic.core.TICCallback
import com.tencent.tic.core.TICClassroomOption
import com.tencent.tic.core.TICManager
import com.tencent.tic.core.TICManager.TICIMStatusListener

class AwareManager : TICIMStatusListener, BoardAwareInterface {
    var nativeViewLink: NativeViewLink?=null
    var flutterApi: PigeonPlatformMessage.PigeonFlutterApi?=null
    private val settingCallback = MySettingCallback().also {
        it.awareManager=this
    }
    /**
     * 课堂资源互动管理
     */
    protected var mTicManager: TICManager = TICManager.instance

    var rtcAware: RtcAware? = null
    var boardAware: BoardAware? = null

    fun joinClassroom(classroomOption: TICClassroomOption, ticCallback: TICCallback<Any>) {
        val context = nativeViewLink?.getApplicationContext()?:return
        boardAware?.destroy()
        rtcAware?.destroy()
        boardAware=BoardAware(context)
        rtcAware= RtcAware(mTicManager.tRTCClound).also {
            it.initRTC(context)
        }
        //2.白板
        boardAware?.mBoard = mTicManager.boardController?:return
        //1、设置白板的回调
        boardAware?.mBoardCallback = MyBoardCallback(this)
        classroomOption.boardCallback = boardAware?.mBoardCallback
        mTicManager.createClassroom(classroomOption.classId,
            classroomOption.classScene, //如果使用大房间，请使用 TIC_CLASS_SCENE_LIVE
            object : TICCallback<Any> {
                override fun onSuccess(data: Any) {
                    print("创建课堂 成功, 房间号：${classroomOption.classId}")
                    mTicManager.joinClassroom(classroomOption, ticCallback)
                }
                override fun onError(module: String, errCode: Int, errMsg: String) {
                    if (errCode == 10021) {
                        print("该课堂已被他人创建，请\"加入课堂\"")
                        mTicManager.joinClassroom(classroomOption, ticCallback)
                    } else if (errCode == 10025) {
                        print("该课堂已创建，请\"加入课堂\"")
                        mTicManager.joinClassroom(classroomOption, ticCallback)
                    } else {
                        val msg="创建课堂失败, 房间号：${classroomOption.classId} errCode:$errCode msg:$errMsg"
                        print(msg)
                        ticCallback.onError(module,errCode,msg)
                    }
                }
            })
    }

    fun quitClassroom(clearBoard: Boolean, ticCallback: TICCallback<Any>) {
        mTicManager.quitClassroom(clearBoard, ticCallback)
        boardAware?.destroy()
//        rtcAware?.destroy()
    }

    fun login(userID: String, userSig: String, ticCallback: TICCallback<Any>) {
        mTicManager.login(userID, userSig, ticCallback)
    }

    override fun onTICForceOffline() {
        //1、退出TRTC
        rtcAware?.mTrtcCloud?.exitRoom()
        quitClassroom(true, object : TICCallback<Any> {
            override fun onError(module: String, errCode: Int, errMsg: String) {
                flutterApi?.exitRoom(PigeonPlatformMessage.DataModel().apply {
                    this.code=errCode.toLong()
                    this.msg="退出失败:$errMsg"
                    this.data=null
                }) {

                }
            }
            override fun onSuccess(data: Any) {
                flutterApi?.exitRoom(PigeonPlatformMessage.DataModel().apply {
                    this.code=1
                    this.msg="退出成功"
                    this.data=null
                }) {

                }
            }
        })
    }

    override fun onTICUserSigExpired() {
        //
    }
    override fun onTEBHistroyDataSyncCompleted() {
        val board = boardAware?.mBoard ?: return
        val currentBoard: String = board.currentBoard;
        val currentFile = board.currentFile
        Log.w("DataSyncCompleted", "currentBoard: $currentBoard currentFile: $currentFile")
    }

    override fun addBoardView() {
        val boardView= boardAware?.mBoard?.boardRenderView ?:return
        val layoutParams = FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)
        nativeViewLink?.addView(boardView,layoutParams)
    }
    override fun removeBoardView() {
        val boardView= boardAware?.mBoard?.boardRenderView ?:return
        nativeViewLink?.removeView(boardView)
    }
    override fun setCanUndo(canUndo: Boolean) {
        settingCallback.setCanUndo(canUndo)
    }
    override fun setCanRedo(canredo: Boolean) {
        settingCallback.setCanRedo(canredo)
    }
    override fun addFile(fileId: String?): TEduBoardFileInfo? {
        return null
    }

    override fun onTextComponentStatusChange(id: String?, status: String?) {
        //
    }

    fun init(context: Context,appid:Int) {
        mTicManager.init(context, appid)
    }
}