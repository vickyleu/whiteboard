//
//  TICManager.h
//  TICDemo
//
//  Created by kennethmiao on 2019/3/27.
//  Copyright © 2019年 Tencent. All rights reserved.
//

//#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <TXLiteAVSDK_TRTC/TXLiteAVSDK.h>
#import <TEduBoard/TEduBoard.h>
#else
#import <TXLiteAVSDK_TRTC_Mac/TXLiteAVSDK.h>
#import <TEduBoard_Mac/TEduBoard.h>
#endif



#import "TICDef.h"
typedef void(^SendCommandBlock)(NSString*, NSData *);

@interface TICManager : NSObject

/*********************************************************************************************************
 *
 *                                             基本流程接口
 *
 ********************************************************************************************************/
+ (instancetype)new __attribute__((unavailable("Use +sharedInstance instead")));
+ (instancetype)init __attribute__((unavailable("Use +sharedInstance instead")));
/**
 * 获取单例
 **/
+ (instancetype)sharedInstance;
@property (nonatomic, copy) SendCommandBlock sendCommandBlock;

/**
* 初始化
* @param sdkAppId 应用标识【必填】
* @param disableModule 禁用内部TIC相关模块
* @param callback 回调【选填】
**/
- (void)init:(int)sdkAppId userId:(NSString*)userId userSig:(NSString*)userSig;
/**
 * 反初始化
 **/
- (void)unInit;


-(void)initTEduBoard:(TICClassroomOption*)classroomOption;

/**
 * 退出课堂
 * @param clearBoard 是否清空白板
 * @param callback 回调【选填】
 **/
- (void)quitClassroom:(BOOL)clearBoard callback:(TICCallback)callback;

/**
 * 切换角色
 * @param role 角色
 * @brief 只在classScene为TIC_CLASS_SCENE_LIVE时有效
 **/
- (void)switchRole:(TICRoleType)role;

/*********************************************************************************************************
 *
 *                                             内部模块管理类
 *
 ********************************************************************************************************/
/**
 * 获取白板控制器
 * @return TEduBoardController  白板控制器
 **/
- (TEduBoardController *)getBoardController;

/*********************************************************************************************************
 *
 *                                             录制相关
 *
 ********************************************************************************************************/
/**
 * 发送课后录制对时信息
 * @brief TIC内部进房成功后会自动发送离线录制对时信息，如果发送失败回调onTICSendOfflineRecordInfo接口且code!=0，调用此接口触发重试
 **/
- (void)sendOfflineRecordInfo;
@end

