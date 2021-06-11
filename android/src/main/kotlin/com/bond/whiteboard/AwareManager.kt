package com.bond.whiteboard

import android.annotation.SuppressLint
import android.graphics.Color
import android.os.Build
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import androidx.annotation.ColorInt
import com.bond.whiteboard.board.BoardAware
import com.bond.whiteboard.nativeView.NativeViewLink
import com.bond.whiteboard.teb.BoardAwareInterface
import com.bond.whiteboard.teb.MyBoardCallback
import com.pigeon.PigeonPlatformMessage
import com.tencent.smtt.sdk.WebView
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
    var drawerType = DrawerType.drawGraffiti
    var isHaveImageBackground = false
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
        board.globalBackgroundColor= TEduBoardController.TEduBoardColor(Color.TRANSPARENT)
        boardAware?.mBoard = board
        //1、设置白板的回调
        boardAware?.mBoardCallback = MyBoardCallback(this)
        print("预创建参数初始化成功")
        ticCallback.onSuccess(1)
    }
    fun joinClassroom(
        classroomOption: TICClassroomOption,
        ticCallback: TICCallback<Any>
    ) {
        classroomOption.boardCallback = boardAware?.mBoardCallback
        mTicManager.initTEduBoard(classroomOption)
        print("创建课堂 成功, 房间号：${classroomOption.classId}")
        ticCallback.onSuccess(1)
    }

    fun reset() {
        boardAware?.reset()
        drawerType = DrawerType.drawGraffiti
        isHaveImageBackground=false
    }
    fun setBackgroundColor(@ColorInt color:Int) {
        boardAware?.setBackgroundColor(color)
    }
    fun quitClassroom() {
        boardAware?.destroy()
        isHaveImageBackground=false
        mTicManager.quitClassroom(true,object :TICCallback<Any>{
            override fun onSuccess(data: Any) {
                removeBoardView()
            }
            override fun onError(module: String, errCode: Int, errMsg: String) {
                Log.e("mother fucker","退出白板失败:$errCode  $errMsg")
                removeBoardView()
            }
        })
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
        flutterApi?.historySyncCompleted(null)
        val board = boardAware?.mBoard ?: return
        val currentBoard: String = board.currentBoard;
        val currentFile = board.currentFile
        Log.w("DataSyncCompleted", "currentBoard: $currentBoard currentFile: $currentFile")
    }

    override fun addBoardView() {
        val board= boardAware?.mBoard ?:return
        board.backgroundColor= TEduBoardController.TEduBoardColor(Color.TRANSPARENT)
        val boardView= board.boardRenderView ?:return
        val webView = boardView as WebView
        if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.LOLLIPOP) {
            try {
                webView.settings.mixedContentMode=0
            }catch (e:Exception){}
        }
        webView.isFocusable=true
        webView.isFocusableInTouchMode=true

        webView.requestFocus(View.FOCUS_DOWN)
        webView.setOnTouchListener { v,  event ->
            when (event.getAction()) {
                MotionEvent.ACTION_DOWN, MotionEvent.ACTION_UP -> if (!v.hasFocus()) {
                    v.requestFocus()
                }
            }
            false
        }

        webView.setOnFocusChangeListener { v, hasFocus ->
            Log.e("setOnFocusChangeLis","${hasFocus}")
            v.requestFocus()
        }
        webView.setBackgroundColor(Color.TRANSPARENT)
        webView.setPadding(0,0,0,0)
        val layoutParams = FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)
        nativeViewLink?.addView(boardView,layoutParams)
    }
    override fun removeBoardView() {
        val board= boardAware?.mBoard  ?:return
        val boardView= board.boardRenderView ?:return
        nativeViewLink?.removeView(boardView)
        board.uninit()
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


    fun addBackgroundImage(url: String) {
        boardAware?.mBoard?.setBackgroundImage(url, TEduBoardController.TEduBoardImageFitMode.TEDU_BOARD_IMAGE_FIT_MODE_CENTER)
        isHaveImageBackground=true
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

    fun drawGraffiti() {
        if(drawerType==DrawerType.drawGraffiti)return
        drawerType=DrawerType.drawGraffiti
        boardAware?.mBoard?.toolType = TEduBoardController.TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_PEN
    }

    fun drawLine() {
        if(drawerType==DrawerType.drawLine)return
        drawerType=DrawerType.drawLine
        boardAware?.mBoard?.toolType = TEduBoardController.TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_LINE
    }

    fun drawSquare() {
        if(drawerType==DrawerType.drawSquare)return
        drawerType=DrawerType.drawSquare
        boardAware?.mBoard?.toolType = TEduBoardController.TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_RECT
    }

    fun drawCircular() {
        if(drawerType==DrawerType.drawCircular)return
        drawerType=DrawerType.drawCircular
        boardAware?.mBoard?.toolType = TEduBoardController.TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_OVAL
    }

    fun drawText() {
        if(drawerType==DrawerType.drawText)return
        drawerType=DrawerType.drawText
        boardAware?.mBoard?.textStyle = TEduBoardController.TEduBoardTextStyle.TEDU_BOARD_TEXT_STYLE_NORMAL
        boardAware?.mBoard?.toolType = TEduBoardController.TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_TEXT
    }

    fun eraserDrawer() {
        if(drawerType==DrawerType.eraserDrawer)return
        drawerType=DrawerType.eraserDrawer
        val arr : ArrayList<Int> = arrayListOf<Int>(
            TEduBoardController.TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_LINE,
            TEduBoardController.TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_OVAL,
            TEduBoardController.TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_MOUSE,
            TEduBoardController.TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_PEN,
            TEduBoardController.TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_RECT,
            TEduBoardController.TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_TEXT)
        boardAware?.mBoard?.toolType = TEduBoardController.TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_ERASER
        boardAware?.mBoard?.setEraseLayerType(arr)
    }

    fun rollbackDraw() {
        boardAware?.mBoard?.undo()
    }

    fun wipeDraw() {
        boardAware?.mBoard?.clear(false)
        isHaveImageBackground=false
    }

    fun setToolColor(value: String) {
        val color=TEduBoardController.TEduBoardColor(value)
        when(drawerType) {
            DrawerType.drawGraffiti->{
                boardAware?.mBoard?.brushColor=color
            }
            DrawerType.drawLine->{
                boardAware?.mBoard?.brushColor=color
            }
            DrawerType .drawSquare->{
                boardAware?.mBoard?.brushColor=color
            }
            DrawerType .drawCircular->{
                boardAware?.mBoard?.brushColor=color
            }
            DrawerType .drawText->{
                boardAware?.mBoard?.textColor=color
            }
            DrawerType .eraserDrawer->{
            }
        }
    }

    fun setToolSize(size: Int) {
        when(drawerType) {
            DrawerType.drawGraffiti->{
                boardAware?.mBoard?.brushThin = size
            }
            DrawerType .drawLine->{
                boardAware?.mBoard?.brushThin = size
            }
            DrawerType .drawSquare->{
                boardAware?.mBoard?.brushThin = size
            }
            DrawerType .drawCircular->{
                boardAware?.mBoard?.brushThin = size
            }
            DrawerType .drawText->{
                boardAware?.mBoard?.textSize = size
            }
            DrawerType .eraserDrawer->{
            }
        }
    }


    fun removeImageBackground() {
        boardAware?.mBoard?.clear(true)
        isHaveImageBackground=false
    }

}

enum class DrawerType{
    drawGraffiti,
    drawLine,
    drawSquare,
    drawCircular,
    drawText,
    eraserDrawer,
}