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
#import <MediaPlayer/MediaPlayer.h>

@interface GKWYMusicVolumeView()<GKSliderViewDelegate>

@property (nonatomic, strong) UIImageView *volImageView;
@property (nonatomic, strong) GKSliderView *volSlider;
@property (nonatomic, strong) MPVolumeView *volumeView;

@property (nonatomic, strong) UIButton *airplayBtn;

@end

@implementation GKWYMusicVolumeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.volImageView];
        [self addSubview:self.volumeView];
        [self addSubview:self.volSlider];
        [self addSubview:self.airplayBtn];
        
        [self.volImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.centerY.equalTo(self);
        }];
        
        [self.airplayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-15);
        }];
        
        [self.volSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.volImageView.mas_right).offset(15);
            make.centerY.equalTo(self);
            make.right.equalTo(self.airplayBtn.mas_left).offset(-10);
            make.height.mas_equalTo(30);
        }];
        
        self.volumeView.frame = CGRectMake(-1000, 0, 100, 100);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
        
        float volume = [[AVAudioSession sharedInstance] outputVolume];
        
        self.volSlider.value = volume;
        
        if (volume == 0) {
            self.volImageView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker_silent"];
        }else {
            self.volImageView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker"];
        }
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect volFrame = self.volumeView.frame;
    volFrame.origin.y = 6;
    self.volumeView.frame = volFrame;
}

- (void)volumeChanged:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    float value = [[userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    if (value == 0) {
        self.volImageView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker_silent"];
    }else {
        self.volImageView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker"];
    }
    
    self.volSlider.value = value;
}

/*
 *获取系统音量滑块
 */
- (UISlider *)getSystemVolumSlider{
    static UISlider * volumeViewSlider = nil;
    if (volumeViewSlider == nil) {
        MPVolumeView *volumeView = self.volumeView;
        
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
    }
    return _volImageView;
}

- (GKSliderView *)volSlider {
    if (!_volSlider) {
        _volSlider = [GKSliderView new];
        _volSlider.maximumTrackImage = [UIImage imageNamed:@"cm2_fm_vol_bg"];
        _volSlider.minimumTrackImage = [UIImage imageNamed:@"cm2_fm_vol_cur"];
        [_volSlider setThumbImage:[UIImage imageNamed:@"cm2_fm_vol_btn"] forState:UIControlStateNormal];
        [_volSlider setThumbImage:[UIImage imageNamed:@"cm2_fm_vol_btn"] forState:UIControlStateSelected];
        [_volSlider setThumbImage:[UIImage imageNamed:@"cm2_fm_vol_btn"] forState:UIControlStateHighlighted];
        _volSlider.delegate = self;
        [_volSlider hideLoading];
        _volSlider.allowTapped = NO;
        _volSlider.sliderHeight = 2;
    }
    return _volSlider;
}

- (MPVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [MPVolumeView new];
//        [_volumeView setMaximumVolumeSliderImage:[UIImage imageNamed:@"cm2_fm_vol_bg"] forState:UIControlStateNormal];
//        [_volumeView setMinimumVolumeSliderImage:[UIImage imageNamed:@"cm2_fm_vol_cur"] forState:UIControlStateNormal];
//        [_volumeView setVolumeThumbImage:[UIImage imageNamed:@"cm2_fm_vol_btn"] forState:UIControlStateNormal];
    }
    return _volumeView;
}

- (UIButton *)airplayBtn {
    if (!_airplayBtn) {
        _airplayBtn = [UIButton new];
        [_airplayBtn setImage:[UIImage imageNamed:@"cm2_play_icn_airplay"] forState:UIControlStateNormal];
        [_airplayBtn setImage:[UIImage imageNamed:@"cm2_play_icn_airplay_prs"] forState:UIControlStateHighlighted];
    }
    return _airplayBtn;
}

@end
