import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';
import 'package:whiteboard/UserSigGenerate.dart';
import 'package:whiteboard/pigeon/PigeonPlatformMessage.dart';
import 'package:whiteboard/whiteboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  WhiteboardController _whiteboardController=WhiteboardController();
  //TRTC
  TRTCCloud trtcCloud;
  TXDeviceManager txDeviceManager;
  TXBeautyManager txBeautyManager;
  TXAudioEffectManager txAudioManager;

  MyApp();
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final userId="1008611";
  final remoteUserId="1008612";
  final userList=List<Map>.empty(growable: true);
  @override
  void initState() {
    initSDK();

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // widget._whiteboardController.dispose();
    super.dispose();
  }
  Future<void> initTRTC(int appID,String userId,String userSig,int classId) async {
    widget.trtcCloud = await TRTCCloud.sharedInstance();
    // 获取设备管理模块
    widget.txDeviceManager = widget.trtcCloud.getDeviceManager();
    // 获取美颜管理对象
    widget.txBeautyManager = widget.trtcCloud.getBeautyManager();
    // 获取音效管理类 TXAudioEffectManager
    widget.txAudioManager = widget.trtcCloud.getAudioEffectManager();
    // 注册事件回调
    widget.trtcCloud.registerListener(onRtcListener);
    widget.trtcCloud.setGSensorMode(TRTCCloudDef.TRTC_GSENSOR_MODE_UIAUTOLAYOUT);

    enterRoom(appID,userId,userSig,classId);
  }
  initSDK() async {
    WidgetsFlutterBinding.ensureInitialized();
    final secret="f31f05a9292434dd66ff368eed72647029daca9e9237fec99aa6669904d8d117";
    final appid=1400501664;

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
              .sendCustomMessage(data: receive, receiver: null, groupID: "$classId",extension: "TXWhiteBoardExt",
            priority: 1,isExcludedFromUnreadCount:true,
            // offlinePushInfo: OfflinePushInfo()
          );
          return DataModel()..code=1
            ..msg="接收成功了";
        },
        syncCompletedCallback: _whiteboardSyncCompleted
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
                initTRTC(appid, userId, pwdStr,classId);
                _register(appid, pwdStr, userId,classId);
              } else {
                print("======腾讯IM登录失败=====${res}");
              }
            });
          }
          _login();
        },
        onKickedOffline: _whiteboardSyncCompleted,
        onConnectFailed: (code,msg){

        },
      ),
    );
  }
  void enterRoom(int appID,String userId,String userSig,int classId) {
    widget.trtcCloud.enterRoom(
        TRTCParams(
            sdkAppId: appID, //应用Id
            userId: userId, // 用户Id
            userSig: userSig, // 用户签名
            roomId: classId), //房间Id
        TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
  }
  void _whiteboardSyncCompleted(){
    widget._whiteboardController.reset();
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
        // "Meeting"
        "Public"
            , groupName: "interact group",groupID: "$groupId").then((value){
          enterRoom();

          //     if (errCode == 10021) {
//                        print("该课堂已被他人创建，请\"加入课堂\"")
//                        mTicManager.joinClassroom(classroomOption, ticCallback)
//                    } else if (errCode == 10025) {
//                        print("该课堂已创建，请\"加入课堂\"")
//                        mTicManager.joinClassroom(classroomOption, ticCallback)
//                    } else {
//                        val msg="创建课堂失败, 房间号：${classroomOption.classId} errCode:$errCode msg:$errMsg"
//                        print(msg)
//                        ticCallback.onError(module,errCode,msg)
//                    }
//                }

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
    ValueKey remoteKey = ValueKey(remoteUserId);
    ValueKey selfkey = ValueKey(userId);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft
    ]);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Container(
              height: 50,
              child: Row(
                children:()sync*{
                  yield Container(
                    key: selfkey,
                    width: 120,
                    height: 200,
                    color: Colors.black,
                    child: TRTCCloudVideoView(
                        key: selfkey,
                        onViewCreated: (viewId) {
                          widget.trtcCloud.startLocalPreview(true, viewId);
                        }),
                  );
                  yield Container(
                    key: remoteKey,
                    width: 120,
                    height: 200,
                    color: Colors.black,
                    child: TRTCCloudVideoView(
                        key: remoteKey,
                        onViewCreated: (viewId) {
                          widget.trtcCloud.startRemoteView(
                              remoteUserId,
                              // remoteMap['type'] == 'video'
                              //     ?
                              // TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL
                              //     :
                              TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
                              viewId);
                        }),
                  );
                }().toList(),
              ),
            ),
            Expanded(child: Container(
              color: Color(1090938470655),
              padding: EdgeInsets.only(top: 10,bottom: 10),
              child: Center(
                child: Whiteboard(
                  controller: widget._whiteboardController,
                ),
              ),
            )),
            SafeArea(child: Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ()sync*{
                  yield* {
                    "蒜头王八\nStanding By":"http://5b0988e595225.cdn.sohucs.com/images/20181205/cdbf0f53bce34a45a85f3ef2702b74e2.jpeg",
                    "Elon Marx\nStanding By":"https://5b0988e595225.cdn.sohucs.com/q_70,c_zoom,w_640/images/20180409/3ba0912dbd894d9fb25ca074046ee4f4.jpeg"
                  }.entries
                      .map((value)=>
                      Expanded(child: Center(
                        child: CupertinoButton(
                            minSize: 0,
                            padding: EdgeInsets.zero,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 100,maxHeight: 60),
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius:BorderRadius.circular(10),

                              ),
                              child: Center(
                                child: Text(value.key,textAlign: TextAlign.center,),
                              ),
                            ), onPressed: (){
                          widget._whiteboardController.reset();
                          widget._whiteboardController.addBackgroundImage(value.value);
                        }),
                      ),flex: 1,));
                }().toList(),
              ),
              height: 50,
            ),top: false,)
          ],
        ),
      ),
    );
  }


  /// 事件回调
  onRtcListener(type, param) {
    print("type::${type}  param:${param}");
    if (userList.length >= 2) {
      return;
    }
    if (type == TRTCCloudListener.onError) {
      showErrordDialog(param['errMsg']);
    }
    if (type == TRTCCloudListener.onEnterRoom) {
    }
    // 远端用户进房
    if (type == TRTCCloudListener.onRemoteUserEnterRoom) {
      print("===== 远端用户进房 ===${param}");
      //当自己是电话发起者需要统计电话时长
      if(widget.isCallIn != "1"){
        DateTime now = new DateTime.now();
        startStamp = (now.millisecondsSinceEpoch*0.001).floor();
      }

      userList.add({'userId': param, 'type': 'video', 'visible': false});
      screenUserList = getScreenList(userList);
      if(userList.length <=1 ){
        return ;
      }else{
        isEnter = true;
      }
      this.setState(() {});
      meetModel.setList(userList);
    }
    // 远端用户离开房间
    if (type == TRTCCloudListener.onRemoteUserLeaveRoom) {
      print("这里接受了事件2");
      print("====用户退出了房间");
      if(widget.isCallIn != "1") {
        DateTime now = new DateTime.now();
        int endTime = (now.millisecondsSinceEpoch*0.001).floor();
        int duration = endTime-startStamp;
        sendMsgToAnother(duration);
      }

      trtcCloud.exitRoom();
      Application.router.pop(context);
      // String userId = param['userId'];
      // for (var i = 0; i < userList.length; i++) {
      //   if (userList[i]['userId'] == userId) {
      //     userList.removeAt(i);
      //   }
      // }
      // screenUserList = getScreenList(userList);
      // this.setState(() {});
      // meetModel.setList(userList);
    }
    //远端用户是否存在可播放的主路画面（一般用于摄像头）
    if (type == TRTCCloudListener.onUserVideoAvailable) {
      String userId = param['userId'];
      // 根据状态对视频进行开启和关闭
      if (param['available']) {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i]['userId'] == userId &&
              userList[i]['type'] == 'video') {
            userList[i]['visible'] = true;
          }
        }
      } else {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i]['userId'] == userId &&
              userList[i]['type'] == 'video') {
            trtcCloud.stopRemoteView(
                userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL);
            userList[i]['visible'] = false;
          }
        }
      }
      screenUserList = getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    }

    //辅流监听
    if (type == TRTCCloudListener.onUserSubStreamAvailable) {
      String userId = param["userId"];
      //视频可用
      if (param["available"]) {
        userList.add({'userId': userId, 'type': 'subStream', 'visible': true});
      } else {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i]['userId'] == userId &&
              userList[i]['type'] == 'subStream') {
            trtcCloud.stopRemoteView(
                userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
            userList.removeAt(i);
          }
        }
      }
      screenUserList = getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    }
  }

  showErrordDialog(String error){}




}

