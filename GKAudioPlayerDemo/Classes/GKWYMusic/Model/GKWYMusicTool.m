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

#define kDataPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"audio.json"]

@implementation GKWYMusicTool

+ (void)saveMusicList:(NSArray *)musicList {
    
    [NSKeyedArchiver archiveRootObject:musicList toFile:kDataPath];
    
}

+ (NSArray *)musicList {
    NSArray *musics = [NSKeyedUnarchiver unarchiveObjectWithFile:kDataPath];
    if (!musics) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"json"];
        
        musics = [NSArray yy_modelArrayWithClass:[GKWYMusicModel class] json:[NSData dataWithContentsOfFile:path]];
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

@end
