//
//  GKPlayer.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKLyricParser.h"
#import "GKTool.h"

#define kPlayer [GKPlayer sharedInstance]

typedef NS_ENUM(NSUInteger, GKPlayerStatus) {
    GKPlayerStatusBuffering,   // 加载中
    GKPlayerStatusPlaying,     // 播放中
    GKPlayerStatusPaused,      // 暂停
    GKPlayerStatusStopped,     // 停止
    GKPlayerStatusEnded,       // 播放结束
    GKPlayerStatusError        // 播放出错
};

@class GKPlayer;

@protocol GKPlayerDelegate <NSObject>

@optional

// 获取当前播放状态的代理方法
- (void)gkPlayer:(GKPlayer *)player statusChanged:(GKPlayerStatus)status;

// 获取当前时间（00:00）和进度的代理方法
- (void)gkPlayer:(GKPlayer *)player currentTime:(NSString *)currentTime progress:(float)progress;

// 获取总时间（00:00）的代理方法
- (void)gkPlayer:(GKPlayer *)player totalTime:(NSString *)totalTime;

// 获取当前时间（单位：毫秒，更加精确）、总时间(单位：毫秒，更加精确)和进度的代理方法
- (void)gkPlayer:(GKPlayer *)player currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime progress:(float)progress;

// 获取总时间（单位：毫秒，更加精确）
- (void)gkPlayer:(GKPlayer *)player duration:(NSTimeInterval)duration;

@end

@interface GKPlayer : NSObject

/** 代理 */
@property (nonatomic, weak) id<GKPlayerDelegate> delegate;
/** 播放地址 */
@property (nonatomic, copy) NSString *playUrlStr;
/** 播放视图，用于视频播放 */
@property (nonatomic, strong) UIView *playView;
/** 播放状态 */
@property (nonatomic, readonly) GKPlayerStatus status;

/** 播放进度 */
@property (nonatomic, assign) float progress;

+ (instancetype)sharedInstance;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 恢复播放
 */
- (void)resume;

/**
 停止播放
 */
- (void)stop;

@end
