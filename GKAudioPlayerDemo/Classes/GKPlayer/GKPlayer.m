//
//  GKPlayer.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKPlayer.h"
#import <MobileVLCKit/MobileVLCKit.h>

@interface GKPlayer()<VLCMediaPlayerDelegate>

/** vlc播放器 */
@property (nonatomic, strong) VLCMediaListPlayer *player;

/** 播放状态 */
@property (nonatomic, assign) GKPlayerStatus status;

/** 用于总时间的获取 */
@property (nonatomic, copy) NSString *totalTime;

@end

@implementation GKPlayer

+ (instancetype)sharedInstance {
    static GKPlayer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GKPlayer new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.status = GKPlayerStatusStopped;
    }
    return self;
}

#pragma mark - Setter
- (void)setPlayUrlStr:(NSString *)playUrlStr {
    _playUrlStr = playUrlStr;
    
    if (self.status == GKPlayerStatusPlaying) {
        [self stop];
    }
    
    VLCMedia *media = [VLCMedia mediaWithURL:[NSURL URLWithString:playUrlStr]];
    
    VLCMediaList *mediaList = [[VLCMediaList alloc] initWithArray:@[media]];
    
    self.player.mediaList = mediaList;
}

- (void)setPlayView:(UIView *)playView {
    _playView = playView;
    
    self.player.mediaPlayer.drawable = playView;
}

- (void)setProgress:(float)progress {
    self.player.mediaPlayer.position = progress;
}

#pragma mark - Public Method

- (void)play {
    if (self.status != GKPlayerStatusStopped) {
        [self.player stop];
    }
    
    // 重置时间
    self.totalTime = nil;
    
    [self.player playItemAtNumber:@(0)];
}

- (void)pause {
    if (self.status != GKPlayerStatusPaused) {
        [self.player pause];
    }
}

- (void)resume {
    if (self.status == GKPlayerStatusPaused) {
        [self.player play];
    }
}

- (void)stop {
    if (self.status != GKPlayerStatusStopped) {
        [self.player stop];
    }
}

#pragma mark - VLCMediaPlayerDelegate
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    switch (self.player.mediaPlayer.state) {
        case VLCMediaPlayerStateBuffering:
            self.status = GKPlayerStatusBuffering;
            NSLog(@"缓冲中。。。");
            break;
        case VLCMediaPlayerStatePlaying:
            self.status = GKPlayerStatusPlaying;
            NSLog(@"播放中。。。");
            break;
        case VLCMediaPlayerStatePaused:
            self.status = GKPlayerStatusPaused;
            NSLog(@"暂停中。。。");
            break;
        case VLCMediaPlayerStateStopped:
            self.status = GKPlayerStatusStopped;
            NSLog(@"停止了。。。");
            break;
        case VLCMediaPlayerStateEnded:
            self.status = GKPlayerStatusEnded;
            NSLog(@"结束了。。。");
            break;
        case VLCMediaPlayerStateOpening:
            NSLog(@"stream opening");
            break;
        case VLCMediaPlayerStateError:
            self.status = GKPlayerStatusError;
            NSLog(@"错误了。。。");
            break;
            
        default:
            break;
    }
    
    NSLog(@"%d", self.player.mediaPlayer.isPlaying);
    
    if (self.player.mediaPlayer.isPlaying) {
        self.status = GKPlayerStatusPlaying;
    }
    
    switch (self.player.mediaPlayer.media.state) {
        case VLCMediaStateBuffering:
            NSLog(@"media缓冲中");
            break;
        case VLCMediaStatePlaying:
            NSLog(@"media播放中");
            break;
        case VLCMediaStateNothingSpecial:
            NSLog(@"media nothing special");
            break;
        case VLCMediaStateError:
            NSLog(@"media error");
            break;
            
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(gkPlayer:statusChanged:)]) {
        [self.delegate gkPlayer:self statusChanged:self.status];
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    
    VLCMediaPlayer *mediaPlayer = self.player.mediaPlayer;
    
    VLCTime *time = mediaPlayer.time;
    
    if ([self.delegate respondsToSelector:@selector(gkPlayer:currentTime:progress:)]) {
        [self.delegate gkPlayer:self currentTime:time.stringValue progress:mediaPlayer.position];
    }
    
    if ([self.delegate respondsToSelector:@selector(gkPlayer:currentTime:totalTime:progress:)]) {
        // 毫秒
        NSTimeInterval currentTime = [time.value doubleValue];
        NSTimeInterval totalTime   = [mediaPlayer.media.length.value doubleValue];
        float progress = mediaPlayer.position;
        
        [self.delegate gkPlayer:self currentTime:currentTime totalTime:totalTime progress:progress];
    }
    
    if (!self.totalTime) {
        VLCMedia *media = mediaPlayer.media;
        
        self.totalTime = [NSString stringWithFormat:@"%@", media.length];
        
        if ([self.totalTime isKindOfClass:[NSNull class]] || [self.totalTime isEqualToString:@"(null)"]) {
            self.totalTime = nil;
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(gkPlayer:totalTime:)]) {
            [self.delegate gkPlayer:self totalTime:self.totalTime];
        }
        
        if ([self.delegate respondsToSelector:@selector(gkPlayer:duration:)]) {
            [self.delegate gkPlayer:self duration:media.length.value.doubleValue];
        }
    }
}

#pragma mark - 懒加载
- (VLCMediaListPlayer *)player {
    if (!_player) {
//        NSArray *optionArr = @[@"--extraintf="]; // 去掉vlc的log
        NSArray *optionArr = @[@"-vvvv"];
        _player = [[VLCMediaListPlayer alloc] initWithOptions:optionArr];
        _player.repeatMode = VLCDoNotRepeat;
        _player.mediaPlayer.delegate = self;
    }
    return _player;
}

@end
