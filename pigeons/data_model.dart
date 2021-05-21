// @dart=2.9
import 'package:pigeon/pigeon.dart';
class DataModel {
  int code;
  String msg;
  String data;

  DataModel(this.code, this.msg, this.data);
}

class InitRequest {
  int appID;
  InitRequest(this.appID);
}

class LoginRequest {
  String userID;
  String userSig;
  LoginRequest(this.userID,this.userSig);
}
class JoinClassRequest {
  int roomId;
  JoinClassRequest(this.roomId);
}

// 需要实现的api
@HostApi()
abstract class PigeonApi {
  DataModel pinit(InitRequest params);
  @async
  DataModel login(LoginRequest params);
  @async
  DataModel joinClass(JoinClassRequest params);
  @async
  DataModel quitClass();
}

@FlutterApi()
abstract class PigeonFlutterApi {
  @async
  void exitRoom(DataModel model); // I want this to be async

}

// 输出配置
void configurePigeon(PigeonOptions opts) {
  opts.dartOut = './lib/pigeon/PigeonPlatformMessage.dart';
  opts.objcHeaderOut = 'ios/pigeon/PigeonPlatformMessage.h';
  opts.objcSourceOut = 'ios/pigeon/PigeonPlatformMessage.m';
  opts.objcOptions.prefix = 'FLT';
  opts.dartOptions.isNullSafe=false;
  opts.javaOut = 'android/src/main/kotlin/com/pigeon/PigeonPlatformMessage.java';
  opts.javaOptions.package = 'com.pigeon';
}