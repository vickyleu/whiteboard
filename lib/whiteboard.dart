// @dart=2.9
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:whiteboard/pigeon/PigeonPlatformMessage.dart';

class Whiteboard extends StatefulWidget{
  final WhiteboardController controller;
  Whiteboard({@required this.controller}):assert(controller!=null,"哎呀,仆街");

  @override
  State<StatefulWidget> createState() {
    return _WhiteboardState();
  }

}

class _WhiteboardState extends State<Whiteboard>{
  static const String _uniqueIdentifier = "plugins.whiteboard/_001";
  PhotoViewController _photoViewController=PhotoViewController();
  ValueNotifier<bool> scaleGesture=ValueNotifier(false);
  @override
  void initState(){
    widget.controller._state=this;
    widget.controller._initCallbackHandler();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    if(!Platform.isIOS && !Platform.isAndroid){
      return Container();
    }else{
      return LayoutBuilder(
        builder: (context,cc){
          assert(cc.maxWidth!=double.infinity&&cc.maxHeight!=double.infinity,"必须约束宽高");
          Widget nativeView;
          double width=cc.maxWidth;
          double height=cc.maxHeight;
          creationParams["width"]=width;
          creationParams["height"]=height;
          if(Platform.isIOS){
            nativeView= UiKitView(
              viewType: _uniqueIdentifier,
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: (id){
                widget.controller.onNativeCreated(id);
              },
            );
          }else if(Platform.isAndroid){
            nativeView= AndroidView(
              viewType: _uniqueIdentifier,
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
              onPlatformViewCreated: (id){
                widget.controller.onNativeCreated(id);
              },
              creationParamsCodec: const StandardMessageCodec(),
            );
          }
          return Container(
            width: width,
            height: height,
            child: ClipRect(
              child: IgnorePointer(
                child: nativeView,
                ignoring: false,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  double lastScale=1.0;
  GestureRecognizerFactoryWithHandlers<_MultipleScaleGestureRecognizer> _multiTouch(BoxConstraints cc) {
    return GestureRecognizerFactoryWithHandlers<_MultipleScaleGestureRecognizer>(
          () => _MultipleScaleGestureRecognizer(),
          (_MultipleScaleGestureRecognizer instance) {
        Offset updatePosition;
        bool breakFut=false;
        instance
          ..onStart = (d){
            if(d.pointerCount>=2){
              updatePosition=_photoViewController.position;
              scaleGesture.value=true;
              breakFut=true;
            }
          }
          ..onUpdate =  (ScaleUpdateDetails d){
            if(d.pointerCount>=2){
              final initialWidth=cc.maxWidth;
              final initialHeight=cc.maxHeight;
              final wGap=(initialWidth/2.0)-d.localFocalPoint.dx;
              final hGap=(initialHeight/2.0)-d.localFocalPoint.dy;
              double distX=wGap*d.horizontalScale;
              double distY=hGap*d.verticalScale;

              _photoViewController.updateMultiple(
                position: Offset(
                    distX+updatePosition.dx,
                    distY+updatePosition.dy
                ),
                scale:d.scale*lastScale,
                // rotation:d.rotation,
              );
              updatePosition=Offset(
                  distX,
                  distY
              );
            }
          }
          ..onEnd =  (d){

            final currentScale=_photoViewController.scale;
            final currentRotation=_photoViewController.rotation;

            Offset position;
            double scale;
            double rotation;
            if(currentScale<=1.0){///防止
              position= Offset.zero;
              scale= 1.0;
            }
            if(currentScale>3.0){///防止
              scale= 3.0;
            }
            if(currentRotation!=0){
              rotation=0;
            }
            if(position!=null||rotation!=null){
              lastScale=scale;
              _photoViewController.updateMultiple(
                position:position,
                scale:scale,
                rotation:rotation,
              );
            }else{
              lastScale=currentScale;
            }
            breakFut=false;
            Future.delayed(Duration(milliseconds: 400)).then((value){
              if(breakFut)return;
              scaleGesture.value=false;
            });
          }
          ..dragStartBehavior = DragStartBehavior.down;
      },
    );
  }
  GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer> _doubleTap() {
    return GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
          () => DoubleTapGestureRecognizer(),
          (DoubleTapGestureRecognizer instance) {
        instance
          ..onDoubleTap = (){
            final currentScale=_photoViewController.scale;
            if(currentScale<3.0){
              if(currentScale%1.0==0){
                _photoViewController.scale+=1;
              }else{
                _photoViewController.scale=3;
              }
            }else{
              _photoViewController.scale=1;
            }
          };
      },
    );
  }
}

typedef Future<NilData> ExitRoom(DataModel arg);
typedef NilData HistorySyncCompleted();
typedef Future<DataModel> ReceiveData(ReceivedData arg);
class PigeonFlutterApiImpl extends PigeonFlutterApi {
  ExitRoom exitRoomCallback;
  ReceiveData receiveDataCallback;
  HistorySyncCompleted syncCompletedCallback;
  PigeonFlutterApiImpl({@required this.exitRoomCallback,@required this.receiveDataCallback,@required this.syncCompletedCallback});
  @override
  Future<NilData> exitRoom(DataModel arg) {
    return exitRoomCallback?.call(arg);
  }


  @override
  Future<DataModel> receiveData(ReceivedData arg) {
    final model = receiveDataCallback?.call(arg);
    return (model!=null)?model:DataModel.decode({"code":-1,"msg":"参数错误"});
  }

  @override
  NilData historySyncCompleted() {
   return this.syncCompletedCallback?.call();
  }
}


class WhiteboardController {//extends Listener
  PigeonApi _api =  PigeonApi();

  WhiteboardController();

  Set<Function>_createdListener=Set();
  bool _isCreated=false;
  bool _isLogin=false;
  _WhiteboardState _state;
  PigeonFlutterApi _pigeonFlutterApi;

  Future<void> reset() {
    return _api.reset();
  }
  Future<void> setBackgroundColor(String color) {
    return _api.setBackgroundColor(StringData()..value = color);
  }
  Future<DataModel> joinClass(int classId) {
    return _api.joinClass(JoinClassRequest()
      ..roomId=classId
    ).then((value){
      if(value.code==-1){
        print("joinClass # ${value.msg}");
      }else{
        print("joinClass # 进入教室成功");
      }
      return value;
    }).catchError((onError){
      print("joinClass # ${onError.message.toString()}");
    });
  }
  Future<DataModel> preJoinClass(int appid, String userId, String userSig) {
    return _api.preJoinClass(
        PreJoinClassRequest()
          ..appId=appid
          ..userId=userId
          ..userSig=userSig
    ).then((value){
      if(value.code==-1){
        print("preJoinClass # ${value.msg}");
      }else{
        print("preJoinClass # 初始化教室成功");
      }
      return value;
    }).catchError((onError){
      print("preJoinClass # ${onError.message.toString()}");
    });
  }

  bool isCreated(){
    return _isCreated;
  }

  void _initCallbackHandler(){
    assert(_pigeonFlutterApi!=null,"必须先调用addPigeonApiListener以初始化信令通道");
    PigeonFlutterApi.setup(_pigeonFlutterApi);
  }

  void addPigeonApiListener(PigeonFlutterApi pigeonApiListener){
    _pigeonFlutterApi=pigeonApiListener;
  }

  void dispose() {
    _api.quitClass();
    _pigeonFlutterApi=null;
    _isCreated=false;
    PigeonFlutterApi.setup(null);
    _state=null;
  }

  void onNativeCreated(int id) {
    _isCreated=true;
    _alreadyCreated();
  }

  void addCreatedListener(Function() created) {
    _createdListener.add(created);
  }

  void receiveMsg(Uint8List msg) {
    _api.receiveData(ReceivedData()..data=msg);
  }

  Future<void> addBackgroundImage(String url) {
    return _api.addBackgroundImage(StringData()..value= url);
  }

  void _alreadyCreated(){
    if(_isCreated&&_isLogin)
      _createdListener.forEach((element) {
        element();
      });
  }

  void isLoginSuccess() {
    _isLogin=true;
    _alreadyCreated();
  }


}


class _MultipleScaleGestureRecognizer extends ScaleGestureRecognizer{
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}