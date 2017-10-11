//
//  GKWYMusicLyricView.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/19.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKWYMusicLyricView : UIView

/** 歌词数据 */
@property (nonatomic, strong) NSArray *lyrics;
@property (nonatomic, assign) NSInteger lyricIndex;

/** 是否将要拖拽歌词 */
@property (nonatomic, assign) BOOL isWillDraging;

/** 是否正在滚动歌词 */
@property (nonatomic, assign) BOOL isScrolling;

/** 声音视图滑动开始或结束block */
@property (nonatomic, copy) void(^volumeViewSliderBlock)(BOOL isBegan);

/**
 滑动歌词的方法

 @param currentTime 当前时间
 @param totalTime 总时间
 */
- (void)scrollLyricWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

- (void)hideSystemVolumeView;
- (void)showSystemVolumeView;

@end
