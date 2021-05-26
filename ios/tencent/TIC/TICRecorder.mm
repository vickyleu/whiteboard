//
//  TICRecorder.m
//  TICDemo
//
//  Created by kennethmiao on 2019/5/21.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import "TICRecorder.h"
#import "TICManager.h"
#include <chrono>
#import "ios-ntp.h"

@interface TICRecorder () <NetAssociationDelegate>
@property (nonatomic, strong) NetAssociation *netAssociation;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *ntpServer;
@property (nonatomic, strong) TICCallback callback;
@end

@implementation TICRecorder
- (id)init
{
    self = [super init];
    if(self){
    }
    return self;
}
#pragma mark - offline record
- (void)sendOfflineRecordInfo:(NSString *)groupId ntpServer:(NSString *)ntpServer callback:(TICCallback)callback
{
    self.groupId = groupId;
    self.callback = callback;
    self.ntpServer = ntpServer;
    if(self.ntpServer.length == 0){
        self.ntpServer = @"time1.cloud.tencent.com";
    }
    self.netAssociation = [[NetAssociation alloc] initWithServerName:self.ntpServer];
    self.netAssociation.delegate = self;
    [self.netAssociation sendTimeQuery];
}

/**
 * 由于IM群消息有可能大于10000，当IM群消息大于10000时，消息会开始丢弃，导致空洞消息，此接口让客户端上报群组id,后台判断，当群组中IM消息大于10000时，会自动备份群消息到COS
 */
- (void)reportGroupId:(NSString *)groupId sdkAppId:(int)sdkAppId userId:(NSString *)userId userSig:(NSString *)userSig
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"cmd"] = @"open_record_svc";
    param[@"sub_cmd"] = @"report_group";
    param[@"group_id"] = groupId;
    NSData *paramData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingSortedKeys error:nil];
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *url = [NSString stringWithFormat:@"https://yun.tim.qq.com/v4/ilvb_edu/record?sdkappid=%d&identifier=%@&usersig=%@&contenttype=json", sdkAppId, userId, userSig];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = paramData;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    [task resume];
    
}

- (uint64_t)getTickCount{
    unsigned long long tickGet = 0;
    tickGet = (uint64_t) std::chrono::steady_clock::now().time_since_epoch().count() / 1000000;
    return tickGet;
}

- (void)reportFromDelegate
{
    uint64_t ntp = static_cast<uint64_t>([[[NSDate date] dateByAddingTimeInterval:-self.netAssociation.offset] timeIntervalSince1970] * 1000);
    uint64_t timestamp = static_cast<uint64_t>([[NSDate date] timeIntervalSince1970] * 1000);
    uint64_t tick = [self getTickCount];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"type"] = @(1008);
    param[@"avsdk_time"] = @(tick);
    param[@"board_time"] = @(timestamp);
    param[@"time_line"] = @(ntp);
    NSData *paramData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingSortedKeys error:nil];
    [TICManager sharedInstance].sendCommandBlock(kTICEduRecordCmd,paramData);
    [self.netAssociation finish];
    self.netAssociation.delegate = nil;
    self.netAssociation = nil;
}
@end
