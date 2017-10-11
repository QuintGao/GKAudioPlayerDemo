//
//  GKWYMusicVolumeView.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/8.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKWYMusicVolumeView.h"
#import "GKSliderView.h"
#import <AVFoundation/AVFoundation.h>
#import "GKVolumeView.h"

@interface GKWYMusicVolumeView()<GKSliderViewDelegate>

// 音量图片
@property (nonatomic, strong) UIImageView *volImageView;

// 声音控件
@property (nonatomic, strong) GKVolumeView *volumeView;

@end

@implementation GKWYMusicVolumeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.volImageView];
        
        [self addSubview:self.volumeView];
        
//        [self addSubview:self.volSlider];
//        [self addSubview:self.airplayBtn];
        
        [self.volImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.centerY.equalTo(self);
        }];
        
//        [self.volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.volImageView.mas_right).offset(15);
//            make.right.equalTo(self);
//            make.centerY.equalTo(self);
//            make.height.mas_equalTo(36);
//        }];
//
//        [self.airplayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(self);
//            make.right.equalTo(self).offset(-15);
//        }];
//
//        [self.volSlider mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.volImageView.mas_right).offset(15);
//            make.centerY.equalTo(self);
//            make.right.equalTo(self.airplayBtn.mas_left).offset(-10);
//            make.height.mas_equalTo(30);
//        }];
//
//        self.volumeView.frame = CGRectMake(-1000, 0, 100, 100);
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
        
//        float volume = [[AVAudioSession sharedInstance] outputVolume];
//
//        self.volSlider.value = volume;
//
//        if (volume == 0) {
//            self.volImageView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker_silent"];
//        }else {
//            self.volImageView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker"];
//        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.volumeView.gk_x      = self.volImageView.gk_right + 10;
    self.volumeView.gk_width  = self.gk_width - self.volumeView.gk_x - 5;
    self.volumeView.gk_height = 36;
    self.volumeView.gk_centerY = self.gk_height * 0.5;
}

- (void)hideSystemVolumeView {
//    [self.volumeView removeFromSuperview];
//    self.volumeView = nil;
//
    self.volumeView.hidden = NO;
//    [self addSubview:self.volumeView];
    
//    self.volumeView.frame = CGRectMake(-1000, 0, 100, 100);
}

- (void)showSystemVolumeView {
    self.volumeView.hidden = YES;
//    [self.volumeView removeFromSuperview];
//    self.volumeView = nil;
}

//- (void)volumeChanged:(NSNotification *)notification
//{
//    NSDictionary *userInfo = notification.userInfo;
//    float value = [[userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
//    if (value == 0) {
//        self.volImageView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker_silent"];
//    }else {
//        self.volImageView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker"];
//    }
//
////    self.volSlider.value = value;
//}

/*
 *获取系统音量滑块
 */
- (UISlider *)getSystemVolumSlider{
    static UISlider *volumeViewSlider = nil;
    if (volumeViewSlider == nil) {
        MPVolumeView *volumeView = self.volumeView;
//        volumeView.frame = CGRectMake(-1000, 0, 100, 100);
        
        for (UIView* newView in volumeView.subviews) {
            if ([newView.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeViewSlider = (UISlider *)newView;
                break;
            }
        }
    }
    return volumeViewSlider;
}

/*
 *获取系统音量大小
 */
- (CGFloat)getSystemVolumValue{
    return [[self getSystemVolumSlider] value];
}
/*
 *设置系统音量大小
 */
- (void)setSysVolumWith:(double)value{
    [self getSystemVolumSlider].value = value;
}

#pragma mark - GKSliderViewDelegate
- (void)sliderTouchBegin:(float)value {
//    [self setSysVolumWith:value];
    if ([self.delegate respondsToSelector:@selector(volumeSlideTouchBegan)]) {
        [self.delegate volumeSlideTouchBegan];
    }
}

- (void)sliderTouchEnded:(float)value {
    [self setSysVolumWith:value];
    
    if ([self.delegate respondsToSelector:@selector(volumeSlideTouchEnded)]) {
        [self.delegate volumeSlideTouchEnded];
    }
}

- (void)sliderValueChanged:(float)value {
    [self setSysVolumWith:value];
}

#pragma mark - 懒加载
- (UIImageView *)volImageView {
    if (!_volImageView) {
        _volImageView = [UIImageView new];
        _volImageView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker_silent"];
    }
    return _volImageView;
}

- (GKVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [GKVolumeView new];
        
        __weak typeof(self) weakSelf = self;
        
        _volumeView.valueChanged = ^(float value) {
            if (value == 0) {
                weakSelf.volImageView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker_silent"];
            }else {
                weakSelf.volImageView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker"];
            }
        };
    }
    return _volumeView;
}

//- (UIButton *)airplayBtn {
//    if (!_airplayBtn) {
//        _airplayBtn = [UIButton new];
//        [_airplayBtn setImage:[UIImage imageNamed:@"cm2_play_icn_airplay"] forState:UIControlStateNormal];
//        [_airplayBtn setImage:[UIImage imageNamed:@"cm2_play_icn_airplay_prs"] forState:UIControlStateHighlighted];
//    }
//    return _airplayBtn;
//}

@end
