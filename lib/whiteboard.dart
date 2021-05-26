// @dart=2.9
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
  @override
  void initState(){
    widget.controller._state=this;
    widget.controller._initCallbackHandler();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    if(Platform.isIOS){
      return UiKitView(
        viewType: _uniqueIdentifier,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id){
          widget.controller.onNativeCreated(id);
        },
      );
    }else if(Platform.isAndroid){
      return PlatformViewLink(
        viewType: _uniqueIdentifier,
        surfaceFactory:(BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: _uniqueIdentifier,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: StandardMessageCodec(),
          )..addOnPlatformViewCreatedListener((id){
            params.onPlatformViewCreated(id);
            widget.controller.onNativeCreated(id);
          })
            ..create();
        },
      );
    }else{
      return Container();
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
}

typedef Future<void> ExitRoom(DataModel arg);
typedef Future<DataModel> ReceiveData(ReceivedData arg);
class PigeonFlutterApiImpl extends PigeonFlutterApi {
  ExitRoom exitRoomCallback;
  ReceiveData receiveDataCallback;
  PigeonFlutterApiImpl({@required this.exitRoomCallback,@required this.receiveDataCallback});
  @override
  Future<void> exitRoom(DataModel arg) {
    return exitRoomCallback?.call(arg);
  }

  @override
  Future<DataModel> receiveData(ReceivedData arg) {
    print("mother fucker receiveData ${arg?.data}");
    final model = receiveDataCallback?.call(arg);
    return (model!=null)?model:DataModel.decode({"code":-1,"msg":"参数错误"});
  }
}


class WhiteboardController {//extends Listener
  PigeonApi api =  PigeonApi();

  Set<Function>_createdListener=Set();
  bool _isCreated=false;
  _WhiteboardState _state;
  PigeonFlutterApi _pigeonFlutterApi;

  Future<DataModel> joinClass(int classId) {
    return api.joinClass(JoinClassRequest()..roomId=classId).then((value){
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
    return api.preJoinClass(
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
    api.quitClass();
    _pigeonFlutterApi=null;
    _isCreated=false;
    PigeonFlutterApi.setup(null);
    _state=null;
  }

  void onNativeCreated(int id) {
    _isCreated=true;
    _createdListener.forEach((element) {
      element();
    });
  }

  void addCreatedListener(Function() created) {
    _createdListener.add(created);
  }

  void receiveMsg(Uint8List msg) {
    api.receiveData(ReceivedData()..data=msg);
  }


}