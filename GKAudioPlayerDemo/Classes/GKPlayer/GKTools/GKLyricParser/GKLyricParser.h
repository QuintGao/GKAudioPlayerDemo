//
//  GKLyricParser.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//  歌词解析工具类

#import <Foundation/Foundation.h>
#import "GKLyricModel.h"

@interface GKLyricParser : NSObject

/**
 歌词解析

 @param url 歌词的url
 @return 包含歌词模型的数组
 */
+ (NSArray *)lyricParserWithUrl:(NSString *)url;

/**
 解析歌词

 @param url 歌词的url
 @param isDelBlank 是否去掉空白行歌词
 @return 包含歌词模型的数组
 */
+ (NSArray *)lyricParserWithUrl:(NSString *)url isDelBlank:(BOOL)isDelBlank;

/**
 歌词解析

 @param str 所有歌词的字符串
 @return 包含歌词模型的数组
 */
+ (NSArray *)lyricParserWithStr:(NSString *)str;

@end
