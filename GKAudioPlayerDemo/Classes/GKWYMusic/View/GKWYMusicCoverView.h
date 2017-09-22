//
//  GKWYMusicCoverView.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/19.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKWYMusicCoverView : UIView

@property (nonatomic, strong) UIImageView *imgView;

- (void)playedWithAnimated:(BOOL)animated;

- (void)pausedWithAnimated:(BOOL)animated;

@end
