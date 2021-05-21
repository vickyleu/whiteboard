//
//  AwareManager.swift
//  whiteboard
//
//  Created by vicky Leu on 2021/5/19.
//

import Foundation

public class AwareManager : NSObject, BoardAwareInterface{
    
    
    var mTicManager : TICManager?
    
    var rtcAware: RtcAware?
    var boardAware: BoardAware?
    
    var nativeViewLink:NativeViewLink?

    private let settingCallback = MySettingCallback()
    
    public override init() {
        super.init()
        settingCallback.also{(it : MySettingCallback) in
            it.awareManager = self
        }
    }
    
    func pinit(appid:Int) {
        mTicManager = TICManager.sharedInstance()
        mTicManager?.`init`(Int32(appid), callback: { (module, code, errMsg) in
            
        })
    }
    
    func login(userId: String, userSig: String, ticCallback: @escaping TICCallback) {
        mTicManager?.login(userId, userSig: userSig, callback:ticCallback)
    }
    
    func joinClass(_ classroomOption:TICClassroomOption,ticCallback: @escaping TICCallback) {
        boardAware?.destroy()
        rtcAware?.destroy()
        boardAware=BoardAware()
        rtcAware = RtcAware(mTicManager?.getTRTCCloud())
        rtcAware?.initRTC()
        //2.白板
        guard let boardController =  mTicManager?.getBoardController() else { return }
        boardAware?.mBoard = boardController
        //1、设置白板的回调
        boardAware?.mBoardCallback = MyBoardCallback(self)
        classroomOption.boardDelegate = boardAware?.mBoardCallback
        mTicManager?.createClassroom(Int32(classroomOption.classId), classScene: classroomOption.classScene){ (module, errCode, errMsg) in
            if(errCode == 0){
                print("创建课堂 成功, 房间号：\(classroomOption.classId)")
                self.mTicManager?.joinClassroom(classroomOption, callback:ticCallback)
            }else if(errCode == 10021){
                print("该课堂已被他人创建，请\"加入课堂\"")
                self.mTicManager?.joinClassroom(classroomOption,  callback:ticCallback)
            }else if (errCode == 10025) {
                print("该课堂已创建，请\"加入课堂\"")
                self.mTicManager?.joinClassroom(classroomOption,  callback:ticCallback)
            } else {
                let msg="创建课堂失败, 房间号：\(classroomOption.classId) errCode:\(errCode) msg:\(errMsg)"
                print(msg)
                ticCallback(module,errCode,msg)
            }
        }
    }
    
    func quitClassroom(_ clearBoard: Bool, ticCallback: @escaping TICCallback) {
        mTicManager?.quitClassroom(clearBoard, callback: ticCallback)
        boardAware?.destroy()
    }
    
    /////
    func onTEBHistroyDataSyncCompleted() {
        guard let board = boardAware?.mBoard else { return }
        guard let currentBoard = board.getCurrentBoard() else { return }
        let currentFile = board.getCurrentFile()
        print("DataSyncCompleted currentBoard:\(currentBoard) currentFile:\(currentFile)")
    }
    
    func addBoardView() {
        guard let boardView = boardAware?.mBoard?.getBoardRenderView() else { return }
        nativeViewLink?.addView(boardView)
    }
    
    func removeBoardView() {
        guard let boardView = boardAware?.mBoard?.getBoardRenderView() else { return }
        nativeViewLink?.removeView(boardView)
    }
    
    func setCanUndo(_ canUndo: Bool) {
        settingCallback.setCanUndo(canUndo)
    }
    
    func setCanRedo(_ canredo: Bool) {
        settingCallback.setCanRedo(canredo)
    }
    
    func addFile(_ fileId: String?) -> TEduBoardFileInfo? {
        return nil
    }
    
    func onTextComponentStatusChange(_ id: String?,_ status: String?) {
        //
    }
    
}
