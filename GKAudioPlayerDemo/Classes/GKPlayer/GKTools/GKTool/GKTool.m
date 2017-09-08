//
//  GKTool.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKTool.h"

@implementation GKTool

+ (NSString *)timeStrWithMsTime:(NSTimeInterval)msTime {
    return [self timeStrWithSecTime:msTime / 1000];
}

+ (NSString *)timeStrWithSecTime:(NSTimeInterval)secTime {
    NSInteger time = (NSInteger)secTime;
    
    if (time / 3600 > 0) { // 时分秒
        NSInteger hour   = time / 3600;
        NSInteger minute = (time % 3600) / 60;
        NSInteger second = (time % 3600) % 60;
        
        return [NSString stringWithFormat:@"%02zd:%02zd:%02zd", hour, minute, second];
    }else { // 分秒
        NSInteger minute = time / 60;
        NSInteger second = time % 60;
        
        return [NSString stringWithFormat:@"%02zd:%02zd", minute, second];
    }
}

@end
