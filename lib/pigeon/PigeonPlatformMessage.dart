// Autogenerated from Pigeon (v0.2.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types
// @dart = 2.8
import 'dart:async';
import 'dart:typed_data' show Uint8List, Int32List, Int64List, Float64List;

import 'package:flutter/services.dart';

class DataModel {
  int code;
  String msg;
  String data;

  Object encode() {
    final Map<Object, Object> pigeonMap = <Object, Object>{};
    pigeonMap['code'] = code;
    pigeonMap['msg'] = msg;
    pigeonMap['data'] = data;
    return pigeonMap;
  }

  static DataModel decode(Object message) {
    final Map<Object, Object> pigeonMap = message as Map<Object, Object>;
    return DataModel()
      ..code = pigeonMap['code'] as int
      ..msg = pigeonMap['msg'] as String
      ..data = pigeonMap['data'] as String;
  }
}

class PreJoinClassRequest {
  int appId;
  String userId;
  String userSig;

  Object encode() {
    final Map<Object, Object> pigeonMap = <Object, Object>{};
    pigeonMap['appId'] = appId;
    pigeonMap['userId'] = userId;
    pigeonMap['userSig'] = userSig;
    return pigeonMap;
  }

  static PreJoinClassRequest decode(Object message) {
    final Map<Object, Object> pigeonMap = message as Map<Object, Object>;
    return PreJoinClassRequest()
      ..appId = pigeonMap['appId'] as int
      ..userId = pigeonMap['userId'] as String
      ..userSig = pigeonMap['userSig'] as String;
  }
}

class JoinClassRequest {
  int roomId;

  Object encode() {
    final Map<Object, Object> pigeonMap = <Object, Object>{};
    pigeonMap['roomId'] = roomId;
    return pigeonMap;
  }

  static JoinClassRequest decode(Object message) {
    final Map<Object, Object> pigeonMap = message as Map<Object, Object>;
    return JoinClassRequest()
      ..roomId = pigeonMap['roomId'] as int;
  }
}

class ReceivedData {
  Uint8List data;
  String extension;

  Object encode() {
    final Map<Object, Object> pigeonMap = <Object, Object>{};
    pigeonMap['data'] = data;
    pigeonMap['extension'] = extension;
    return pigeonMap;
  }

  static ReceivedData decode(Object message) {
    final Map<Object, Object> pigeonMap = message as Map<Object, Object>;
    return ReceivedData()
      ..data = pigeonMap['data'] as Uint8List
      ..extension = pigeonMap['extension'] as String;
  }
}

class NilData {
  int value;

  Object encode() {
    final Map<Object, Object> pigeonMap = <Object, Object>{};
    pigeonMap['value'] = value;
    return pigeonMap;
  }

  static NilData decode(Object message) {
    final Map<Object, Object> pigeonMap = message as Map<Object, Object>;
    return NilData()
      ..value = pigeonMap['value'] as int;
  }
}

class StringData {
  String value;

  Object encode() {
    final Map<Object, Object> pigeonMap = <Object, Object>{};
    pigeonMap['value'] = value;
    return pigeonMap;
  }

  static StringData decode(Object message) {
    final Map<Object, Object> pigeonMap = message as Map<Object, Object>;
    return StringData()
      ..value = pigeonMap['value'] as String;
  }
}

class BoolData {
  bool value;

  Object encode() {
    final Map<Object, Object> pigeonMap = <Object, Object>{};
    pigeonMap['value'] = value;
    return pigeonMap;
  }

  static BoolData decode(Object message) {
    final Map<Object, Object> pigeonMap = message as Map<Object, Object>;
    return BoolData()
      ..value = pigeonMap['value'] as bool;
  }
}

class IntData {
  int value;

  Object encode() {
    final Map<Object, Object> pigeonMap = <Object, Object>{};
    pigeonMap['value'] = value;
    return pigeonMap;
  }

  static IntData decode(Object message) {
    final Map<Object, Object> pigeonMap = message as Map<Object, Object>;
    return IntData()
      ..value = pigeonMap['value'] as int;
  }
}

class PigeonApi {
  /// Constructor for [PigeonApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  PigeonApi({BinaryMessenger binaryMessenger}) : _binaryMessenger = binaryMessenger;

  final BinaryMessenger _binaryMessenger;

  Future<DataModel> preJoinClass(PreJoinClassRequest arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.preJoinClass', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(encoded) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return DataModel.decode(replyMap['result']);
    }
  }

  Future<DataModel> joinClass(JoinClassRequest arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.joinClass', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(encoded) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return DataModel.decode(replyMap['result']);
    }
  }

  Future<DataModel> quitClass() async {
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.quitClass', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(null) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return DataModel.decode(replyMap['result']);
    }
  }

  Future<DataModel> receiveData(ReceivedData arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.receiveData', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(encoded) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return DataModel.decode(replyMap['result']);
    }
  }

  Future<NilData> setBackgroundColor(StringData arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.setBackgroundColor', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(encoded) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }

  Future<NilData> reset() async {
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.reset', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(null) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }

  Future<NilData> addBackgroundImage(StringData arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.addBackgroundImage', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(encoded) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }

  Future<BoolData> isHaveBackgroundImage() async {
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.isHaveBackgroundImage', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(null) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return BoolData.decode(replyMap['result']);
    }
  }

  Future<NilData> removeBackgroundImage() async {
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.removeBackgroundImage', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(null) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }

  Future<NilData> drawGraffiti() async {
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.drawGraffiti', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(null) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }

  Future<NilData> drawLine() async {
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.drawLine', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(null) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }

  Future<NilData> drawSquare() async {
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.drawSquare', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(null) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }

  Future<NilData> drawCircular() async {
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.drawCircular', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(null) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }

  Future<NilData> drawText() async {
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.drawText', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(null) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }

  Future<NilData> eraserDrawer() async {
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.eraserDrawer', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(null) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }

  Future<NilData> rollbackDraw() async {
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.rollbackDraw', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(null) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }

  Future<NilData> wipeDraw() async {
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.wipeDraw', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(null) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }

  Future<NilData> setToolColor(StringData arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.setToolColor', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(encoded) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }

  Future<NilData> setToolSize(IntData arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.PigeonApi.setToolSize', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(encoded) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return NilData.decode(replyMap['result']);
    }
  }
}

abstract class PigeonFlutterApi {
  Future<NilData> exitRoom(DataModel arg);
  Future<DataModel> receiveData(ReceivedData arg);
  NilData historySyncCompleted();
  static void setup(PigeonFlutterApi api) {
    {
      const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
          'dev.flutter.pigeon.PigeonFlutterApi.exitRoom', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.PigeonFlutterApi.exitRoom was null. Expected DataModel.');
          final DataModel input = DataModel.decode(message);
          final NilData output = await api.exitRoom(input);
          return output.encode();
        });
      }
    }
    {
      const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
          'dev.flutter.pigeon.PigeonFlutterApi.receiveData', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.PigeonFlutterApi.receiveData was null. Expected ReceivedData.');
          final ReceivedData input = ReceivedData.decode(message);
          final DataModel output = await api.receiveData(input);
          return output.encode();
        });
      }
    }
    {
      const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
          'dev.flutter.pigeon.PigeonFlutterApi.historySyncCompleted', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object message) async {
          // ignore message
          final NilData output = api.historySyncCompleted();
          return output.encode();
        });
      }
    }
  }
}
