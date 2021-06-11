//
//  AwareManager.swift
//  whiteboard
//
//  Created by vicky Leu on 2021/5/19.
//

import Foundation
import Masonry
import WebKit

public class AwareManager: NSObject, BoardAwareInterface {
    let mTicManager: TICManager = TICManager.sharedInstance()
    var boardAware: BoardAware?
    var nativeViewLink: NativeViewLink?
    private let settingCallback = MySettingCallback()
    public var flutterApi: FLTPigeonFlutterApi?
    var drawerType = DrawerType.drawGraffiti
    var isHaveBackgroundImage=false
    public override init() {
        super.init()
        settingCallback.also { (it: MySettingCallback) in
            it.awareManager = self
        }
    }
    


    func preJoinClassroom(arg: FLTPreJoinClassRequest, ticCallback: @escaping TICCallback) {
        boardAware?.destroy()
        boardAware = BoardAware()
        mTicManager.`init`(Int32(arg.appId!.intValue), userId: arg.userId, userSig: arg.userSig)
        mTicManager.sendCommandBlock = { (ext, d) in
            let data = FLTReceivedData()
            data.data = FlutterStandardTypedData(bytes: d!)
            data.extension = ext
            print("receive嘿嘿嘿嘿嘿嘿嘿嘿呵呵呵呵呵呵::::\(data.data)")
            self.flutterApi?.receive(data, completion: { model, _ in
                if (model.code?.intValue == -1) {
                    print("同步失败了:${it.msg}")
                } else {
                    guard  let wtf: TEduBoardController = self.boardAware?.mBoard else {
                        return
                    }
                    //                    wtf.addAckData(data) ////
                }
            })
        }
        //1、设置白板的回调
        let mbcallback = MyBoardCallback(self)
        boardAware?.mBoardCallback = mbcallback
        
        ticCallback(TICModule.TICMODULE_IMSDK, 1, "预创建参数初始化成功")
    }
    
    func joinClass(_ classroomOption: TICClassroomOption, ticCallback: @escaping TICCallback) {
        classroomOption.boardDelegate = boardAware?.mBoardCallback
        mTicManager.initTEduBoard(classroomOption)
        guard let boardController = mTicManager.getBoardController() else {
            ticCallback(TICModule.TICMODULE_IMSDK, -1, "白板初始化不成功")
            return
        }
        boardController.setGlobalBackgroundColor(UIColor.clear)
        boardAware?.mBoard = boardController
        classroomOption.boardDelegate?.onTEBInit()
        
        
        ///腾讯的Android和iOS回调不同步,这里手动调用,保证在业务层处理逻辑是一样的.反正回调中我会判断画板是否已经准备就绪的
        ticCallback(TICModule.TICMODULE_IMSDK, 1, "创建课堂 成功, 房间号 \(classroomOption.classId)")
    }
    
    //////
    
    func drawGraffiti() {
        guard (drawerType != DrawerType.drawGraffiti) else {
            return
        }
        drawerType = DrawerType.drawGraffiti
        boardAware?.mBoard?.setToolType(TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_PEN)
    }
    
    func drawLine() {
        guard (drawerType != DrawerType.drawLine) else {
            return
        }
        drawerType = DrawerType.drawLine
        boardAware?.mBoard?.setToolType(TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_LINE)
    }
    
    func drawSquare() {
        guard (drawerType != DrawerType.drawSquare) else {
            return
        }
        drawerType = DrawerType.drawSquare
        boardAware?.mBoard?.setToolType(TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_RECT)
    }
    
    func drawCircular() {
        guard (drawerType != DrawerType.drawCircular) else {
            return
        }
        drawerType = DrawerType.drawCircular
        boardAware?.mBoard?.setToolType(TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_OVAL)
    }
    
    func drawText() {
        guard (drawerType != DrawerType.drawText) else {
            return
        }
        drawerType = DrawerType.drawText
        boardAware?.mBoard?.setTextStyle(TEduBoardTextStyle.TEDU_BOARD_TEXT_STYLE_NORMAL)
        boardAware?.mBoard?.setToolType(TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_TEXT)
    }
    
    func eraserDrawer() {
        guard (drawerType != DrawerType.eraserDrawer) else {
            return
        }
         drawerType = DrawerType.eraserDrawer
        let arr : Array<NSNumber> = [
            NSNumber(value:TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_LINE.rawValue),
            NSNumber(value:TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_OVAL.rawValue),
            NSNumber(value:TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_MOUSE.rawValue),
            NSNumber(value:TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_PEN.rawValue),
            NSNumber(value:TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_RECT.rawValue),
            NSNumber(value:TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_TEXT.rawValue),
        ]
        boardAware?.mBoard?.setToolType(TEduBoardToolType.TEDU_BOARD_TOOL_TYPE_ERASER)
        boardAware?.mBoard?.setEraseLayerType(arr)
    }
    
    func rollbackDraw() {
        boardAware?.mBoard?.undo()
    }
    
    func wipeDraw() {
        boardAware?.mBoard?.clearDraws()
        isHaveBackgroundImage = false
    }

    func removeBackgroundImage(){
        boardAware?.mBoard?.clearBackground(true, andSelected: false)
        isHaveBackgroundImage = false
    }


    func setToolColor(color:UIColor){
        switch drawerType {
        case .drawGraffiti:
            boardAware?.mBoard?.setBrush(color)
            break
        case .drawLine:
            boardAware?.mBoard?.setBrush(color)
            break
        case .drawSquare:
            boardAware?.mBoard?.setBrush(color)
            break
        case .drawCircular:
            boardAware?.mBoard?.setBrush(color)
            break
        case .drawText:
            boardAware?.mBoard?.setTextColor(color)
            break
        case .eraserDrawer:
            break
        }
    }
    func setToolSize(size:Int){
        switch drawerType {
        case .drawGraffiti:
            boardAware?.mBoard?.setBrushThin(UInt32(size))
            break
        case .drawLine:
            boardAware?.mBoard?.setBrushThin(UInt32(size))
            break
        case .drawSquare:
            boardAware?.mBoard?.setBrushThin(UInt32(size))
            break
        case .drawCircular:
            boardAware?.mBoard?.setBrushThin(UInt32(size))
            break
        case .drawText:
            boardAware?.mBoard?.setTextSize(UInt32(size))
            break
        case .eraserDrawer:
            break
        }
    }
    
    //////
    
    func onTEBSyncData(data: String) {
        let model = FLTReceivedData()
        model.data = FlutterStandardTypedData(bytes: data.data(using: .utf8)!)
        model.extension = "TXWhiteBoardExt"
        print("receive嘿嘿嘿嘿嘿嘿嘿嘿呵呵呵呵呵呵:::\(model.data)")
        self.flutterApi?.receive(model, completion: { model, _ in
            if (model.code?.intValue == -1) {
                print("同步失败了:${it.msg}")
            }
        })
    }
    
    func reset() {
        boardAware?.reset()
        drawerType = DrawerType.drawGraffiti
        isHaveBackgroundImage = false
    }
    
    func setBackgroundColor(_ color: UIColor) {
        boardAware?.setBackgroundColor(color)
    }
    
    func addBackgroundImage(url: String) {
        boardAware?.mBoard?.setBackgroundImage(url, mode: TEduBoardImageFitMode.TEDU_BOARD_IMAGE_FIT_MODE_CENTER)
        isHaveBackgroundImage = true
    }
    
    func quitClassroom() {
        boardAware?.destroy()
        isHaveBackgroundImage = false
        mTicManager.quitClassroom(true, callback: { _, errCode, errMsg in
            if (errCode == -1) {
                print("mother fucker  退出白板失败:\(errCode)  \(errMsg)")
                self.removeBoardView()
            } else {
                self.removeBoardView()
            }
        })
        mTicManager.sendCommandBlock = nil
        flutterApi?.exitRoom(FLTDataModel().also { (v: FLTDataModel) in
            v.code = 1
            v.msg = "退出成功"
            v.data = nil
        }) { (_, error: Error?) in
            
        }
    }
    
    
    func receiveData(data: [UInt8], callback: @escaping TICCallback) {
        do {
            let string = try String(bytes: data, encoding: .utf8)
            try boardAware?.mBoard?.addSyncData(string)
            callback(TICModule.TICMODULE_IMSDK, 1, "同步数据成功")
        } catch let error {
            callback(TICModule.TICMODULE_IMSDK, -1, "addSyncData failed: \(error)")
        }
    }
    
    
    /////
    func onTEBHistroyDataSyncCompleted() {
        flutterApi?.historySyncCompleted { _, _ in
            
        }
        guard let board = boardAware?.mBoard else {
            return
        }
        guard let currentBoard = board.getCurrentBoard() else {
            return
        }
        let currentFile = board.getCurrentFile()
        print("DataSyncCompleted currentBoard:\(currentBoard) currentFile:\(currentFile)")
    }
    
    func addBoardView() {
        guard let board = boardAware?.mBoard else {
            return
        }
        guard let boardView: WKWebView = board.getBoardRenderView() as? WKWebView else {
            return
        }
        print("addBoardView::::::\(boardView)")
        if #available(iOS 11.0, *) {
            boardView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        boardView.scrollView.contentInset = .zero
        boardView.scrollView.backgroundColor = UIColor.clear
        boardView.isOpaque = false
        boardView.backgroundColor = UIColor.clear
        
        nativeViewLink?.addView(boardView) { (root: UIView, make: MASConstraintMaker?) in
            make?.top.equalTo()(root)
            make?.left.equalTo()(root)
            make?.right.equalTo()(root)
            make?.bottom.equalTo()(root)
        }
    }
    
    func removeBoardView() {
        guard let board = boardAware?.mBoard else {
                return
            }
        guard let boardView = board.getBoardRenderView() else {
            return
        }
        nativeViewLink?.removeView(boardView)
        board.unInit()
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
    
    func onTextComponentStatusChange(_ id: String?, _ status: String?) {
        //
    }
    
    func receiveIds(id: String, type: Int) {
        //rtcAware?.mImgsFid
    }
}

enum DrawerType {
    case drawGraffiti
    case drawLine
    case drawSquare
    case drawCircular
    case drawText
    case eraserDrawer
}
