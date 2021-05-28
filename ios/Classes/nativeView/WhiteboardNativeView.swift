//
//  WhiteboardNativeView.swift
//  whiteboard
//
//  Created by vicky Leu on 2021/5/20.
//

import Foundation
import Flutter

public class WhiteboardNativeView : NSObject, FlutterPlatformView {
    let rootView = UIView.init()
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) {
        super.init()
        rootView.frame = frame //CGRect(x:0, y: 0, width:0, height:0)
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
