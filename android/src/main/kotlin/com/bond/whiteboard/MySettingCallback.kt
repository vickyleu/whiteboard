package com.bond.whiteboard

import android.os.Environment
import android.text.TextUtils
import android.util.Log
import com.tencent.teduboard.TEduBoardController.*
import com.tencent.trtc.TRTCCloudDef
import java.util.*

//------回调设置的处理------
internal class MySettingCallback : IMoreListener {
    var awareManager: AwareManager? = null

    var _canRedo=true
    var _canUndo=true

    //------------board------------
    override fun onSetDrawEnable(SetDrawEnable: Boolean) {
        awareManager?.boardAware?.mBoard?.isDrawEnable = SetDrawEnable
    }

    override fun onSyncDrawEnable(syncDrawEnable: Boolean) {
        awareManager?.boardAware?.mBoard?.isDataSyncEnable = syncDrawEnable
    }

    override fun onStartSnapshot() {
        val snapshotInfo = TEduBoardSnapshotInfo()
        snapshotInfo.path = Environment.getExternalStorageDirectory().absolutePath
        awareManager?.boardAware?.mBoard?.snapshot(snapshotInfo)
    }

    override fun onNextTextInput(textContent: String, keepFocus: Boolean) {
        awareManager?.boardAware?.mBoard?.setNextTextInput(textContent, keepFocus)
    }

    override fun onTipTextInput(textContent: String) {
        val titleStyle = TEduBoardToolTypeTitleStyle()
        titleStyle.color = "#FF0000"
        titleStyle.size = 1000
        titleStyle.style = TEduBoardTextStyle.TEDU_BOARD_TEXT_STYLE_BOLD_ITALIC
        titleStyle.position = TEduBoardPosition.TEDU_BOARD_POSITION_RIGHT_TOP
        awareManager?.boardAware?.mBoard?.setToolTypeTitle(textContent, titleStyle)
    }

    override fun onWipeNumInput(num: Int) {
        awareManager?.boardAware?.mBoard?.setEraseLayerLimit(num)
    }

    override fun onSetHandwritingEnable(writingEnable: Boolean) {
        awareManager?.boardAware?.mBoard?.isHandwritingEnable = writingEnable
    }

    override fun onSetToolType(type: Int) {
        awareManager?.boardAware?.mBoard?.toolType = type
    }

    override fun onBrushThin(size: Int) {
        awareManager?.boardAware?.mBoard?.brushThin = size
    }

    override fun onSetTextSize(size: Int) {
        awareManager?.boardAware?.mBoard?.textSize = size
    }

    override fun onAddElement(type: Int, url: String) {
        val elementId = awareManager?.boardAware?.mBoard?.addElement(type, url)
//        if (type == 4) {
//            awareManager?.rtcAware?.mAudioElementId = elementId
//        }
//        Log.d("evaluateJs", "onAddElement elementId: " + elementId + " mAudioElementId: " + awareManager?.rtcAware?.mAudioElementId)
    }

    override fun onSetBrushColor(color: Int) {
        val eduBoardColor = TEduBoardColor(color)
        awareManager?.boardAware?.mBoard?.brushColor = eduBoardColor
    }

    override fun onSetTextColor(color: Int) {
        awareManager?.boardAware?.mBoard?.textColor = TEduBoardColor(color)
    }

    override fun onSetTextStyle(style: Int) {
        awareManager?.boardAware?.mBoard?.textStyle = style
    }

    override fun onSetBackgroundColore(color: Int) {
        awareManager?.boardAware?.mBoard?.backgroundColor = TEduBoardColor(color)
    }

    override fun onSetBackgroundImage(path: String) {
        if (!TextUtils.isEmpty(path)) {
            awareManager?.boardAware?.mBoard?.setBackgroundImage(path, TEduBoardImageFitMode.TEDU_BOARD_IMAGE_FIT_MODE_CENTER)
        }
    }

    override fun onSetBackgroundH5(url: String) {
        if (!TextUtils.isEmpty(url)) {
            awareManager?.boardAware?.mBoard?.setBackgroundH5(url)
        }
    }

    override fun setWipeType(wipeType: Int) {
        val typeArray: MutableList<Int> = ArrayList()
        typeArray.add(wipeType)
        awareManager?.boardAware?.mBoard?.setEraseLayerType(typeArray)
    }

    override fun onUndo() {
        val board = awareManager?.boardAware?:return
        if(_canUndo)
            board.mBoard?.undo()
    }

    override fun onRedo() {
        val board = awareManager?.boardAware?:return
        if(_canRedo)
            board.mBoard?.redo()
    }

    override fun onClear() {
        awareManager?.boardAware?.mBoard?.clear(true)
    }

    override fun onReset() {
        awareManager?.boardAware?.mBoard?.reset()
    }

    override fun onAddBoard(url: String) {
        awareManager?.boardAware?.mBoard?.addBoard(url)
    }

    override fun onDeleteBoard(boardId: String) {
        awareManager?.boardAware?.mBoard?.deleteBoard(boardId)
    }

    override fun onGotoBoard(boardId: String) {
        awareManager?.boardAware?.mBoard?.gotoBoard(boardId)
    }

    override fun onPrevStep() {
        awareManager?.boardAware?.mBoard?.prevStep()
    }

    override fun onNextStep() {
        awareManager?.boardAware?.mBoard?.nextStep()
    }

    override fun onPrevBoard() {
        awareManager?.boardAware?.mBoard?.prevBoard()
    }

    override fun onNextBoard() {
        awareManager?.boardAware?.mBoard?.nextBoard()
    }

    override fun onScale(scale: Int) {
        awareManager?.boardAware?.mBoard?.boardScale = scale
    }

    override fun onSetRatio(ratio: String) {
        awareManager?.boardAware?.mBoard?.boardRatio = ratio
    }

    override fun onSetFitMode(mode: Int) {
        awareManager?.boardAware?.mBoard?.boardContentFitMode = mode
    }

    override fun onTransCodeFile(myresult: TEduBoardTranscodeFileResult) {
        awareManager?.boardAware?.mBoard?.addTranscodeFile(myresult, true)
    }

    override fun onAddH5File(url: String) {
        awareManager?.boardAware?.mBoard?.addH5File(url)
    }

    override fun onDeleteFile(fileId: String) {
        awareManager?.boardAware?.mBoard?.deleteFile(fileId)
    }

    override fun onGotoFile(fid: String) {
        awareManager?.boardAware?.mBoard?.switchFile(fid)
    }

    override fun onAddImagesFile(urls: List<String>) {
        awareManager?.receiveIds(awareManager?.boardAware?.mBoard?.addImagesFile(urls)?:return,1)
//        awareManager?.rtcAware?.mImgsFid = awareManager?.boardAware?.mBoard?.addImagesFile(urls)
    }

    override fun onPlayVideoFile(url: String) {
        awareManager?.boardAware?.mBoard?.addVideoFile(url)
    }

    override fun onPlayAudio(audioElementId:String?) {
        if (!TextUtils.isEmpty(audioElementId)) {
            awareManager?.boardAware?.mBoard?.playAudio(audioElementId)
            // mBoard.seekAudio(mAudioElementId, 120);
            //     mBoard.setAudioVolume(mAudioElementId,0.7f);
        }
    }

    override fun onPauseAudio(audioElementId:String?) {
        if (!TextUtils.isEmpty(audioElementId)) {
            awareManager?.boardAware?.mBoard?.pauseAudio(audioElementId)
            // mBoard.getAudioVolume(mAudioElementId);
            awareManager?.boardAware?.mBoard?.getBoardElementList("")
        }
    }

    override fun onAddBackupDomain() {
        awareManager?.boardAware?.mBoard?.addBackupDomain("https://test2.tencent.com", "http://b.hiphotos.baidu.com", 0)
    }

    override fun onRemoveBackupDomain() {
        awareManager?.boardAware?.mBoard?.removeBackupDomain("https://test2.tencent.com", "http://b.hiphotos.baidu.com")
    }

    override fun onShowVideoCtrl(value: Boolean) {
        awareManager?.boardAware?.mBoard?.showVideoControl(value)
    }

    override fun onSyncAndReload() {
        awareManager?.boardAware?.mBoard?.syncAndReload()
    }

    override fun onSetSystemCursorEnable(systemCursorEnable: Boolean) {
        awareManager?.boardAware?.mBoard?.setSystemCursorEnable(systemCursorEnable)
    }

    fun setCanUndo(canUndo: Boolean) {
        _canUndo=canUndo
    }

    fun setCanRedo(canredo: Boolean) {
        _canRedo=canredo
    }
}
private interface IMoreListener {
    //TRTC
//    fun onEnableAudio(bEnableAudio: Boolean)
//    fun onSwitchAudioRoute(speaker: Boolean)
//    fun onEnableCamera(bEnableCamera: Boolean)
//    fun onSwitchCamera(bFrontCamera: Boolean)

    //Board(涂鸭操作)
    fun onSetDrawEnable(SetDrawEnable: Boolean)
    fun onSyncDrawEnable(syncDrawEnable: Boolean)
    fun onStartSnapshot()
    fun onNextTextInput(textContent: String, keepFocus: Boolean)
    fun onTipTextInput(textContent: String)
    fun onWipeNumInput(num: Int)
    fun onSetHandwritingEnable(syncDrawEnable: Boolean)
    fun onSetSystemCursorEnable(systemCursorEnable: Boolean)
    fun onSetToolType(type: Int)
    fun onBrushThin(size: Int)
    fun onSetTextSize(size: Int)
    fun onScale(scale: Int)
    fun onSetRatio(scale: String)
    fun onSetFitMode(mode: Int)
    fun onAddElement(type: Int, url: String)
    fun onSetBrushColor(color: Int)
    fun onSetTextColor(color: Int)
    fun onSetTextStyle(style: Int)
    fun onSetBackgroundColore(color: Int)
    fun onSetBackgroundImage(path: String)
    fun onSetBackgroundH5(url: String)
    fun setWipeType(wipeType: Int)
    fun onUndo()
    fun onRedo()
    fun onClear()
    fun onReset()

    //Board(白板操作)
    fun onAddBoard(url: String)
    fun onDeleteBoard(boardId: String)
    fun onGotoBoard(boardId: String)
    fun onPrevStep()
    fun onNextStep()
    fun onPrevBoard()
    fun onNextBoard()

    //Board(文件操作)
    fun onTransCodeFile(result: TEduBoardTranscodeFileResult)
    fun onAddH5File(url: String)
    fun onDeleteFile(boardId: String)
    fun onGotoFile(boardId: String)
    fun onAddImagesFile(urls: List<String>)

    //Video()
    fun onPlayVideoFile(url: String)
    fun onShowVideoCtrl(value: Boolean)
    fun onSyncAndReload()
    fun onPlayAudio(audioElementId:String?)
    fun onPauseAudio(audioElementId:String?)
    fun onAddBackupDomain()
    fun onRemoveBackupDomain()
}