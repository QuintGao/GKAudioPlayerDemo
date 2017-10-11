//
//  GKVolumeView.m
//  GKAirPlayDemo
//
//  Created by QuintGao on 2017/10/11.
//  Copyright © 2017年 高坤. All rights reserved.
//  自定义声音调节控件

#import "GKVolumeView.h"

@implementation GKVolumeView

- (instancetype)init {
    if (self = [super init]) {
        // 设置自定义图片
        
        // 滑杆
        [self setMaximumVolumeSliderImage:[UIImage imageNamed:@"cm2_fm_vol_bg"] forState:UIControlStateNormal];
        [self setMinimumVolumeSliderImage:[UIImage imageNamed:@"cm2_fm_vol_cur"] forState:UIControlStateNormal];
        [self setVolumeThumbImage:[UIImage imageNamed:@"cm2_fm_vol_btn"] forState:UIControlStateNormal];
        
        // 按钮
        [self setRouteButtonImage:[UIImage imageNamed:@"cm2_play_icn_airplay"] forState:UIControlStateNormal];
        [self setRouteButtonImage:[UIImage imageNamed:@"cm2_play_icn_airplay_prs"] forState:UIControlStateHighlighted];
        
//        self.backgroundColor = [UIColor redColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemVolumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 设置子控件居竖直居中
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint center = obj.center;
        
        center.y = self.frame.size.height * 0.5;
        
        obj.center = center;
    }];
    
//    !self.valueChanged ? : self.valueChanged(self.volumeValue);
//    NSLog(@"%@", self.subviews);
}

- (void)systemVolumeChanged:(NSNotification *)notify {
    NSDictionary *userInfo = notify.userInfo;
    
    float value = [[userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    
    !self.valueChanged ? : self.valueChanged(value);
}

- (float)volumeValue {
    UISlider *slider = nil;
    
    for (UIView *view in self.subviews) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
            slider = (UISlider *)view;
            break;
        }
    }
    return slider.value;
}

@end
