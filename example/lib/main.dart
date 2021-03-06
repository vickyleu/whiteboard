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
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
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

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  WhiteboardController _whiteboardController = WhiteboardController();
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
  final userId = "1008611";
  final remoteUserId = "20210403103215917";
  var initialOptionPosition = 0;
  final userAvailableMap = HashMap<String, Map>();

  var mToolType="icon_graffiti";
  var mToolSizeRatio=1;//1~100

  var mCameraOpen=true;
  var mMicOpen=true;

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
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    _exitWhiteboard();

    super.dispose();
  }

  Future<void> initTRTC(
      int appID, String userId, String userSig, int classId) async {
    widget.trtcCloud = await TRTCCloud.sharedInstance();
    // ????????????????????????
    widget.txDeviceManager = widget.trtcCloud.getDeviceManager();
    // ????????????????????????
    widget.txBeautyManager = widget.trtcCloud.getBeautyManager();
    // ????????????????????? TXAudioEffectManager
    widget.txAudioManager = widget.trtcCloud.getAudioEffectManager();
    // ??????????????????

    widget.trtcCloud
        .setGSensorMode(TRTCCloudDef.TRTC_GSENSOR_MODE_UIAUTOLAYOUT);

    enterRoom(appID, userId, userSig, classId);
  }

  initSDK() async {
    WidgetsFlutterBinding.ensureInitialized();

    final secret ="c063ff07273be5bd38996d09a623c10485c7c009b139f69259e1d204084eb54d";
    final appid = 1400492258;///tencent appid

    final int classId = 456;
    V2TIMManager timManager = TencentImSDKPlugin.v2TIMManager;
    String pwdStr = UserSigGenerate.genTestSig(appid, secret, userId);
    widget._whiteboardController.addPigeonApiListener(
        new PigeonFlutterApiImpl(exitRoomCallback: (arg) async {
          if (mounted) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
          return NilData();
        }, receiveDataCallback: (arg) async {
          final conversation = await TencentImSDKPlugin.v2TIMManager
              .getConversationManager()
              .getConversation(conversationID: "group_$classId");
          String receive = new String.fromCharCodes(arg.data);
          await _sendCustomMessage(receive, classId,remoteUserId);
          return DataModel()
            ..code = 1
            ..msg = "???????????????";
        }, syncCompletedCallback: () {
          _whiteboardSyncCompleted();
          initTRTC(appid, userId, pwdStr, classId);
          return NilData();
        }));
    widget._whiteboardController.addCreatedListener(() {
      print("???????????????");
      _created(classId, appid, userId, pwdStr);
    });
    await timManager.initSDK(
      sdkAppID: appid,
      loglevel: LogLevel.V2TIM_LOG_DEBUG,
      listener: V2TimSDKListener(
        onConnectSuccess: () {
          _login() {
            TencentImSDKPlugin.v2TIMManager
                .login(
              userID: userId,
              userSig: pwdStr,
            )
                .then((res) async {
              if (res.code == 0) {
                print("======??????IM????????????=====${res}");

                ///????????????????????????,businessID????????????????????????id,??????????????????????????????,????????????
                widget._whiteboardController.isLoginSuccess();
              } else {
                print("======??????IM????????????=====${res}");
              }
            });
          }

          _login();
        },
        onKickedOffline: () {
          widget._whiteboardController.dispose();
        },
        onConnectFailed: (code, msg) {},
      ),
    );
    timManager.getMessageManager().addAdvancedMsgListener(
        listener: new V2TimAdvancedMsgListener(onRecvNewMessage: (msg) {
          if (msg.groupID != null &&
              msg.customElem.extension == "TXWhiteBoardExt") {
            final receive = msg.customElem.data;
            var outputAsUint8List = new Uint8List.fromList(receive.codeUnits);
            widget._whiteboardController.receiveMsg(outputAsUint8List);
          }
        }));
  }

  Future<V2TimValueCallback<V2TimMessage>> _sendCustomMessage(String receive, int classId, String remoteUserId) {
    // return TencentImSDKPlugin
    //     .v2TIMManager
    //     .getMessageManager()
    //     .sendCustomMessage(
    //   data: receive,
    //   groupID: "$classId",
    //   priority: 1,
    //   isExcludedFromUnreadCount: true,
    //   receiver: "$remoteUserId",
    // );
    return TencentImSDKPlugin.v2TIMManager.v2TIMMessageManager
            .sendCustomMessage(
          data: receive,
          // receiver: remoteUserId,
          receiver: null,
          groupID: "$classId",
          extension: "TXWhiteBoardExt",
          priority: 1,
          isExcludedFromUnreadCount: true,
          // offlinePushInfo: OfflinePushInfo()
        );
  }

  void enterRoom(int appID, String userId, String userSig, int classId) {
    widget.trtcCloud.registerListener(onRtcListener);
    widget.trtcCloud
        .enterRoom(
        TRTCParams(
            sdkAppId: appID, //??????Id
            userId: userId, // ??????Id
            userSig: userSig, // ????????????
            roomId: classId), //??????Id
        TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL)
        .then((value) {
      print("??????????????????");

    }).catchError((onError) {
      print("???????????????");
    });
  }

  _whiteboardSyncCompleted() {
    widget._whiteboardController.setBackgroundColor("#F5F6FA");
    _switchBackgroundVisible();
  }

  _created(int groupId, int appid, String userId, String userSig) {
    widget._whiteboardController
        .preJoinClass(appid, userId, userSig)
        .then((value) {
      if (value.code != -1) {
        final enterRoom = () {
          TencentImSDKPlugin.v2TIMManager
              .joinGroup(groupID: "$groupId", message: "board group$groupId")
              .then((value) {
            TencentImSDKPlugin.v2TIMManager.getGroupManager().inviteUserToGroup(
                groupID: "$groupId", userList: [remoteUserId]);
            widget._whiteboardController.joinClass(groupId);
          });
        };
        TencentImSDKPlugin.v2TIMManager
            .createGroup(
            groupType:
            // "AVChatRoom"
            "Meeting",
            // "Public",
            groupName: "interact group",
            groupID: "$groupId")
            .then((value) async {
          if (value.code == 0) {
            enterRoom();
          } else if (value.code == 10021) {
            print("?????????????????????????????????\"????????????\"");
            enterRoom();
          } else if (value.code == 10025) {
            //	?????? ID ???????????????????????????????????????????????????????????????
            print("????????????????????????\"????????????\"");
            enterRoom();
          } else {
            final msg =
                "??????????????????, ????????????${groupId} errCode:${value.code} msg:${value.desc}";
            print(msg);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeLeft]);

    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      resizeToAvoidBottomInset: false,
      body: Container(
          color: Color(0xFFF5F6FA),
          padding: EdgeInsets.only(
              right: () sync* {
                final right = MediaQuery.of(context).padding.right;
                if (right > 0) {
                  yield right;
                } else {
                  yield 15.toDouble();
                }
              }()
                  .last),
          child: Row(
            children: [
              Container(
                width: 140,
                color: Color(0xFFE1E2E6),
                height: double.infinity,
                padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                child: _profileArea(),
              ),
              Expanded(child: LayoutBuilder(
                builder: (context, cc) {
                  return Container(
                    width: cc.maxWidth,
                    height: cc.maxHeight,
                    color: Colors.transparent,
                    child: Container(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              child: Whiteboard(
                                controller: widget._whiteboardController,
                              ),
                              color: Colors.transparent,
                            ),
                          ),
                          Positioned(
                            child: Container(
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: CupertinoButton(
                                        minSize: 0,
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          width: 76,
                                          height: 36,
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                  EdgeInsets.only(right: 6),
                                                  child: ImageViewLocal(
                                                      placeHolder:
                                                      "icon_exit_whiteboard",
                                                      size: 18,
                                                      height: 18,
                                                      fit: BoxFit.fill),
                                                ),
                                                Text(
                                                  "??????",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0XFF666666)),
                                                )
                                              ],
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(20)),
                                        ),
                                        onPressed: () {
                                          _exitWhiteboard();
                                        }),
                                  ),
                                  CupertinoButton(
                                      minSize: 0,
                                      padding: EdgeInsets.zero,
                                      child: Container(
                                        width: 76,
                                        height: 36,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                EdgeInsets.only(right: 6),
                                                child: ImageViewLocal(
                                                    placeHolder:
                                                    "icon_background_visible",
                                                    size: 18,
                                                    height: 18,
                                                    fit: BoxFit.fill),
                                              ),
                                              Text(
                                                "?????????",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0XFF666666)),
                                              )
                                            ],
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(20)),
                                      ),
                                      onPressed: () {
                                        _switchBackgroundVisible();
                                      })
                                ],
                              ),
                            ),
                            left: 15,
                            top: 15,
                          )
                        ],
                      ),
                    ),
                  );
                },
              )),
              Container(
                width: 50,
                height: double.infinity,
                margin: EdgeInsets.only(top: 15, bottom: 15, left: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: LayoutBuilder(
                  builder: (context, cc) {
                    return Container(
                      padding: EdgeInsets.only(
                          top: cc.maxHeight * (4 / 345.0),
                          bottom: cc.maxHeight * (4 / 345.0)),
                      child: Column(
                        children: () sync* {
                          yield* listCommand.asMap().map((key, element) {
                            return MapEntry(
                                key,
                                CupertinoButton(
                                    child: Container(
                                      height: cc.maxHeight *
                                          (((345.0 - 4 * 2) / listCommand.length) /
                                              (345.0)),
                                      width: double.infinity,
                                      child: Center(
                                        child: Container(
                                          width: cc.maxHeight * (22 / 345.0),
                                          height: cc.maxHeight * (22 / 345.0),
                                          child: LayoutBuilder(
                                            builder: (context, cc) {
                                              return ImageViewLocal(
                                                  placeHolder:
                                                  "$element${initialOptionPosition == key ? "_selected" : ""}",
                                                  size: cc.maxWidth,
                                                  height: cc.maxHeight,
                                                  fit: BoxFit.fill);
                                            },
                                          ),
                                        ),
                                      ),
                                      padding: EdgeInsets.only(
                                          top: cc.maxHeight * (10 / 345.0),
                                          bottom: cc.maxHeight * (10 / 345.0)),
                                    ),
                                    minSize: 0,
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      _executeCommand(element);
                                      if (key < listCommand.length - 2) {
                                        initialOptionPosition = key;
                                        setState(() {});
                                      }
                                    }));
                          }).values;
                        }()
                            .toList(),
                      ),
                    );
                  },
                ),
              )
            ],
          )),
    );
  }
  final List<String> listCommand=[
    "icon_graffiti","icon_line","icon_square","icon_circular","icon_text","icon_eraser",
    "icon_rollback","icon_wipe"
  ];
  Future<void> _executeCommand(String command) async {
    if(mToolType==command&&mToolType!="icon_eraser"){

    }
    switch(command){
      case "icon_graffiti":
        await widget._whiteboardController.drawGraffiti();
        break;
      case  "icon_line":
        await widget._whiteboardController.drawLine();
        break;
      case "icon_square":
        await widget._whiteboardController.drawSquare();
        break;
      case  "icon_circular":
        await widget._whiteboardController.drawCircular();
        break;
      case "icon_text":
        await widget._whiteboardController.drawText();
        break;
      case "icon_eraser":
        await widget._whiteboardController.eraserDrawer();
        break;
      case "icon_rollback":
        await widget._whiteboardController.rollbackDraw();
        return;
        break;
      case "icon_wipe":
        await widget._whiteboardController.wipeDraw();
        return;
        break;
    }
    mToolType=command;
  }
  Widget _profileArea() {
    ValueKey remoteKey = ValueKey(remoteUserId);
    ValueKey selfkey = ValueKey(userId);
    Widget self;
    Widget remote;
    if (widget.trtcCloud != null && userAvailableMap.keys.length > 0) {
      final selfMap = userAvailableMap[userId];
      final remoteMap = userAvailableMap[remoteUserId];
      if (selfMap != null && selfMap['visible']) {
        self = TRTCCloudVideoView(
            key: selfkey,
            onViewCreated: (viewId) {
              widget.trtcCloud.startLocalPreview(true, viewId);
            });
      }
      if (remoteMap != null && remoteMap['visible']) {
        remote = TRTCCloudVideoView(
            key: remoteKey,
            onViewCreated: (viewId) {
              widget.trtcCloud.startRemoteView(
                  remoteUserId,
                  remoteMap['type'] == 'video'
                      ? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL
                      : TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
                  viewId);
            });
      }
    }

    return ClipRect(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              key: selfkey,
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withAlpha(10),
                      borderRadius: BorderRadius.circular(10)),
                  child: ClipRRect(
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child: Container(
                              child: ClipRRect(
                                child: Center(
                                  child: self,
                                ),
                              ),
                            )),
                        Positioned(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Center(
                              child: Text(
                                "123",
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ),
                            color: Colors.black.withAlpha(50),
                          ),
                          left: 0,
                          right: 0,
                          bottom: 0,
                        )
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Container(
              key: remoteKey,
              margin: EdgeInsets.only(top: 10),
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withAlpha(10),
                      borderRadius: BorderRadius.circular(10)),
                  child: ClipRRect(
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child: Container(
                              child: ClipRRect(
                                child: Center(
                                  child: remote,
                                ),
                              ),
                            )),
                        Positioned(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Center(
                              child: Text(
                                "123",
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ),
                            color: Colors.black.withAlpha(50),
                          ),
                          left: 0,
                          right: 0,
                          bottom: 0,
                        )
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15),
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(child: Text("?????????",style: TextStyle(fontSize: 14,color: Colors.black),)),
                  CupertinoSwitch(
                    onChanged: (b){
                      mCameraOpen=b;
                      userAvailableMap[userId]["visible"] = mCameraOpen;
                      if (mCameraOpen) {
                        //??????????????????
                        widget.txBeautyManager
                            .setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_PITU);
                        widget.txBeautyManager.setBeautyLevel(6);
                      }else{
                        widget.trtcCloud.stopLocalPreview();
                      }
                      setState(() {

                      });
                    },
                    value: mCameraOpen,
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(child: Text("?????????",style: TextStyle(fontSize: 14,color: Colors.black),)),
                  CupertinoSwitch(
                    onChanged: (b){
                      mMicOpen=b;
                      if (mMicOpen) {
                        //???????????????
                        widget.trtcCloud
                            .startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH);
                      }else{
                        widget.trtcCloud.stopLocalAudio();
                      }
                      setState(() {

                      });
                    },
                    value: mMicOpen,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchBackgroundVisible() async {
    bool have=await widget._whiteboardController.isHaveBackgroundImage();
    if(have){
      widget._whiteboardController.removeBackgroundImage();
    }else{
      widget._whiteboardController.addBackgroundImage("https://5b0988e595225.cdn.sohucs.com/q_70,c_zoom,w_640/images/20180409/3ba0912dbd894d9fb25ca074046ee4f4.jpeg");
    }
  }

  /// ????????????
  onRtcListener(TRTCCloudListener type, dynamic param) {
    if ([
      TRTCCloudListener.onStatistics,
      TRTCCloudListener.onSpeedTest,
      TRTCCloudListener.onNetworkQuality,
    ].contains(type)) return;
    print("type::${type}  param:${param}");
    if (userAvailableMap.length >= 2) {
      return;
    }
    if (type == TRTCCloudListener.onError) {
      showErrordDialog(param['errMsg']);
    }
    if (type == TRTCCloudListener.onEnterRoom) {
      print("===== ???????????? ===${param}");
      userAvailableMap[userId] = {
        'userId': param,
        'type': 'video',
        'visible': mCameraOpen
      };

      if (mMicOpen) {
        //???????????????
        widget.trtcCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH);
        widget.txDeviceManager.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);

      }
      if (mCameraOpen) {
        //??????????????????
        widget.txBeautyManager
            .setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_PITU);
        widget.txBeautyManager.setBeautyLevel(6);
      }
      setState(() {

      });
    } else
      // ??????????????????
    if (type == TRTCCloudListener.onRemoteUserEnterRoom) {
      print("===== ?????????????????? ===${param}");
      //???????????????????????????????????????????????????
      userAvailableMap[remoteUserId] = {
        'userId': param,
        'type': 'video',
        'visible': false
      };
      setState(() {

      });
    }
    // // ????????????????????????
    if (type == TRTCCloudListener.onRemoteUserLeaveRoom) {
      print("====?????????????????????");
      final map = userAvailableMap[remoteUserId];
      if (map["type"] == "video") {
        widget.trtcCloud.stopRemoteView(
            remoteUserId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL);
        map['visible'] = false;
      }else if (map["type"] == "subStream") {
        widget.trtcCloud
            .stopRemoteView(remoteUserId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
        userAvailableMap.remove(remoteUserId);
      }
      setState(() {

      });
    }
    //???????????????????????????????????????????????????????????????????????????
    if (type == TRTCCloudListener.onUserVideoAvailable) {
      String userId = param['userId'];
      // ??????????????????????????????????????????
      if (param['available']) {
        final map = userAvailableMap[remoteUserId];
        if (map["type"] == "video") {
          map['visible'] = true;
        }
      } else {
        final map = userAvailableMap[remoteUserId];
        if (map["type"] == "video") {
          widget.trtcCloud.stopRemoteView(
              userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL);
          map['visible'] = false;
        }
      }
      setState(() {

      });
    }
    //????????????
    if (type == TRTCCloudListener.onUserSubStreamAvailable) {
      String userId = param["userId"];
      //????????????
      if (param["available"]) {
        userAvailableMap[remoteUserId] = {
          'userId': userId,
          'type': 'subStream',
          'visible': true
        };
      } else {
        final map = userAvailableMap[remoteUserId];
        if (map["type"] == "subStream") {
          widget.trtcCloud
              .stopRemoteView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
          userAvailableMap.remove(remoteUserId);
        }
      }
      setState(() {

      });
    }
  }

  showErrordDialog(String error) {}

  void _exitWhiteboard() {
    widget._whiteboardController.dispose();
  }
}
