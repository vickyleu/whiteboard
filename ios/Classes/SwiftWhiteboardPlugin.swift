import Flutter
import UIKit

public class SwiftWhiteboardPlugin: NSObject, FlutterPlugin,FLTPigeonApi {
    public func isHaveBackgroundImage(_ completion: @escaping (FLTBoolData?, FlutterError?) -> Void) {
        let bd=FLTBoolData()
        bd.value=NSNumber(value: awareManager.isHaveBackgroundImage)
        completion(bd,nil)
    }
    
    public func removeBackgroundImage(_ completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        awareManager.removeBackgroundImage()
        completion(FLTNilData(),nil)
    }
    
    public func setToolColor(_ arg: FLTStringData?, completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        if(arg != nil){
            awareManager.setToolColor(color: UIColor.init(hex: arg!.value!))
        }
        completion(FLTNilData(),nil)
    }
    
    public func setToolSize(_ arg: FLTIntData?, completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        if(arg != nil){
            awareManager.setToolSize(size: arg!.value!.intValue)
        }
        completion(FLTNilData(),nil)
    }
    
    public func drawGraffiti(_ completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        awareManager.drawGraffiti()
        completion(FLTNilData(),nil)
    }
    
    public func drawLine(_ completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        awareManager.drawLine()
        completion(FLTNilData(),nil)
    }
    
    public func drawSquare(_ completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        awareManager.drawSquare()
        completion(FLTNilData(),nil)
    }
    
    public func drawCircular(_ completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        awareManager.drawCircular()
        completion(FLTNilData(),nil)
    }
    
    public func drawText(_ completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        awareManager.drawText()
        completion(FLTNilData(),nil)
    }
    
    public func eraserDrawer(_ completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        awareManager.eraserDrawer()
        completion(FLTNilData(),nil)
    }
    
    public func rollbackDraw(_ completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        awareManager.rollbackDraw()
        completion(FLTNilData(),nil)
    }
    
    public func wipeDraw(_ completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        awareManager.wipeDraw()
        completion(FLTNilData(),nil)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let boardFactory = WhiteboardViewFactory.init()
        let plugin = SwiftWhiteboardPlugin.init()
        registrar.register(boardFactory, withId: "plugins.whiteboard/_001")
        let flutterApi = FLTPigeonFlutterApi(binaryMessenger: registrar.messenger())
        FLTPigeonApiSetup(registrar.messenger(), plugin);
        plugin.awareManager.flutterApi=flutterApi
        plugin.awareManager.nativeViewLink=boardFactory
    }

    let  awareManager = AwareManager()

    public func preJoinClass(_ arg: FLTPreJoinClassRequest?, completion: @escaping (FLTDataModel?, FlutterError?) -> Void) {
        let model = FLTDataModel.init()
        if(arg != nil){
            awareManager.preJoinClassroom(arg: arg!) { module, errCode, errMsg in
                if(errCode == 1){
                    model.code = 1
                    model.msg = "?????????????????????"
                    completion(model,nil)
                }else{
                    model.code = -1
                    model.msg = "?????????????????????:\(errMsg)"
                    completion(model,nil)
                }
            }
        }else{
            model.code = -1
            model.msg = "???????????????:????????????"
            completion(model,nil)
        }
    }

    public func joinClass(_ arg: FLTJoinClassRequest?, completion: @escaping (FLTDataModel?, FlutterError?) -> Void) {
        let model = FLTDataModel.init()
        if(arg != nil){
            let initParam = TEduBoardInitParam.init()
            initParam.timSync = false;
            initParam.globalBackgroundColor = UIColor.clear
            initParam.brushColor = UIColor.init(red: 255, green: 0, blue: 0, alpha: 1.0)
            initParam.smoothLevel = 0 //??????????????????????????????????????????0.1?????????[0, 1]
            let classroomOption = TICClassroomOption.init()
            classroomOption.classId = UInt32(arg!.roomId!.intValue)
            classroomOption.boardInitParam = initParam

            awareManager.joinClass(classroomOption){ (module, errCode, errMsg) in
                if(errCode == 1){
                    model.code = 1
                    model.msg = "??????????????????:\(arg!.roomId!.intValue)"
                    completion(model,nil)
                }else if(errCode == 10015) {
                    model.code = -1
                    model.msg = "???????????????:\(arg!.roomId!.intValue),\(errMsg)"
                    completion(model,nil)
                }else{
                    model.code = -1
                    model.msg = "??????????????????:\(arg!.roomId!.intValue),\(errMsg)"
                    completion(model,nil)
                }
            }
        }else{

            model.code = -1
            model.msg = "??????????????????:????????????"
            completion(model,nil)
        }
    }

    public func quitClass(_ completion: @escaping (FLTDataModel?, FlutterError?) -> Void) {
        awareManager.quitClassroom()
        let model = FLTDataModel.init()
        model.code = 1
        model.msg = "??????????????????"
        completion(model,nil)
    }
    public func reset(_ completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        awareManager.reset()
        completion(FLTNilData(),nil)
    }
   
    public func setBackgroundColor(_ arg: FLTStringData?, completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        if(arg?.value != nil){
            awareManager.setBackgroundColor(UIColor.init(hex: arg!.value!))
        }
        completion(FLTNilData(),nil)
    }
    
    public func addBackgroundImage(_ arg: FLTStringData?, completion: @escaping (FLTNilData?, FlutterError?) -> Void) {
        if(arg?.value != nil){
            awareManager.addBackgroundImage(url:arg!.value!)
        }
        completion(FLTNilData(),nil)
    }

    public func receive(_ arg: FLTReceivedData?, completion: @escaping (FLTDataModel?, FlutterError?) -> Void) {
        if(arg?.data != nil){
            let byte = [UInt8](arg!.data!.data)
            awareManager.receiveData(data:byte) { (module, errCode, errMsg) in
                if(errCode == 1){
                    let model = FLTDataModel.init()
                    model.code = 1
                    model.msg = "????????????"
                    completion(model,nil)
                }else{
                    let model = FLTDataModel.init()
                    model.code = -1
                    model.msg = "????????????:\(errMsg)"
                    completion(model,nil)
                }
            }
        }else{
            let model = FLTDataModel.init()
            model.code = -1
            model.msg = "????????????:????????????"
            completion(model,nil)
        }
    }
}
