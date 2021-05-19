import Flutter
import UIKit

public class SwiftWhiteboardPlugin: NSObject, FlutterPlugin,FLTPigeonApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    FLTPigeonApiSetup(registrar.messenger(), SwiftWhiteboardPlugin.init());
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
