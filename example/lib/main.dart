import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:whiteboard/UserSigGenerate.dart';
import 'package:whiteboard/whiteboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  WhiteboardController _whiteboardController=WhiteboardController();
  MyApp(){
    final secret="f31f05a9292434dd66ff368eed72647029daca9e9237fec99aa6669904d8d117";
    final appid=1400501664;
    final userId="1008611";
    _register(appid, secret, userId);
  }
  Future _register(int appid, String secret, String userId) async {

    if(!_whiteboardController.isInit()){
      _whiteboardController.addCreatedListener(_created);
      _whiteboardController.init(appid).then((value) async {
        if(value.code==1){
          final userSig=await UserSigGenerate.genTestSig(appid,secret,userId);
          _whiteboardController.login(userId,userSig).then((value){
            if(value.code==1){
              _created();
            }
          });
        }
      });
    }
  }
  _created(){
    print("value.isLogin==>${_whiteboardController.isLogin()}  #");
    if(_whiteboardController.isLogin()){
      print("value.isLogin=joinClass=>${_whiteboardController.isLogin()}  #");
      _whiteboardController.joinClass();
    }
  }
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
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
