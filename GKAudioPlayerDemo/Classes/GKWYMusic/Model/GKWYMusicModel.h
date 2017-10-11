//
//  GKWYMusicModel.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GKWYMusicModel : NSObject<NSCoding>

@property (nonatomic, copy) NSString *music_id;

@property (nonatomic, copy) NSString *music_name;

@property (nonatomic, copy) NSString *music_artist;

@property (nonatomic, copy) NSString *music_cover;

/** 是否正在播放 */
@property (nonatomic, assign) BOOL isPlaying;

/** 是否喜欢 */
@property (nonatomic, assign) BOOL isLike;

@end
