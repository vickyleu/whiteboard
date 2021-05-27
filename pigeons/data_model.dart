// @dart=2.9
import 'package:pigeon/pigeon.dart';

class DataModel {
  int code;
  String msg;
  String data;

  DataModel(this.code, this.msg, this.data);
}


class PreJoinClassRequest {
  int appId;
  String userId;
  String userSig;
  PreJoinClassRequest(this.appId,this.userId,this.userSig);
}
class JoinClassRequest {
  int roomId;
  JoinClassRequest(this.roomId);
}


class ReceivedData{
  Uint8List data;
  String extension;
}

class StringData{
  String string;
}

///Flutter持有的原生平台通道,Flutter调用原生方法
@HostApi()
abstract class PigeonApi {
  @async
  DataModel preJoinClass(PreJoinClassRequest params);
  @async
  DataModel joinClass(JoinClassRequest params);
  @async
  DataModel quitClass();
  @async
  DataModel receiveData(ReceivedData params);

  @async
  void reset();

  @async
  void addBackgroundImage(StringData url);
}



///原生平台持有的Flutter通道,原生调用Flutter方法
@FlutterApi()
abstract class PigeonFlutterApi {
  @async
  void exitRoom(DataModel model); // I want this to be async
  @async
  DataModel receiveData(ReceivedData params);

  void historySyncCompleted();
}


void configurePigeon(PigeonOptions opts) {
  opts.dartOut = './lib/pigeon/PigeonPlatformMessage.dart';
  opts.objcHeaderOut = 'ios/pigeon/PigeonPlatformMessage.h';
  opts.objcSourceOut = 'ios/pigeon/PigeonPlatformMessage.m';
  opts.objcOptions.prefix = 'FLT';
  opts.dartOptions.isNullSafe=false;
  opts.javaOut = 'android/src/main/kotlin/com/pigeon/PigeonPlatformMessage.java';
  opts.javaOptions.package = 'com.pigeon';
}