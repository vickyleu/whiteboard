import 'dart:async';
import 'dart:collection';
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
import 'package:whiteboard_example/ImageExt.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: MyApp(),
    );
  }

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
  var initialOptionPosition=0;
  final userAvailableMap=HashMap<String,Map>();
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
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top,SystemUiOverlay.bottom]);
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

    widget.trtcCloud.setGSensorMode(TRTCCloudDef.TRTC_GSENSOR_MODE_UIAUTOLAYOUT);

    enterRoom(appID,userId,userSig,classId);
  }
  initSDK() async {
    WidgetsFlutterBinding.ensureInitialized();

    final secret="c063ff07273be5bd38996d09a623c10485c7c009b139f69259e1d204084eb54d";
    final appid=1400492258;

    final int classId= 123;
    V2TIMManager timManager = TencentImSDKPlugin.v2TIMManager;
    String pwdStr =  UserSigGenerate.genTestSig(appid, secret, userId );
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
        syncCompletedCallback: (){
          _whiteboardSyncCompleted();
          // initTRTC(appid, userId, pwdStr,classId);
        }
    ));
    widget._whiteboardController.addCreatedListener((){
      print("有点卵用吗");
      _created(classId,appid,userId,pwdStr);
    });
    await timManager.initSDK(
      sdkAppID: appid,
      loglevel: LogLevel.V2TIM_LOG_DEBUG,
      listener: V2TimSDKListener(
        onConnectSuccess: (){
          _login(){
            TencentImSDKPlugin.v2TIMManager
                .login(
              userID: userId,
              userSig: pwdStr,
            )
                .then((res) async {
              if (res.code == 0) {
                print("======腾讯IM登录成功=====${res}");
                ///设置离线消息通道,businessID为腾讯后台生成的id,必须是登录成功后设置,不然无效
                widget._whiteboardController.isLoginSuccess();
              } else {
                print("======腾讯IM登录失败=====${res}");
              }
            });
          }
          _login();
        },
        onKickedOffline: (){
          widget._whiteboardController.dispose();
        },
        onConnectFailed: (code,msg){

        },
      ),
    );
    timManager.getMessageManager().addAdvancedMsgListener(listener: new V2TimAdvancedMsgListener(
        onRecvNewMessage: (msg){
          if(msg.groupID!=null&&msg.customElem.extension=="TXWhiteBoardExt"){
            final receive = msg.customElem.data;
            var outputAsUint8List = new Uint8List.fromList(receive.codeUnits);
            widget._whiteboardController.receiveMsg(outputAsUint8List);
          }
        }
    ));
  }
  void enterRoom(int appID,String userId,String userSig,int classId) {
    widget.trtcCloud.registerListener(onRtcListener);
    widget.trtcCloud.enterRoom(
        TRTCParams(
            sdkAppId: appID, //应用Id
            userId: userId, // 用户Id
            userSig: userSig, // 用户签名
            roomId: classId), //房间Id
        TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL).then((value){
      print("进房成功没有");
    }).catchError((onError){
      print("进房异常了");
    });
  }
  _whiteboardSyncCompleted(){
    widget._whiteboardController.reset().then((value) async {
      await widget._whiteboardController.addBackgroundImage("https://5b0988e595225.cdn.sohucs.com/q_70,c_zoom,w_640/images/20180409/3ba0912dbd894d9fb25ca074046ee4f4.jpeg");
      widget._whiteboardController.setBackgroundColor("#F5F6FA");
    });

  }

  _created(int groupId,int appid,String userId,String userSig){
    widget._whiteboardController.preJoinClass(appid,userId,userSig).then((value){
      if(value.code!=-1){
        final enterRoom= (){
          TencentImSDKPlugin.v2TIMManager.joinGroup(groupID:  "$groupId", message: "board group$groupId").then((value){
            TencentImSDKPlugin.v2TIMManager.getGroupManager().inviteUserToGroup(groupID: "$groupId", userList: [remoteUserId]);
            widget._whiteboardController.joinClass(groupId);
          });
        };
        TencentImSDKPlugin.v2TIMManager.createGroup(groupType:
        // "AVChatRoom"
        // "Meeting"
        "Public"
            , groupName: "interact group",groupID: "$groupId").then((value) async {
          if(value.code==0){
            enterRoom();
          }else if(value.code==10021){
            print("该课堂已被他人创建，请\"加入课堂\"");
            enterRoom();
          }else  if(value.code==10025){//	群组 ID 已被使用，并且操作者为群主，可以直接使用。
            print("该课堂已创建，请\"加入课堂\"");
            enterRoom();
          }else{
            final msg="创建课堂失败, 房间号：${groupId} errCode:${value.code} msg:${value.desc}";
            print(msg);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ValueKey remoteKey = ValueKey(remoteUserId);
    ValueKey selfkey = ValueKey(userId);
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeLeft
    ]);


    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      body: Row(
        children:()sync*{
          yield Container(
            width: 100,
            color: Colors.transparent,
            height: double.infinity,
            child: ClipRect(
              child: Row(
                children:()sync*{
                  print("userAvailableMapuserAvailableMap::${userAvailableMap.toString()}");
                  if(widget.trtcCloud!=null&&userAvailableMap.keys.length>0){
                    final selfMap=userAvailableMap[userId];
                    final remoteMap=userAvailableMap[remoteUserId];
                    if(selfMap!=null&&selfMap['visible']){
                      yield Container(
                        key: selfkey,
                        width: 120,
                        height: 200,
                        color: Colors.black,
                        padding: EdgeInsets.all(5),
                        child: TRTCCloudVideoView(
                            key: selfkey,
                            onViewCreated: (viewId) {
                              widget.trtcCloud.startLocalPreview(true, viewId);
                            }),
                      );
                    }
                    if(remoteMap!=null&&remoteMap['visible']){
                      yield Container(
                        key: remoteKey,
                        width: 120,
                        height: 200,
                        color: Colors.black,
                        padding: EdgeInsets.all(5),
                        child: TRTCCloudVideoView(
                            key: remoteKey,
                            onViewCreated: (viewId) {
                              widget.trtcCloud.startRemoteView(
                                  remoteUserId,
                                  remoteMap['type'] == 'video'?
                                  TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL :
                                  TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
                                  viewId);
                            }),
                      );
                    }
                  }
                }().toList(),
              ),
            ),
          );
          yield Expanded(child: Container(
            color: Color(0xFFF5F6FA),
            padding: EdgeInsets.only(right: ()sync*{
              final right=MediaQuery.of(context).padding.right;
              if(right>0){
                yield right;
              }else{
                yield 15.toDouble();
              }
            }().last),
            child: Row(
              children: [
                Expanded(child: LayoutBuilder(
                  builder: (context,cc){
                    return Container(
                      width: cc.maxWidth,
                      height: cc.maxHeight,
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          Positioned.fill(child: Container(
                            // padding:EdgeInsets.only(top: 36,bottom: 36),
                            child: Whiteboard(
                              controller: widget._whiteboardController,
                            ),
                          )),
                          Positioned(child: Container(
                            color: Colors.transparent,
                            child: Row(
                              children: [
                                Padding(padding: EdgeInsets.only(right: 10),
                                  child: CupertinoButton(
                                    minSize:0,padding:EdgeInsets.zero,
                                    child: Container(
                                      width:76,
                                      height:36,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:MainAxisAlignment.center,
                                          children: [
                                            Padding(padding:EdgeInsets.only(right: 6) ,
                                              child: ImageViewLocal(
                                                  placeHolder: "icon_exit_whiteboard",
                                                  size: 18,
                                                  height: 18,
                                                  fit: BoxFit.fill
                                              ),),
                                            Text("退出",style: TextStyle(fontSize: 14,color: Color(0XFF666666)),)
                                          ],
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                    ), onPressed: (){
                                      _exitWhiteboard();
                                }),),
                                CupertinoButton(
                                    minSize:0,padding:EdgeInsets.zero,
                                    child: Container(
                                      width:76,
                                      height:36,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:MainAxisAlignment.center,
                                          children: [
                                            Padding(padding:EdgeInsets.only(right: 6) ,
                                              child: ImageViewLocal(
                                                  placeHolder: "icon_change_background",
                                                  size: 18,
                                                  height: 18,
                                                  fit: BoxFit.fill
                                              ),),
                                            Text("背景图",style: TextStyle(fontSize: 14,color: Color(0XFF666666)),)
                                          ],
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                    ), onPressed: (){

                                })
                              ],
                            ),
                          ),left: 15,top: 15,)
                        ],
                      ),
                    );
                  },
                ),
                ),
                Container(
                  width: 50,
                  height: double.infinity,
                  margin: EdgeInsets.only(top: 15,bottom: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: LayoutBuilder(
                    builder: (context,cc){
                      return Container(
                        padding: EdgeInsets.only(top: cc.maxHeight*(4/345.0),bottom: cc.maxHeight*(4/345.0)),
                        child: Column(
                          children: ()sync*{
                            final icons=["icon_graffiti","icon_line","icon_square","icon_circular","icon_text","icon_eraser",
                              "icon_rollback","icon_wipe"];
                            yield* icons.asMap().map((key,element) {
                              return MapEntry(key, CupertinoButton(
                                  child:Container(
                                    height: cc.maxHeight*(((345.0-4*2)/icons.length)/(345.0)),
                                    width: double.infinity,
                                    child: Center(
                                      child: Container(
                                        width: cc.maxHeight*(22/345.0),
                                        height: cc.maxHeight*(22/345.0),
                                        child: LayoutBuilder(
                                          builder: (context,cc){
                                            return ImageViewLocal(
                                                placeHolder: "$element${initialOptionPosition==key?"_selected":""}",
                                                size: cc.maxWidth,
                                                height: cc.maxHeight,
                                                fit: BoxFit.fill
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(top: cc.maxHeight*(10/345.0),bottom: cc.maxHeight*(10/345.0)),
                                  ),
                                  minSize: 0,padding: EdgeInsets.zero,
                                  onPressed: (){
                                    if(key<icons.length-2){
                                      initialOptionPosition=key;
                                      setState(() {

                                      });
                                    }
                                  }));
                            }).values;
                          }().toList(),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ));
        }().toList(),
      ),
    );
  }


  /// 事件回调
  onRtcListener(TRTCCloudListener type, dynamic param) {
    if([
      TRTCCloudListener.onStatistics,
      TRTCCloudListener.onSpeedTest,
      TRTCCloudListener.onNetworkQuality,
    ].contains(type))return;
    print("type::${type}  param:${param}");
    if (userAvailableMap.length >= 2) {
      return;
    }
    if (type == TRTCCloudListener.onError) {
      showErrordDialog(param['errMsg']);
    }
    bool isOpenMic=true;
    bool isOpenCamera=true;
    if(type == TRTCCloudListener.onEnterRoom){
      print("===== 自己进房 ===${param}");
      userAvailableMap[userId]= {'userId': param,'type': 'video','visible': isOpenCamera};
      if (isOpenMic) {
        //开启麦克风
        widget.trtcCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH);
      }
      if(isOpenCamera){
        //设置美颜效果
        widget.txBeautyManager.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_PITU);
        widget.txBeautyManager.setBeautyLevel(6);
      }
      this.setState(() {});
    }else
      // 远端用户进房
    if (type == TRTCCloudListener.onRemoteUserEnterRoom) {
      print("===== 远端用户进房 ===${param}");
      //当自己是电话发起者需要统计电话时长
      userAvailableMap[remoteUserId]={'userId': param, 'type': 'video', 'visible': false};
      this.setState(() {});
    }
    // // 远端用户离开房间
    // if (type == TRTCCloudListener.onRemoteUserLeaveRoom) {
    //   print("====用户退出了房间");
    //   widget.trtcCloud.exitRoom();
    // }
    //远端用户是否存在可播放的主路画面（一般用于摄像头）
    if (type == TRTCCloudListener.onUserVideoAvailable) {
      String userId = param['userId'];
      // 根据状态对视频进行开启和关闭
      if (param['available']) {
        final map= userAvailableMap[remoteUserId];
        if(map["type"]=="video"){
          map['visible']=true;
        }
      } else {
        final map= userAvailableMap[remoteUserId];
        if(map["type"]=="video"){
          widget.trtcCloud.stopRemoteView(
              userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL);
          map['visible']=false;
        }
      }
      this.setState(() {});
    }
    //辅流监听
    if (type == TRTCCloudListener.onUserSubStreamAvailable) {
      String userId = param["userId"];
      //视频可用
      if (param["available"]) {
        userAvailableMap[remoteUserId]={'userId': userId, 'type': 'subStream', 'visible': true};
      } else {
        final map= userAvailableMap[remoteUserId];
        if(map["type"]=="subStream"){
          widget.trtcCloud.stopRemoteView(
              userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
          userAvailableMap.remove(remoteUserId);
        }
      }
      this.setState(() {});
    }
  }

  showErrordDialog(String error){}

  void _exitWhiteboard() {

  }




}

