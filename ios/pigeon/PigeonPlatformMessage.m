// Autogenerated from Pigeon (v0.2.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import "PigeonPlatformMessage.h"
#import <Flutter/Flutter.h>

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

static NSDictionary<NSString*, id>* wrapResult(NSDictionary *result, FlutterError *error) {
  NSDictionary *errorDict = (NSDictionary *)[NSNull null];
  if (error) {
    errorDict = @{
        @"code": (error.code ? error.code : [NSNull null]),
        @"message": (error.message ? error.message : [NSNull null]),
        @"details": (error.details ? error.details : [NSNull null]),
        };
  }
  return @{
      @"result": (result ? result : [NSNull null]),
      @"error": errorDict,
      };
}

@interface FLTDataModel ()
+(FLTDataModel*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end
@interface FLTPreJoinClassRequest ()
+(FLTPreJoinClassRequest*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end
@interface FLTJoinClassRequest ()
+(FLTJoinClassRequest*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end
@interface FLTReceivedData ()
+(FLTReceivedData*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end
@interface FLTNilData ()
+(FLTNilData*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end
@interface FLTStringData ()
+(FLTStringData*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end
@interface FLTBoolData ()
+(FLTBoolData*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end
@interface FLTIntData ()
+(FLTIntData*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end

@implementation FLTDataModel
+(FLTDataModel*)fromMap:(NSDictionary*)dict {
  FLTDataModel* result = [[FLTDataModel alloc] init];
  result.code = dict[@"code"];
  if ((NSNull *)result.code == [NSNull null]) {
    result.code = nil;
  }
  result.msg = dict[@"msg"];
  if ((NSNull *)result.msg == [NSNull null]) {
    result.msg = nil;
  }
  result.data = dict[@"data"];
  if ((NSNull *)result.data == [NSNull null]) {
    result.data = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.code ? self.code : [NSNull null]), @"code", (self.msg ? self.msg : [NSNull null]), @"msg", (self.data ? self.data : [NSNull null]), @"data", nil];
}
@end

@implementation FLTPreJoinClassRequest
+(FLTPreJoinClassRequest*)fromMap:(NSDictionary*)dict {
  FLTPreJoinClassRequest* result = [[FLTPreJoinClassRequest alloc] init];
  result.appId = dict[@"appId"];
  if ((NSNull *)result.appId == [NSNull null]) {
    result.appId = nil;
  }
  result.userId = dict[@"userId"];
  if ((NSNull *)result.userId == [NSNull null]) {
    result.userId = nil;
  }
  result.userSig = dict[@"userSig"];
  if ((NSNull *)result.userSig == [NSNull null]) {
    result.userSig = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.appId ? self.appId : [NSNull null]), @"appId", (self.userId ? self.userId : [NSNull null]), @"userId", (self.userSig ? self.userSig : [NSNull null]), @"userSig", nil];
}
@end

@implementation FLTJoinClassRequest
+(FLTJoinClassRequest*)fromMap:(NSDictionary*)dict {
  FLTJoinClassRequest* result = [[FLTJoinClassRequest alloc] init];
  result.roomId = dict[@"roomId"];
  if ((NSNull *)result.roomId == [NSNull null]) {
    result.roomId = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.roomId ? self.roomId : [NSNull null]), @"roomId", nil];
}
@end

@implementation FLTReceivedData
+(FLTReceivedData*)fromMap:(NSDictionary*)dict {
  FLTReceivedData* result = [[FLTReceivedData alloc] init];
  result.data = dict[@"data"];
  if ((NSNull *)result.data == [NSNull null]) {
    result.data = nil;
  }
  result.extension = dict[@"extension"];
  if ((NSNull *)result.extension == [NSNull null]) {
    result.extension = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.data ? self.data : [NSNull null]), @"data", (self.extension ? self.extension : [NSNull null]), @"extension", nil];
}
@end

@implementation FLTNilData
+(FLTNilData*)fromMap:(NSDictionary*)dict {
  FLTNilData* result = [[FLTNilData alloc] init];
  result.value = dict[@"value"];
  if ((NSNull *)result.value == [NSNull null]) {
    result.value = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.value ? self.value : [NSNull null]), @"value", nil];
}
@end

@implementation FLTStringData
+(FLTStringData*)fromMap:(NSDictionary*)dict {
  FLTStringData* result = [[FLTStringData alloc] init];
  result.value = dict[@"value"];
  if ((NSNull *)result.value == [NSNull null]) {
    result.value = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.value ? self.value : [NSNull null]), @"value", nil];
}
@end

@implementation FLTBoolData
+(FLTBoolData*)fromMap:(NSDictionary*)dict {
  FLTBoolData* result = [[FLTBoolData alloc] init];
  result.value = dict[@"value"];
  if ((NSNull *)result.value == [NSNull null]) {
    result.value = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.value ? self.value : [NSNull null]), @"value", nil];
}
@end

@implementation FLTIntData
+(FLTIntData*)fromMap:(NSDictionary*)dict {
  FLTIntData* result = [[FLTIntData alloc] init];
  result.value = dict[@"value"];
  if ((NSNull *)result.value == [NSNull null]) {
    result.value = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.value ? self.value : [NSNull null]), @"value", nil];
}
@end

void FLTPigeonApiSetup(id<FlutterBinaryMessenger> binaryMessenger, id<FLTPigeonApi> api) {
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.preJoinClass"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FLTPreJoinClassRequest *input = [FLTPreJoinClassRequest fromMap:message];
        [api preJoinClass:input completion:^(FLTDataModel *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.joinClass"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FLTJoinClassRequest *input = [FLTJoinClassRequest fromMap:message];
        [api joinClass:input completion:^(FLTDataModel *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.quitClass"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api quitClass:^(FLTDataModel *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.receiveData"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FLTReceivedData *input = [FLTReceivedData fromMap:message];
        [api receiveData:input completion:^(FLTDataModel *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.setBackgroundColor"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FLTStringData *input = [FLTStringData fromMap:message];
        [api setBackgroundColor:input completion:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.reset"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api reset:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.addBackgroundImage"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FLTStringData *input = [FLTStringData fromMap:message];
        [api addBackgroundImage:input completion:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.isHaveBackgroundImage"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api isHaveBackgroundImage:^(FLTBoolData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.removeBackgroundImage"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api removeBackgroundImage:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.drawGraffiti"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api drawGraffiti:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.drawLine"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api drawLine:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.drawSquare"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api drawSquare:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.drawCircular"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api drawCircular:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.drawText"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api drawText:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.eraserDrawer"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api eraserDrawer:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.rollbackDraw"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api rollbackDraw:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.wipeDraw"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api wipeDraw:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.setToolColor"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FLTStringData *input = [FLTStringData fromMap:message];
        [api setToolColor:input completion:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.PigeonApi.setToolSize"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FLTIntData *input = [FLTIntData fromMap:message];
        [api setToolSize:input completion:^(FLTNilData *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult([output toMap], error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
}
@interface FLTPigeonFlutterApi ()
@property (nonatomic, strong) NSObject<FlutterBinaryMessenger>* binaryMessenger;
@end

@implementation FLTPigeonFlutterApi
- (instancetype)initWithBinaryMessenger:(NSObject<FlutterBinaryMessenger>*)binaryMessenger {
  self = [super init];
  if (self) {
    _binaryMessenger = binaryMessenger;
  }
  return self;
}

- (void)exitRoom:(FLTDataModel*)input completion:(void(^)(FLTNilData*, NSError* _Nullable))completion {
  FlutterBasicMessageChannel *channel =
    [FlutterBasicMessageChannel
      messageChannelWithName:@"dev.flutter.pigeon.PigeonFlutterApi.exitRoom"
      binaryMessenger:self.binaryMessenger];
  NSDictionary* inputMap = [input toMap];
  [channel sendMessage:inputMap reply:^(id reply) {
    NSDictionary* outputMap = reply;
    FLTNilData * output = [FLTNilData fromMap:outputMap];
    completion(output, nil);
  }];
}
- (void)receiveData:(FLTReceivedData*)input completion:(void(^)(FLTDataModel*, NSError* _Nullable))completion {
  FlutterBasicMessageChannel *channel =
    [FlutterBasicMessageChannel
      messageChannelWithName:@"dev.flutter.pigeon.PigeonFlutterApi.receiveData"
      binaryMessenger:self.binaryMessenger];
  NSDictionary* inputMap = [input toMap];
  [channel sendMessage:inputMap reply:^(id reply) {
    NSDictionary* outputMap = reply;
    FLTDataModel * output = [FLTDataModel fromMap:outputMap];
    completion(output, nil);
  }];
}
- (void)historySyncCompleted:(void(^)(FLTNilData*, NSError* _Nullable))completion {
  FlutterBasicMessageChannel *channel =
    [FlutterBasicMessageChannel
      messageChannelWithName:@"dev.flutter.pigeon.PigeonFlutterApi.historySyncCompleted"
      binaryMessenger:self.binaryMessenger];
  [channel sendMessage:nil reply:^(id reply) {
    NSDictionary* outputMap = reply;
    FLTNilData * output = [FLTNilData fromMap:outputMap];
    completion(output, nil);
  }];
}
@end