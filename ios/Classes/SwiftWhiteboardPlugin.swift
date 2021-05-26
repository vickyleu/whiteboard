import Flutter
import UIKit

public class SwiftWhiteboardPlugin: NSObject, FlutterPlugin,FLTPigeonApi {
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
                    model.msg = "初始化课堂成功"
                    completion(model,nil)
                }else{
                    model.code = -1
                    model.msg = "初始化课堂失败:\(errMsg)"
                    completion(model,nil)
                }
            }
        }else{
            model.code = -1
            model.msg = "初始化失败:参数有误"
            completion(model,nil)
        }
    }

    public func joinClass(_ arg: FLTJoinClassRequest?, completion: @escaping (FLTDataModel?, FlutterError?) -> Void) {
        let model = FLTDataModel.init()
        if(arg != nil){
            let initParam = TEduBoardInitParam.init()
            initParam.timSync = true;
            initParam.brushColor = UIColor.init(red: 255, green: 0, blue: 0, alpha: 1.0)
            initParam.smoothLevel = 0 //用于指定笔迹平滑级别，默认值0.1，取值[0, 1]
            let classroomOption = TICClassroomOption.init()
            classroomOption.classId = UInt32(arg!.roomId!.intValue)
            classroomOption.boardInitParam = initParam

            awareManager.joinClass(classroomOption){ (module, errCode, errMsg) in
                if(errCode == 1){
                    model.code = 1
                    model.msg = "进入课堂成功:\(arg!.roomId!.intValue)"
                    completion(model,nil)
                }else if(errCode == 10015) {
                    model.code = -1
                    model.msg = "课堂不存在:\(arg!.roomId!.intValue),\(errMsg)"
                    completion(model,nil)
                }else{
                    model.code = -1
                    model.msg = "进入课堂失败:\(arg!.roomId!.intValue),\(errMsg)"
                    completion(model,nil)
                }
            }
        }else{

            model.code = -1
            model.msg = "进入课堂失败:参数有误"
            completion(model,nil)
        }
    }

    public func quitClass(_ completion: @escaping (FLTDataModel?, FlutterError?) -> Void) {
        awareManager.quitClassroom()
        let model = FLTDataModel.init()
        model.code = 1
        model.msg = "退出课堂成功"
        completion(model,nil)
    }

    public func receive(_ arg: FLTReceivedData?, completion: @escaping (FLTDataModel?, FlutterError?) -> Void) {
        if(arg?.data != nil){
            let byte = [UInt8](arg!.data!.data)
            awareManager.receiveData(data:byte) { (module, errCode, errMsg) in
                if(errCode == 1){
                    let model = FLTDataModel.init()
                    model.code = 1
                    model.msg = "传值成功"
                    completion(model,nil)
                }else{
                    let model = FLTDataModel.init()
                    model.code = -1
                    model.msg = "传值失败:\(errMsg)"
                    completion(model,nil)
                }
            }
        }else{
            let model = FLTDataModel.init()
            model.code = -1
            model.msg = "传值失败:参数错误"
            completion(model,nil)
        }
    }
}
