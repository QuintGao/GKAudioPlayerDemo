//
//  GKWYMusicTool.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GKWYMusicTool : NSObject

+ (void)saveMusicList:(NSArray *)musicList;

+ (NSArray *)musicList;

+ (NSInteger)indexFromID:(NSString *)musicID;

+ (UIViewController *)visibleViewController;

+ (void)showPlayBtn;
+ (void)hidePlayBtn;

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (NSString *)networkState;
+ (void)setNetworkState:(NSString *)state;

@end
