//
//  GKWYMusicCoverView.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/19.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYMusicModel.h"

typedef void(^finished)(void);

@protocol GKWYMusicCoverViewDelegate<NSObject>

@optional
- (void)scrollDidScroll;

- (void)scrollWillChangeModel:(GKWYMusicModel *)model;

- (void)scrollDidChangeModel:(GKWYMusicModel *)model;

@end

@interface GKWYMusicCoverView : UIView

@property (nonatomic, weak) id<GKWYMusicCoverViewDelegate> delegate;

/** 切换唱片的scrollview */
@property (nonatomic, strong) UIScrollView *diskScrollView;

//@property (nonatomic, strong) NSArray *musics;
- (void)setupMusicList:(NSArray *)musics idx:(NSInteger)currentIndex;

- (void)resetMusicList:(NSArray *)musics idx:(NSInteger)currentIndex;

// 滑动切换歌曲
- (void)scrollChangeIsNext:(BOOL)isNext Finished:(finished)finished;

- (void)playedWithAnimated:(BOOL)animated;

- (void)pausedWithAnimated:(BOOL)animated;

- (void)resetCover;

@end
