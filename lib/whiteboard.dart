// @dart=2.9
import 'dart:io';

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

class WhiteboardController {//extends Listener
  PigeonApi api =  PigeonApi();

  Set<Function>_createdListener=Set();
  bool _isInit=false;
  bool _isLogin=false;
  bool _isCreated=false;
  _WhiteboardState _state;
  PigeonFlutterApi _pigeonFlutterApi;
  Future<DataModel> init(int appID){
    WidgetsFlutterBinding.ensureInitialized();///先调用这一句
    return api.pinit(InitRequest()..appID=appID).then((value){
      if(value.code==-1){
        print("login # ${value.msg}");
      }else{
        print("login # 初始化成功");
        _isInit=true;
      }
      return value;
    }).catchError((onError){
      print("login # ${onError.message.toString()}");
      return null;
    });
  }

  Future<DataModel> login(String userID,String userSig) {
    return api.login(LoginRequest()
      ..userID=userID
      ..userSig=userSig
    ).then((value){
      if(value.code==-1){
        print("login # ${value.msg}");
      }else{
        print("login # 初始化成功");
        _isLogin=true;
      }
      return value;
    }).catchError((onError){
      print("login # ${onError.message.toString()}");
    });
  }


  Future<DataModel> joinClass() {
    api.joinClass(JoinClassRequest()..roomId=123);
  }

  bool isInit(){
    return _isInit;
  }
  bool isCreated(){
    return _isCreated;
  }
  bool isLogin(){
    return _isInit&&_isLogin;
  }
  void _initCallbackHandler(){
    PigeonFlutterApi.setup(_pigeonFlutterApi);
  }

  void addPigeonApiListener(PigeonFlutterApi pigeonApiListener){
    _pigeonFlutterApi=pigeonApiListener;
  }

  void dispose() {
    // _pigeonFlutterApi=null;
    _isInit=false;
    _isLogin=false;
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


}