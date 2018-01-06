//
//  GKWYMusicTool.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKWYMusicTool.h"
#import "GKWYMusicModel.h"
#import "AppDelegate.h"
#import <Accelerate/Accelerate.h>

#define kDataPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"audio.json"]

@implementation GKWYMusicTool

+ (void)saveMusicList:(NSArray *)musicList {
    [NSKeyedArchiver archiveRootObject:musicList toFile:kDataPath];
}

+ (NSArray *)musicList {
    NSArray *musics = [NSKeyedUnarchiver unarchiveObjectWithFile:kDataPath];
    
    if (!musics) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"json"];
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        musics = [NSArray yy_modelArrayWithClass:[GKWYMusicModel class] json:data];
    }
    
    return musics;
}

+ (NSInteger)indexFromID:(NSString *)musicID {
    
    __block NSInteger index = 0;
    
    [[self musicList] enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.music_id isEqualToString:musicID]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

+ (UIViewController *)visibleViewController {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    return [rootVC visibleViewControllerIfExist];
}

+ (void)showPlayBtn {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [delegate showPlayBtn];
}

+ (void)hidePlayBtn {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [delegate hidePlayBtn];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1.0, 1.0)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSString *)networkState {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"networkState"];
}

+ (void)setNetworkState:(NSString *)state {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:state forKey:@"networkState"];
    [defaults synchronize];
}

@end
