package com.bond.whiteboard

import android.util.Log
import android.widget.FrameLayout
import com.bond.whiteboard.board.BoardAware
import com.bond.whiteboard.nativeView.NativeViewLink
import com.bond.whiteboard.teb.BoardAwareInterface
import com.bond.whiteboard.teb.MyBoardCallback
import com.pigeon.PigeonPlatformMessage
import com.tencent.teduboard.TEduBoardController
import com.tencent.teduboard.TEduBoardController.TEduBoardFileInfo
import com.tencent.tic.core.TICCallback
import com.tencent.tic.core.TICClassroomOption
import com.tencent.tic.core.TICManager
import com.tencent.tic.core.TICManager.Companion.MODULE_IMSDK
import com.tencent.tic.core.TICManager.Companion.TICSDK_WHITEBOARD_CMD
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
    protected var mTicManager: TICManager = TICManager.instance.also {
        it.receiveData(this)
    }

    var boardAware: BoardAware? = null
    fun preJoinClassroom(
        arg: PigeonPlatformMessage.PreJoinClassRequest,
        ticCallback: TICCallback<Any>
    ) {
        val context = nativeViewLink?.getApplicationContext()
        if(context==null){
            val msg="预创建房间失败,上下文为空"
            print(msg)
            ticCallback.onError(MODULE_IMSDK,-1,msg)
            return
        }
        boardAware?.destroy()
        boardAware=BoardAware(context)
        try {
            mTicManager.init(context,arg.appId.toInt(), arg.userId, arg.userSig)
        }catch (e:Exception){
            Log.e("mother fucker","why you are crash anytime")
        }
        //2.白板
        val board = mTicManager.boardController
        if(board==null){
            val msg="预创建房间失败,白板未初始化"
            print(msg)
            ticCallback.onError(MODULE_IMSDK,-1,msg)
            return
        }
        boardAware?.mBoard = board
        //1、设置白板的回调
        boardAware?.mBoardCallback = MyBoardCallback(this)
        print("预创建参数初始化成功")
        ticCallback.onSuccess(1)
    }
    fun joinClassroom(classroomOption: TICClassroomOption, ticCallback: TICCallback<Any>) {
        classroomOption.boardCallback = boardAware?.mBoardCallback
        mTicManager.initTEduBoard(classroomOption)
        print("创建课堂 成功, 房间号：${classroomOption.classId}")
        ticCallback.onSuccess(1)
//        mTicManager.createClassroom(classroomOption.classId,
//            classroomOption.classScene, //如果使用大房间，请使用 TIC_CLASS_SCENE_LIVE
//            object : TICCallback<Any> {
//                override fun onSuccess(data: Any) {
//
//
//                }
//                override fun onError(module: String, errCode: Int, errMsg: String) {
//                    if (errCode == 10021) {
//                        print("该课堂已被他人创建，请\"加入课堂\"")
//                        mTicManager.joinClassroom(classroomOption, ticCallback)
//                    } else if (errCode == 10025) {
//                        print("该课堂已创建，请\"加入课堂\"")
//                        mTicManager.joinClassroom(classroomOption, ticCallback)
//                    } else {
//                        val msg="创建课堂失败, 房间号：${classroomOption.classId} errCode:$errCode msg:$errMsg"
//                        print(msg)
//                        ticCallback.onError(module,errCode,msg)
//                    }
//                }
//            })
    }

    fun quitClassroom() {
        boardAware?.destroy()
//        rtcAware?.destroy()
        flutterApi?.exitRoom(PigeonPlatformMessage.DataModel().apply {
            this.code=1
            this.msg="退出成功"
            this.data=null
        }) {

        }
    }


    fun receiveData(data: ByteArray, callback: TICCallback<Any>) {
        try {
            boardAware?.mBoard?.addSyncData(String(data))
            callback.onSuccess(1)
        }catch (e:Exception){
            callback.onError(TICManager.MODULE_IMSDK, -1, "addSyncData failed: ${e.message}")
        }

    }

    override fun onTICForceOffline() {

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


    override fun sendMessage(data: ByteArray, extension: String) {
        flutterApi?.receiveData(PigeonPlatformMessage.ReceivedData().also {
            it.data=data
            it.extension=extension
        }){it->
            if(it.code.toInt()==-1){
                print("同步失败了:${it.msg}")
            }else{
               val wtf : TEduBoardController = boardAware?.mBoard?:return@receiveData
//                wtf.addAckData(data) //// 🙄🙄🙄🙄🙄🙄🙄❓❓❓❓❓❓❓❓❓❓🙃🙃🙃🙃🙃🙃🙃🙃🙃🙃🙃
            }
        }
    }
    override fun onTEBSyncData(data: String) {
        sendMessage(data.toByteArray(),extension = TICSDK_WHITEBOARD_CMD)
    }

    fun receiveIds(id: String, type: Int) {
//        rtcAware?.mImgsFid
    }


}