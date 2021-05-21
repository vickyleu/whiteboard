//
//  WhiteboardViewFactory.swift
//  whiteboard
//
//  Created by vicky Leu on 2021/5/20.
//

import Foundation
import Flutter

public class WhiteboardViewFactory : NSObject, FlutterPlatformViewFactory,NativeViewLink {
    
    private var nativeViewContainer: WhiteboardNativeView?
    
    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        nativeViewContainer =  WhiteboardNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args)
        return nativeViewContainer!
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    
    func addView(_ view: UIView) {
        view.backgroundColor = UIColor.red
        nativeViewContainer?.rootView.addSubview(view)
    }
    
    func removeView(_ view: UIView) {
        view.isHidden = true
        nativeViewContainer?.rootView.bringSubviewToFront(view)
        view.removeFromSuperview()
    }
}
