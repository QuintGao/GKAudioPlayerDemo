//
//  GKWYMusicControlView.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYPlayerViewController.h"

@class GKWYMusicControlView;

@protocol GKWYMusicControlViewDelegate <NSObject>

- (void)controlView:(GKWYMusicControlView *)controlView didClickLoop:(UIButton *)loopBtn;
- (void)controlView:(GKWYMusicControlView *)controlView didClickPrev:(UIButton *)prevBtn;
- (void)controlView:(GKWYMusicControlView *)controlView didClickPlay:(UIButton *)playBtn;
- (void)controlView:(GKWYMusicControlView *)controlView didClickNext:(UIButton *)nextBtn;
- (void)controlView:(GKWYMusicControlView *)controlView didClickList:(UIButton *)listBtn;

- (void)controlView:(GKWYMusicControlView *)controlView didSliderTouchBegan:(float)value;
- (void)controlView:(GKWYMusicControlView *)controlView didSliderTouchEnded:(float)value;
- (void)controlView:(GKWYMusicControlView *)controlView didSliderValueChange:(float)value;
- (void)controlView:(GKWYMusicControlView *)controlView didSliderTapped:(float)value;

@end

@interface GKWYMusicControlView : UIView

@property (nonatomic, weak) id<GKWYMusicControlViewDelegate> delegate;

@property (nonatomic, assign) GKWYPlayerPlayStyle style;

@property (nonatomic, copy) NSString *currentTime;
@property (nonatomic, copy) NSString *totalTime;
@property (nonatomic, assign) float value;

- (void)setupInitialData;

- (void)showLoadingAnim;
- (void)hideLoadingAnim;

- (void)setupPlayBtn;
- (void)setupPauseBtn;

@end
