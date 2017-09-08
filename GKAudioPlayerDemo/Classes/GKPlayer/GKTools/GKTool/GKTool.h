//
//  GKTool.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GKTool : NSObject

// 时间转字符串：毫秒-> string
+ (NSString *)timeStrWithMsTime:(NSTimeInterval)msTime;
// 时间转字符串：秒 -> string
+ (NSString *)timeStrWithSecTime:(NSTimeInterval)secTime;

@end
