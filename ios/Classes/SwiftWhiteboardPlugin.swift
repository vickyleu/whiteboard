import Flutter
import UIKit

public class SwiftWhiteboardPlugin: NSObject, FlutterPlugin,FLTPigeonApi {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let boardFactory = WhiteboardViewFactory.init()
        let plugin = SwiftWhiteboardPlugin.init()
        registrar.register(boardFactory, withId: "plugins.whiteboard/_001")
        FLTPigeonApiSetup(registrar.messenger(), plugin);
        plugin.awareManager.nativeViewLink=boardFactory
    }
    
    let  awareManager = AwareManager()
    
    public func pinit(_ arg: FLTInitRequest?, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> FLTDataModel? {
        if(arg != nil){
            awareManager.pinit(appid:arg!.appID!.intValue)
            let model = FLTDataModel.init()
            model.code = 1
            model.msg = "初始化成功"
            return model
        }else{
            let model = FLTDataModel.init()
            model.code = -1
            model.msg = "初始化不成功"
            return model
        }
    }
    
    public func login(_ arg: FLTLoginRequest?, completion: @escaping (FLTDataModel?, FlutterError?) -> Void) {
        if(arg != nil){
            awareManager.login(userId: arg!.userID!, userSig: arg!.userSig!) { (module, errCode, errMsg) in
                if(errCode == 0){
                    let model = FLTDataModel.init()
                    model.code = 1
                    model.msg = "\(arg!.userID!)登录成功"
                    completion(model,nil)
                }else{
                    let model = FLTDataModel.init()
                    model.code = -1
                    model.msg = "\(arg!.userID!)登录失败:\(errMsg)"
                    completion(model,nil)
                }
            }
        }else{
            let model = FLTDataModel.init()
            model.code = -1
            model.msg = "登录失败:参数错误"
            completion(model,nil)
        }
    }
    
    public func joinClass(_ arg: FLTJoinClassRequest?, completion: @escaping (FLTDataModel?, FlutterError?) -> Void) {
        if(arg != nil){
            let initParam = TEduBoardInitParam.init()
            initParam.brushColor = UIColor.init(red: 255, green: 0, blue: 0, alpha: 1.0)
            initParam.smoothLevel = 0 //用于指定笔迹平滑级别，默认值0.1，取值[0, 1]
            let classroomOption = TICClassroomOption.init()
            classroomOption.classId = UInt32(arg!.roomId!.intValue)
            classroomOption.boardInitParam = initParam
            let model = FLTDataModel.init()
            awareManager.joinClass(classroomOption){ (module, errCode, errMsg) in
                if(errCode == 0){
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
            let model = FLTDataModel.init()
            model.code = -1
            model.msg = "进入课堂失败:参数有误"
            completion(model,nil)
        }
    }
    
    public func quitClass(_ completion: @escaping (FLTDataModel?, FlutterError?) -> Void) {
        awareManager.quitClassroom(true) { (module, errCode, errMsg) in
            if(errCode == 0){
                let model = FLTDataModel.init()
                model.code = 1
                model.msg = "退出课堂成功"
                completion(model,nil)
            }else{
                let model = FLTDataModel.init()
                model.code = -1
                model.msg = "退出课堂失败,\(errMsg)"
                completion(model,nil)
            }
        }
    }
}
