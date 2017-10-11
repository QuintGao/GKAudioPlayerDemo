//
//  GKVolumeView.h
//  GKAirPlayDemo
//
//  Created by QuintGao on 2017/10/11.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface GKVolumeView : MPVolumeView

@property (nonatomic, assign) float volumeValue;

@property (nonatomic, copy) void(^valueChanged)(float value);

@end
