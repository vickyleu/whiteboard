//
//  TICReport.h
//  TICDemo_Mac
//
//  Created by 缪少豪 on 2019/7/5.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TICReportEvent)
{
    TIC_REPORT_INITSDK_START,               //初始化开始
    TIC_REPORT_INITSDK_END,                 //初始化结束
    TIC_REPORT_LOGIN_START,                 //登陆开始
    TIC_REPORT_LOGIN_END,                   //登陆结束
    TIC_REPORT_LOGOUT_START,                //登出开始
    TIC_REPORT_LOGOUT_END,                  //登出结束
    TIC_REPORT_CREATE_GROUP_START,          //创建房间开始
    TIC_REPORT_CREATE_GROUP_END,            //创建房间结束
    TIC_REPORT_DELETE_GROUP_START,          //解散房间开始
    TIC_REPORT_DELETE_GROUP_END,            //解散房间结束
    TIC_REPORT_JOIN_GROUP_START,            //加入房间开始
    TIC_REPORT_JOIN_GROUP_END,              //加入房间结束
    TIC_REPORT_INIT_BOARD_START,            //初始化白板开始
    TIC_REPORT_INIT_BOARD_END,              //初始化百般结束
    TIC_REPORT_SYNC_BOARD_HISTORY_END,      //同步历史数据完成
    TIC_REPORT_ENTER_ROOM_START,            //开始进入TRTC房间
    TIC_REPORT_ENTER_ROOM_END,              //进入TRTC房间结束
    TIC_REPORT_QUIT_GROUP_START,            //退出房间开始
    TIC_REPORT_QUIT_GROUP_END,              //退出房间结束
    TIC_REPORT_RECORD_INFO_START,           //离线录制消息发送开始
    TIC_REPORT_RECORD_INFO_END,             //离线录制消息发送结束
    TIC_REPORT_VIDEO_AVAILABLE,             //视频可用
    TIC_REPORT_AUDIO_AVAILABLE,             //音频可用
    TIC_REPORT_SUB_STREAM_AVAILABLE,        //辅路可用
    TIC_REPORT_FORCE_OFFLINE,               //被踢下线
    TIC_REPORT_SIG_EXPIRED,                 //sig过期
    TIC_REPORT_BOARD_ERROR,                 //白板错误
    TIC_REPORT_BOARD_WARNING,               //白板告警
};

@interface TICReportParam : NSObject
@property (nonatomic, assign) int sdkAppId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *sdkVersion;
@property (nonatomic, assign) int roomId;
@property (nonatomic, assign) TICReportEvent event;
@property (nonatomic, assign) int errorCode;
@property (nonatomic, strong) NSString *errorMsg;
@property (nonatomic, assign) int timeCost;
@property (nonatomic, strong) NSString *data;
@property (nonatomic, strong) NSString *ext;

@end

@interface TICReport : NSObject
+ (void)report:(TICReportParam *)param;
@end

