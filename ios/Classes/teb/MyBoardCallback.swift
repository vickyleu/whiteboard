//
// Created by vicky Leu on 2021/5/19.
//

import Foundation

public class  MyBoardCallback :NSObject, TEduBoardDelegate{

     let TAG = "MyBoardCallback"
    
    
    let boardAwareCallback:BoardAwareInterface
    
    init(_ boardAwareCallback: BoardAwareInterface) {
        self.boardAwareCallback=boardAwareCallback
    }

    public func onTEBError(_ code: TEduBoardErrorCode, msg: String!) {
        print("\(TAG) onTEBError:\(code)|\(msg)")
    }
    
    public func onTEBWarning(_ code: TEduBoardWarningCode, msg: String!) {
        print("\(TAG) onTEBWarning:\(code)|\(msg)")
    }
    
    public func onTEBInit() {
        boardAwareCallback.addBoardView()
    }
    
    public func onTEBHistroyDataSyncCompleted() {
        boardAwareCallback.onTEBHistroyDataSyncCompleted()
    }
    
    public func onTEBSyncData(_ data: String!) {
        
    }
    
    public func onTEBUndoStatusChanged(_ canUndo: Bool) {
        boardAwareCallback.setCanUndo(canUndo)
    }
    
    public func onTEBRedoStatusChanged(_ canRedo: Bool) {
        boardAwareCallback.setCanRedo(canRedo)
    }
    
    public func onTEBImageStatusChanged(_ boardId: String!, url: String!, status: TEduBoardImageStatus) {
        print("\(TAG) onTEBImageStatusChanged:\(boardId)|\(url)|\(status)")
    }
    
    public func onTEBSetBackgroundImage(_ url: String!) {
        print("\(TAG) onTEBSetBackgroundImage:\(url)")
    }
    
    public func onTEBAddImageElement(_ url: String!) {
        print("\(TAG) onTEBAddImageElement:\(url)")
    }
    
    public func onTEBAddElement(_ elementId: String!, url: String!) {
    }
    
  
    
    public func onTEBBackgroundH5StatusChanged(_ boardId: String!, url: String!, status: TEduBoardBackgroundH5Status) {
        print("\(TAG) onTEBBackgroundH5StatusChanged:\(boardId)|\(url)|\(status)")
    }
    
    public func onTEBAddBoard(_ boardIds: [Any]!, fileId: String!) {
        print("\(TAG) onTEBAddBoard:\(boardIds)|\(fileId)")
    }
    
    public func onTEBDeleteBoard(_ boardIds: [Any]!, fileId: String!) {
        print("\(TAG) onTEBDeleteBoard:\(boardIds)|\(fileId)")
    }
    
    public func onTEBGotoBoard(_ boardId: String!, fileId: String!) {
        print("\(TAG) onTEBGotoBoard:\(boardId)|\(fileId)")
    }
    
    public func onTEBGotoStep(_ currentStep: UInt32, totalStep: UInt32) {
        print("\(TAG) onTEBGotoStep:\(currentStep)|\(totalStep)")
    }
    
    public func onTEBRectSelected() {
        print("\(TAG) onTEBRectSelected")
    }
    
    public func onTEBRefresh() {
        print("\(TAG) onTEBRefresh")
    }
    
    public func onTEBSnapshot(_ path: String!, errorCode code: TEduBoardErrorCode, errorMsg msg: String!) {
        print("\(TAG) onTEBSnapshot:\(path)|\(code)|\(msg)")
    }
    
    public func onTEBFileTranscodeProgress(_ result: TEduBoardTranscodeFileResult!, path: String!, errorCode: String!, errorMsg: String!) {
    }
    
    public func onTEBAddTranscodeFile(_ fileId: String!) {
        print("\(TAG) onTEBAddTranscodeFile:\(fileId)")
    }
    
    public func onTEBDeleteFile(_ fileId: String!) {
    }
    
    public func onTEBSwitchFile(_ fileId: String!) {
    }
    
    public func onTEBFileUploadProgress(_ path: String!, currentBytes: Int32, totalBytes: Int32, uploadSpeed: Int32, percent: Float) {
        print("\(TAG) onTEBFileUploadProgress:\(path)|\(currentBytes)|\(totalBytes)|\(uploadSpeed)|\(percent)")
    }
    
    public func onTEBFileUploadStatus(_ path: String!, status: TEduBoardUploadStatus, errorCode: Int32, errorMsg: String!) {
        print("\(TAG) onTEBFileUploadStatus:\(path)|\(status)|\(errorCode)|\(errorMsg)")
    }
    
    public func onTEBH5FileStatusChanged(_ fileId: String!, status: TEduBoardH5FileStatus) {
    }
    
    public func onTEBVideoStatusChanged(_ fileId: String!, status: TEduBoardVideoStatus, progress: CGFloat, duration: CGFloat) {
        print("\(TAG) onTEBVideoStatusChanged:\(fileId)|\(status)|\(progress)|\(duration)")
    }
    
    public func onTEBAudioStatusChanged(_ elementId: String!, status: TEduBoardAudioStatus, progress: CGFloat, duration: CGFloat) {
        print("\(TAG) onTEBAudioStatusChanged:\(elementId)|\(status)|\(progress)|\(duration)")
    }
    
    public func onTEBAddImagesFile(_ fileId: String!) {
        print("\(TAG) onTEBAddImagesFile:\(fileId)")
        _ = boardAwareCallback.addFile(fileId)
    }
    
    public func onTEBH5PPTStatusChanged(_ fileId: String!, status: TEduBoardH5PPTStatus, message: String!) {}
    

    // # onTEBDeleteElement
    public func onTEBRemoveElement(_ elementIds: [Any]!) {
    }
}
