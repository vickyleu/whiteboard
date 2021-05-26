//
//  TICManager.m
//  TICDemo
//
//  Created by kennethmiao on 2019/3/27.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import "TICManager.h"
#if TARGET_OS_IPHONE
#import <TXLiteAVSDK_TRTC/TXLiteAVSDK.h>
#else
#import <TXLiteAVSDK_TRTC_Mac/TXLiteAVSDK.h>
#endif
#import "TICRecorder.h"
#import "TICReport.h"
#import "TICWeakProxy.h"

typedef id(^WeakRefBlock)(void);
typedef id(^MakeWeakRefBlock)(id);
id makeWeakRef (id object) {
    __weak id weakref = object;
    WeakRefBlock block = ^(){
        return weakref;
    };
    return block();
}

@interface TICManager () <TEduBoardDelegate>
@property (nonatomic, assign) int sdkAppId;
@property (nonatomic, strong) TICClassroomOption *option;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userSig;


@property (nonatomic, assign) BOOL isEnterRoom;


@property (nonatomic, strong) TEduBoardController *boardController;
@property (nonatomic, strong) TICRecorder *recorder;

@property (nonatomic, strong) NSTimer *syncTimer;
@end

@implementation TICManager


+ (instancetype)sharedInstance
{
    static TICManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TICManager alloc] init];;
    });
    return instance;
}

- (void)init:(int)sdkAppId userId:(NSString *)userId userSig:(NSString *)userSig {
    [self report:TIC_REPORT_INITSDK_START];
    _sdkAppId = sdkAppId;
    _userId = userId;
    _userSig = userSig;
    [self report:TIC_REPORT_INITSDK_END code:1 msg:nil];
}

-(void)initTEduBoard:(TICClassroomOption *)option {
    _option = option;
    TEduBoardAuthParam *authParam = [[TEduBoardAuthParam alloc] init];
    authParam.sdkAppId = self.sdkAppId;
    authParam.userId = self.userId;
    authParam.userSig = self.userSig;
    TEduBoardInitParam *initParam = option.boardInitParam;
    if(!initParam){
        initParam = [[TEduBoardInitParam alloc] init];
    }
    [self report:TIC_REPORT_INIT_BOARD_START];
    self.boardController = [[TEduBoardController alloc] initWithAuthParam:authParam roomId:option.classId initParam:initParam];
    [self.boardController addDelegate:self];
    if(option.boardDelegate){
        [self.boardController addDelegate:option.boardDelegate];
    }
}

- (void)quitClassroom:(BOOL)clearBoard  callback:(TICCallback)callback
{
    __weak typeof(self) ws = self;
    void (^block)(void) = ^(){
        //停止同步
        [ws stopSyncTimer];
        //清除白板
        if(clearBoard){
            [ws.boardController reset];
        }
        [ws.boardController unInit];
        TEView *renderView = [ws.boardController getBoardRenderView];
        if(renderView.superview){
            [renderView removeFromSuperview];
        }
        [ws.boardController removeDelegate:ws];
        if(ws.option.boardDelegate){
            [ws.boardController removeDelegate:ws.option.boardDelegate];
        }
        ws.isEnterRoom = NO;
        ws.option = nil;
        ws.boardController = nil;
        [ws report:TIC_REPORT_QUIT_GROUP_START];
        //退出成功回调
        [ws report:TIC_REPORT_QUIT_GROUP_END];
        TICBLOCK_SAFE_RUN(callback, TICMODULE_IMSDK, 0, nil)
    };
    TICBLOCK_SAFE_RUN(block);
}

- (void)switchRole:(TICRoleType)role
{
    [[TRTCCloud sharedInstance] switchRole:(TRTCRoleType)role];
    if(role == TIC_ROLE_TYPE_ANCHOR){
        [self startSyncTimer];
    }
    else{
        [self stopSyncTimer];
    }
}
#pragma mark - manager
- (TEduBoardController *)getBoardController
{
    return _boardController;
}



#if !TARGET_OS_IPHONE
- (void)onDevice:(NSString *)deviceId type:(TRTCMediaDeviceType)deviceType stateChanged:(NSInteger)state
{
    for (id<TICEventListener> listener in _eventListeners) {
        if(listener && [listener respondsToSelector:@selector(onTICDevice:type:stateChanged:)]){
            [listener onTICDevice:deviceId type:deviceType stateChanged:state];
        }
    }
}
#endif

#pragma mark - board method
- (NSString *)getChatGroup
{
    NSString *chatGroup = [@(_option.classId) stringValue];
    if(_option.compatSaas){
        chatGroup = [NSString stringWithFormat:@"%ld_chat", (long)_option.classId];
    }
    return chatGroup;
}

#pragma mark - board delegate
- (void)onTEBHistroyDataSyncCompleted
{
    [self report:TIC_REPORT_SYNC_BOARD_HISTORY_END];
}
- (void)onTEBInit
{
    [self report:TIC_REPORT_INIT_BOARD_END];

}

- (void)onTEBError:(TEduBoardErrorCode)code msg:(NSString *)msg
{
    [self report:TIC_REPORT_BOARD_ERROR code:(int)code msg:msg];
    if(code == TEDU_BOARD_ERROR_AUTH || code == TEDU_BOARD_ERROR_LOAD || code == TEDU_BOARD_ERROR_INIT || code == TEDU_BOARD_ERROR_AUTH_TIMEOUT){
        [self report:TIC_REPORT_INIT_BOARD_END code:(int)code msg:msg];
    }
}

- (void)onTEBWarning:(TEduBoardWarningCode)code msg:(NSString *)msg
{
    [self report:TIC_REPORT_BOARD_WARNING code:(int)code msg:msg];
}


- (void)onForceOffline
{
    [self report:TIC_REPORT_FORCE_OFFLINE];
    if(_isEnterRoom){
        [_boardController removeDelegate:self];
        if(_option.boardDelegate){
            [_boardController removeDelegate:_option.boardDelegate];
        }
        _boardController = nil;
    }
}

- (void)onUserSigExpired
{
    [self report:TIC_REPORT_SIG_EXPIRED];
    if(_isEnterRoom){
        [_boardController removeDelegate:self];
        if(_option.boardDelegate){
            [_boardController removeDelegate:_option.boardDelegate];
        }
        _boardController = nil;
    }
  
}

- (void)sendOfflineRecordInfo
{
    if(_recorder == nil){
        _recorder = [[TICRecorder alloc] init];
    }
    [self report:TIC_REPORT_RECORD_INFO_START];
    __weak typeof(self) ws = self;
    //录制对时
    [_recorder sendOfflineRecordInfo:[@(_option.classId) stringValue] ntpServer:_option.ntpServer callback:^(TICModule module, int code, NSString *desc) {
        [ws report:TIC_REPORT_RECORD_INFO_END code:code msg:desc];
     
    }];
    //群ID上报
    [_recorder reportGroupId:[@(_option.classId) stringValue] sdkAppId:_sdkAppId userId:_userId userSig:_userSig];
}

#pragma mark - LIVE
- (void)startSyncTimer
{
    [self stopSyncTimer];
    _syncTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:[TICWeakProxy proxyWithTarget:self] selector:@selector(syncRemoteTime) userInfo:nil repeats:YES];
}

- (void)stopSyncTimer
{
    if(_syncTimer){
        [_syncTimer invalidate];
        _syncTimer = nil;
    }
}
- (void)syncRemoteTime
{
    uint64_t syncTime = [[[TICManager sharedInstance] getBoardController] getSyncTime];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    dataDic[@"syncTime"] = @(syncTime);
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDic options:0 error:nil];
//    [[[TICManager sharedInstance] getTRTCCloud] sendSEIMsg:data repeatCount:1];
}

- (void)onRecvSEIMsg:(NSString *)userId message:(NSData *)message
{
    NSError *error;
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:message options:0 error:&error];
    if(!error){
        if([dataDic isKindOfClass:[NSDictionary class]]){
            NSNumber *remoteTimeNum = dataDic[@"syncTime"];
            if(remoteTimeNum){
                uint64_t remoteTime = [remoteTimeNum longLongValue];
                [[[TICManager sharedInstance] getBoardController] syncRemoteTime:userId timestamp:remoteTime];
            }
        }
    }
}

#pragma mark - report
- (void)report:(TICReportEvent)event
{
    [self report:event code:0 msg:@""];
}
- (void)report:(TICReportEvent)event code:(int)code msg:(NSString*)msg
{
    [self report:event code:code msg:msg data:nil];
}
- (void)report:(TICReportEvent)event code:(int)code msg:(NSString*)msg data:(NSString *)data
{
    TICReportParam *param = [[TICReportParam alloc] init];
    param.sdkAppId = _sdkAppId;
    param.userId = _userId;
    param.roomId = _option.classId;
    param.errorCode = code;
    param.errorMsg = msg;
    param.event = event;
    param.data = data;
    [TICReport report:param];
}

@end
