//
//  GKWYPlayerViewController.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

typedef NS_ENUM(NSUInteger, GKWYPlayerPlayStyle) {
    GKWYPlayerPlayStyleLoop,        // 循环播放
    GKWYPlayerPlayStyleOne,         // 单曲播放
    GKWYPlayerPlayStyleRandom       // 随机播放
};

#import "GKNavigationBarViewController.h"

#define kWYPlayerVC         [GKWYPlayerViewController sharedInstance]

@interface GKWYPlayerViewController : GKNavigationBarViewController

@property (nonatomic, copy) NSString *currentMusicId;
/** 是否正在播放 */
@property (nonatomic, assign) BOOL isPlaying;

+ (instancetype)sharedInstance;


/**
 数组原始播放列表

 @param list 原始播放列表
 */
- (void)setupMusicList:(NSArray *)list;

/**
 根据索引及列表播放音乐

 @param index 列表中的索引
 @param list 列表
 */
- (void)playMusicWithIndex:(NSInteger)index list:(NSArray *)list;

/**
 加载音乐列表，不播放

 @param index 列表中的索引
 @param list 列表
 */
- (void)loadMusicWithIndex:(NSInteger)index list:(NSArray *)list;

- (void)playMusic;
- (void)pauseMusic;
- (void)stopMusic;
- (void)playNextMusic;
- (void)playPrevMusic;

@end
