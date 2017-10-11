//
//  GKWYMusicModel.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKWYMusicModel.h"
#import "GKWYPlayerViewController.h"

@implementation GKWYMusicModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"music_id"       : @"id",
             @"music_name"     : @"name",
             @"music_artist"   : @"artist",
             @"music_cover"    : @"cover"
             };
}

- (BOOL)isPlaying {
    return [self.music_id isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kPlayerLastPlayIDKey]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self yy_modelInitWithCoder:aDecoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

@end
