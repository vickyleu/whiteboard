//
//  WhiteboardNativeView.swift
//  whiteboard
//
//  Created by vicky Leu on 2021/5/20.
//

import Foundation
import Flutter

public class WhiteboardNativeView : NSObject, FlutterPlatformView {
    let rootView = UIView()
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) {
        super.init()
        let dictionary = args as! Dictionary<String, Any>
        
        let width = (dictionary["width"] as! NSNumber).doubleValue
        let height = (dictionary["height"] as! NSNumber).doubleValue
        rootView.frame = CGRect(x:0, y: 0, width:width, height:height)
        print("frame\(rootView.frame) ")
        rootView.backgroundColor=UIColor.clear
        rootView.tag=Int(viewId)
    }
    
    public func view() -> UIView {
        return rootView
    }
    
    deinit {
        for sub in rootView.subviews {
            sub.removeFromSuperview()
        }
    }
    
}
