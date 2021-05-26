import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_message_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:whiteboard/UserSigGenerate.dart';
import 'package:whiteboard/pigeon/PigeonPlatformMessage.dart';
import 'package:whiteboard/whiteboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  WhiteboardController _whiteboardController=WhiteboardController();
  MyApp();
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeRight,
    ]);
    initSDK();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  initSDK() async {
    WidgetsFlutterBinding.ensureInitialized();
    final secret="f31f05a9292434dd66ff368eed72647029daca9e9237fec99aa6669904d8d117";
    final appid=1400501664;
    final userId="1008611";
    final int classId= 123;
    V2TIMManager timManager = TencentImSDKPlugin.v2TIMManager;
    widget._whiteboardController.addPigeonApiListener(new PigeonFlutterApiImpl(
        exitRoomCallback: (arg)async{
          if(mounted){
            if(Navigator.of(context).canPop()){
              Navigator.of(context).pop();
            }
          }
        },
        receiveDataCallback: (arg)async{
          final conversation = await TencentImSDKPlugin.v2TIMManager.getConversationManager().getConversation(conversationID: "group_$classId");
          String receive = new String.fromCharCodes(arg.data);
          await TencentImSDKPlugin.v2TIMManager.v2TIMMessageManager
              .sendCustomMessage(data: receive, receiver: "$classId", groupID: "$classId",extension: "TXWhiteBoardExt",
            priority: 1,isExcludedFromUnreadCount:true,
            // offlinePushInfo: OfflinePushInfo()
          );
          return null;
        }
    ));
    await timManager.initSDK(
      sdkAppID: appid,
      loglevel: LogLevel.V2TIM_LOG_DEBUG,
      listener: V2TimSDKListener(
        onConnectSuccess: (){
          _login(){
            String pwdStr =  UserSigGenerate.genTestSig(appid, secret, userId );
            TencentImSDKPlugin.v2TIMManager
                .login(
              userID: userId,
              userSig: pwdStr,
            )
                .then((res) async {
              if (res.code == 0) {
                print("======腾讯IM登录成功=====${res}");
                ///设置离线消息通道,businessID为腾讯后台生成的id,必须是登录成功后设置,不然无效

                _register(appid, pwdStr, userId,classId);
              } else {
                print("======腾讯IM登录失败=====${res}");
              }
            });
          }
          _login();
        },
        onKickedOffline: (){

        },
        onConnectFailed: (code,msg){

        },
      ),
    );
  }

  _created(int groupId,int appid,String userId,String userSig){
    widget._whiteboardController.preJoinClass(appid,userId,userSig).then((value){
      if(value.code!=-1){
        final enterRoom= (){
          TencentImSDKPlugin.v2TIMManager.joinGroup(groupID:  "$groupId", message: "board group$groupId").then((value){
            widget._whiteboardController.joinClass(groupId);
          });
        };
        TencentImSDKPlugin.v2TIMManager.createGroup(groupType:
        // "AVChatRoom"
        "Meeting"
        // "Public"
            , groupName: "interact group",groupID: "$groupId").then((value){
          enterRoom();
        });
      }
    });

  }
  Future _register(int appid, String userSig, String userId, int groupId) async {
    TencentImSDKPlugin.v2TIMManager.getMessageManager().addAdvancedMsgListener(listener: new V2TimAdvancedMsgListener(
        onRecvNewMessage: (msg){
          if(msg.groupID!=null&&msg.customElem.extension=="TXWhiteBoardExt"){
            final receive = msg.customElem.data;
            var outputAsUint8List = new Uint8List.fromList(receive.codeUnits);
            widget._whiteboardController.receiveMsg(outputAsUint8List);
          }
        }
    ));
    widget._whiteboardController.addCreatedListener(_created(groupId,appid,userId,userSig));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Whiteboard(
            controller: widget._whiteboardController,
          ),
        ),
      ),
    );
  }
}

