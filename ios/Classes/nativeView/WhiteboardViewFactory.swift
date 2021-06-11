//
//  WhiteboardViewFactory.swift
//  whiteboard
//
//  Created by vicky Leu on 2021/5/20.
//

import Foundation
import Flutter
import Masonry

public class WhiteboardViewFactory : NSObject, FlutterPlatformViewFactory,NativeViewLink {
    
    private var nativeViewContainer: WhiteboardNativeView?
    
    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
    if( nativeViewContainer == nil){
    nativeViewContainer =  WhiteboardNativeView(
                frame: frame,
                viewIdentifier: viewId,
                arguments: args)
    }else{
        nativeViewContainer!.update(frame: frame,
                                    viewIdentifier: viewId,
                                    arguments: args)

    }
        return nativeViewContainer!
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    
    func addView(_ view: UIView,layoutParam:(UIView, MASConstraintMaker?) -> ()) {
        guard let root = nativeViewContainer?.rootView else {
            return
        }
        root.addSubview(view)
        view.mas_makeConstraints { (make) in
            layoutParam(root,make)
        }
    }
    
    func removeView(_ view: UIView) {
        view.isHidden = true
        nativeViewContainer?.rootView.bringSubviewToFront(view)
        view.removeFromSuperview()
    }
}
