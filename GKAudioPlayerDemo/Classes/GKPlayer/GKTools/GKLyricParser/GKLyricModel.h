//
//  GKLyricModel.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//  歌词模型类

#import <Foundation/Foundation.h>

@interface GKLyricModel : NSObject

/** 毫秒 */
@property (nonatomic, assign) NSTimeInterval msTime;
/** 秒 */
@property (nonatomic, assign) NSTimeInterval secTime;
/** 时间字符串 */
@property (nonatomic, copy) NSString *timeString;
/** 歌词内容 */
@property (nonatomic, copy) NSString *content;

@end
