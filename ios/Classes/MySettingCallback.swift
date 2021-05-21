//
// Created by vicky Leu on 2021/5/19.
//

import Foundation


internal class  MySettingCallback : NSObject,IMoreListener {
    var awareManager: AwareManager?
    private var _canRedo=true
    private var _canUndo=true
    
    func setCanUndo(_ canUndo: Bool) {
        _canUndo=canUndo
    }
    
    func setCanRedo(_ canredo: Bool) {
        _canRedo=canredo
    }
    
    func onEnableAudio(bEnableAudio: Bool) {
        awareManager?.rtcAware?.mEnableAudio = bEnableAudio
        awareManager?.rtcAware?.enableAudioCapture(bEnableAudio)
    }
    
    
    func onSwitchAudioRoute(speaker: Bool) {
        awareManager?.rtcAware?.mEnableAudioRouteSpeaker = speaker
        awareManager?.rtcAware?.mTrtcCloud?.setAudioRoute(speaker ? TRTCAudioRoute.modeSpeakerphone : TRTCAudioRoute.modeEarpiece)
    }
    
    func onEnableCamera(bEnableCamera: Bool) {
        awareManager?.rtcAware?.mEnableCamera = bEnableCamera
        awareManager?.rtcAware?.startLocalVideo(bEnableCamera)
    }
    
    func onSwitchCamera(bFrontCamera: Bool) {
        awareManager?.rtcAware?.mEnableFrontCamera = bFrontCamera
        awareManager?.rtcAware?.mTrtcCloud?.switchCamera()
    }
    
    func onSetDrawEnable(SetDrawEnable: Bool) {
        awareManager?.boardAware?.mBoard?.setDrawEnable(SetDrawEnable)
    }
    
    func onSyncDrawEnable(syncDrawEnable: Bool) {
        awareManager?.boardAware?.mBoard?.setDataSyncEnable(syncDrawEnable)
    }
    
    func onStartSnapshot() {
        let snapshotInfo = TEduBoardSnapshotInfo()
        snapshotInfo.path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.absoluteURL.absoluteString
        awareManager?.boardAware?.mBoard?.snapshot(snapshotInfo)
    }
    
    func onNextTextInput(textContent: String, keepFocus: Bool) {
        awareManager?.boardAware?.mBoard?.setNextTextInput(textContent, focus:keepFocus)
    }
    
    func onTipTextInput(textContent: String) {
        let titleStyle = TEduBoardToolTypeTitleStyle()
        titleStyle.color = UIColor.init(hex: "#FF0000")
        titleStyle.size = 1000
        titleStyle.style = TEduBoardTextStyle.TEDU_BOARD_TEXT_STYLE_BOLD_ITALIC
        titleStyle.position = TEduBoardPosition.TEDU_BOARD_POSITION_RIGHT_TOP
        awareManager?.boardAware?.mBoard?.setToolTypeTitle(textContent, style:titleStyle)
    }
    
    func onWipeNumInput(num: Int) {
        awareManager?.boardAware?.mBoard?.setEraseLayerLimit(num)
    }
    
    func onSetHandwritingEnable(syncDrawEnable: Bool) {
        awareManager?.boardAware?.mBoard?.setHandwritingEnable(syncDrawEnable)
    }
    
    func onSetSystemCursorEnable(systemCursorEnable: Bool) {
        awareManager?.boardAware?.mBoard?.setSystemCursorEnable(systemCursorEnable)
    }
    
    func onSetToolType(type: Int) {
        awareManager?.boardAware?.mBoard?.setToolType(TEduBoardToolType(rawValue: type)!)
    }
    
    func onBrushThin(size: Int) {
        awareManager?.boardAware?.mBoard?.setBrushThin(UInt32(size))
    }
    
    func onSetTextSize(size: Int) {
        awareManager?.boardAware?.mBoard?.setTextSize(UInt32(size))
    }
    
    func onScale(scale: Int) {
        awareManager?.boardAware?.mBoard?.setBoardScale(UInt32(scale))
    }
    
    func onSetRatio(scale: String) {
        awareManager?.boardAware?.mBoard?.setBoardRatio(scale)
    }
    
    func onSetFitMode(mode: Int) {
        awareManager?.boardAware?.mBoard?.setBoardContentFitMode(TEduBoardContentFitMode(rawValue: mode)!)
    }
    
    func onAddElement(type: Int, url: String) {
        let elementId = awareManager?.boardAware?.mBoard?.addElement(url, type: TEduBoardElementType(rawValue: type)!)
        if (type == 4) {
            awareManager?.rtcAware?.mAudioElementId = elementId
        }
        print("evaluateJs onAddElement elementId: \(elementId) mAudioElementId: \(awareManager?.rtcAware?.mAudioElementId)")
    }
    
    func onSetBrushColor(color: Int) {
        awareManager?.boardAware?.mBoard?.setBrush(UIColor.init(rgbValue: color))
    }
    
    func onSetTextColor(color: Int) {
        awareManager?.boardAware?.mBoard?.setTextColor(UIColor.init(rgbValue: color))
    }
    
    func onSetTextStyle(style: Int) {
        awareManager?.boardAware?.mBoard?.setTextStyle(TEduBoardTextStyle(rawValue: style)!)
    }
    
    func onSetBackgroundColore(color: Int) {
        awareManager?.boardAware?.mBoard?.setBackgroundColor(UIColor.init(rgbValue: color))
    }
    
    func onSetBackgroundImage(path: String) {
        if !path.isEmpty {
            awareManager?.boardAware?.mBoard?.setBackgroundImage(path, mode:TEduBoardImageFitMode.TEDU_BOARD_IMAGE_FIT_MODE_CENTER)
        }
    }
    
    func onSetBackgroundH5(url: String) {
        if !url.isEmpty {
            awareManager?.boardAware?.mBoard?.setBackgroundH5(url)
        }
    }
    
    func setWipeType(wipeType: Int) {
        var typeArray:[NSNumber] = []
        typeArray.append(NSNumber(value: wipeType))
        awareManager?.boardAware?.mBoard?.setEraseLayerType(typeArray)
    }
    
    func onUndo() {
        guard let board = awareManager?.boardAware else {return}
        if(_canUndo){
            board.mBoard?.undo()
        }
        
    }
    
    func onRedo() {
        guard let board = awareManager?.boardAware else {return}
        if(_canUndo){
            board.mBoard?.redo()
        }
    }
    
    func onClear() {
        awareManager?.boardAware?.mBoard?.clear()
    }
    
    func onReset() {
        awareManager?.boardAware?.mBoard?.reset()
    }
    
    func onAddBoard(url: String) {
        awareManager?.boardAware?.mBoard?.addBoard(withBackgroundImage: url)
    }
    
    func onDeleteBoard(boardId: String) {
        awareManager?.boardAware?.mBoard?.deleteBoard(boardId)
    }
    
    func onGotoBoard(boardId: String) {
        awareManager?.boardAware?.mBoard?.gotoBoard(boardId)
    }
    
    func onPrevStep() {
        awareManager?.boardAware?.mBoard?.prevStep()
    }
    
    func onNextStep() {
        awareManager?.boardAware?.mBoard?.nextStep()
    }
    
    func onPrevBoard() {
        awareManager?.boardAware?.mBoard?.preBoard()
    }
    
    func onNextBoard() {
        awareManager?.boardAware?.mBoard?.nextBoard()
    }
    
    func onTransCodeFile(result: TEduBoardTranscodeFileResult) {
        awareManager?.boardAware?.mBoard?.addTranscodeFile(result, needSwitch:true)
    }
    
    func onAddH5File(url: String) {
        awareManager?.boardAware?.mBoard?.addH5File(url)
    }
    
    func onDeleteFile(boardId: String) {
        awareManager?.boardAware?.mBoard?.deleteFile(boardId)
    }
    
    func onGotoFile(boardId: String) {
        awareManager?.boardAware?.mBoard?.switchFile(boardId)
    }
    
    func onAddImagesFile(urls: Array<String>) {
        awareManager?.rtcAware?.mImgsFid = awareManager?.boardAware?.mBoard?.addImagesFile(urls)
    }
    
    func onPlayVideoFile(url: String) {
        awareManager?.boardAware?.mBoard?.addVideoFile(url)
    }
    
    func onShowVideoCtrl(value: Bool) {
        awareManager?.boardAware?.mBoard?.showVideoControl(value)
    }
    
    func onSyncAndReload() {
        awareManager?.boardAware?.mBoard?.syncAndReload()
    }
    
    func onPlayAudio() {
        guard let elem = awareManager?.rtcAware?.mAudioElementId else {
            return
        }
        if (!elem.isEmpty) {
            awareManager?.boardAware?.mBoard?.playAudio(elem)
            // mBoard.seekAudio(mAudioElementId, 120);
            //     mBoard.setAudioVolume(mAudioElementId,0.7f);
        }
    }
    
    func onPauseAudio() {
        guard let elem = awareManager?.rtcAware?.mAudioElementId else {
            return
        }
        if (!elem.isEmpty) {
            awareManager?.boardAware?.mBoard?.pauseAudio(elem)
            // mBoard.getAudioVolume(mAudioElementId);
            awareManager?.boardAware?.mBoard?.getBoardElementList("")
        }
    }
    
    func onAddBackupDomain() {
        awareManager?.boardAware?.mBoard?.addBackupDomain("https://test2.tencent.com", backup: "http://b.hiphotos.baidu.com", priority: 0)
    }
    
    func onRemoveBackupDomain() {
        awareManager?.boardAware?.mBoard?.removeBackupDomain("https://test2.tencent.com", backup:"http://b.hiphotos.baidu.com")
    }
}

protocol IMoreListener {
    //TRTC
    func onEnableAudio(bEnableAudio: Bool)
    func onSwitchAudioRoute(speaker: Bool)
    func onEnableCamera(bEnableCamera: Bool)
    func onSwitchCamera(bFrontCamera: Bool)
    
    //Board(涂鸭操作)
    func onSetDrawEnable(SetDrawEnable: Bool)
    func onSyncDrawEnable(syncDrawEnable: Bool)
    func onStartSnapshot()
    func onNextTextInput(textContent: String, keepFocus: Bool)
    func onTipTextInput(textContent: String)
    func onWipeNumInput(num: Int)
    func onSetHandwritingEnable(syncDrawEnable: Bool)
    func onSetSystemCursorEnable(systemCursorEnable: Bool)
    func onSetToolType(type: Int)
    func onBrushThin(size: Int)
    func onSetTextSize(size: Int)
    func onScale(scale: Int)
    func onSetRatio(scale: String)
    func onSetFitMode(mode: Int)
    func onAddElement(type: Int, url: String)
    func onSetBrushColor(color: Int)
    func onSetTextColor(color: Int)
    func onSetTextStyle(style: Int)
    func onSetBackgroundColore(color: Int)
    func onSetBackgroundImage(path: String)
    func onSetBackgroundH5(url: String)
    func setWipeType(wipeType: Int)
    func onUndo()
    func onRedo()
    func onClear()
    func onReset()
    
    //Board(白板操作)
    func onAddBoard(url: String)
    func onDeleteBoard(boardId: String)
    func onGotoBoard(boardId: String)
    func onPrevStep()
    func onNextStep()
    func onPrevBoard()
    func onNextBoard()
    
    //Board(文件操作)
    func onTransCodeFile(result: TEduBoardTranscodeFileResult)
    func onAddH5File(url: String)
    func onDeleteFile(boardId: String)
    func onGotoFile(boardId: String)
    func onAddImagesFile(urls: Array<String>)
    
    //Video()
    func onPlayVideoFile(url: String)
    func onShowVideoCtrl(value: Bool)
    func onSyncAndReload()
    func onPlayAudio()
    func onPauseAudio()
    func onAddBackupDomain()
    func onRemoveBackupDomain()
}
