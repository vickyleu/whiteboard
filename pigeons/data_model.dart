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

///操作请求
///这里是希望通过纯文本的形式发送方法和参数命令,然后在原生语言中通过反射执行预定义的方法,swift项目通过调用OC的方法执行反射,kotlin正常操作
///或者是通过各自定义一组枚举值,需要保证三端枚举值完全一致,然后手动在原生中执行各种方法,pigeon不能导出枚举,TODO 我他妈不是很想这么写
class CommandRequest{
  String commandMethod;
  List<String> args;
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