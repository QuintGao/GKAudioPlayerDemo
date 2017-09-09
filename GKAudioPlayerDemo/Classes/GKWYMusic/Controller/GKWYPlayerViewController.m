//
//  GKWYPlayerViewController.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKWYPlayerViewController.h"
#import "GKWYMusicControlView.h"
#import "GKPlayer.h"
#import "GKWYMusicModel.h"
#import "GKWYMusicTool.h"
#import "UIImageView+WebCache.h"

#import "GKWYMusicListView.h"
#import "GKWYMusicVolumeView.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface GKWYPlayerViewController ()<UITableViewDataSource, UITableViewDelegate, GKWYMusicControlViewDelegate, GKPlayerDelegate, GKWYMusicListViewDelegate, GKWYMusicVolumeViewDelegate>

/*****************UI**********************/
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *artistLabel;

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) GKWYMusicControlView *controlView;
@property (nonatomic, strong) GKWYMusicVolumeView *volumeView;

@property (nonatomic, strong) UITableView *lyricTable;

@property (nonatomic, strong) UIImageView *maskImageView;

@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) UIView *timeLineView;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) GKWYMusicListView *listView;

/**********************data*************************/
/** 音乐播放列表 */
@property (nonatomic, strong) NSArray *musicList;
@property (nonatomic, strong) GKWYMusicModel *model;
@property (nonatomic, strong) NSDictionary *songDic;

@property (nonatomic, assign) GKWYPlayerPlayStyle playStyle; // 循环类型

@property (nonatomic, strong) NSArray *lyricList;  // 歌词列表
@property (nonatomic, assign) NSInteger lyricIndex; // 歌词索引

@property (nonatomic, assign) BOOL isAutoPlay;   // 是否自动播放
@property (nonatomic, assign) BOOL isDraging;    // 是否正在拖拽
@property (nonatomic, assign) BOOL isSeeking;    // 是否在快进快退
@property (nonatomic, assign) BOOL isScrolling;  // 是否在滚动歌词
@property (nonatomic, assign) BOOL isWillDraging; // 是否将要开始拖拽歌词

@property (nonatomic, assign) NSTimeInterval duration;      // 总时间
@property (nonatomic, assign) NSTimeInterval currentTime;   // 当前时间
@property (nonatomic, assign) NSTimeInterval positionTime;  // 锁屏时的滑杆时间

@property (nonatomic, strong) NSTimer *seekTimer;  // 快进、快退定时器

@end

@implementation GKWYPlayerViewController

+ (instancetype)sharedInstance {
    static GKWYPlayerViewController *playerVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerVC = [GKWYPlayerViewController new];
    });
    return playerVC;
}

#pragma mark - Life Cycle
- (instancetype)init {
    if (self = [super init]) {
        
        [self.view addSubview:self.bgImageView];
        [self.view addSubview:self.lyricTable];
        [self.lyricTable addSubview:self.tipsLabel];
        [self.view addSubview:self.maskImageView];
        [self.view addSubview:self.volumeView];
        [self.view addSubview:self.controlView];
        
        [self.view addSubview:self.timeLineView];
        [self.view addSubview:self.timeLabel];
        
        [self.volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).offset(64);
            make.height.mas_equalTo(34);
        }];
//        self.volumeView.backgroundColor = [UIColor redColor];
        
        [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.mas_equalTo(150);
        }];
        
        [self.lyricTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.volumeView.mas_bottom).offset(10);
            make.bottom.equalTo(self.controlView.mas_top);
        }];
        
        [self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.lyricTable);
        }];
        
        [self.timeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(50);
            make.right.equalTo(self.view).offset(-50);
            make.center.equalTo(self.lyricTable);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.timeLineView.mas_right).offset(25);
            make.centerY.equalTo(self.timeLineView.mas_centerY);
        }];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    
    [self addNotifications];
    
    // 设置播放器的代理
    kPlayer.delegate = self;
}

- (void)dealloc {
    [self removeNotifications];
}

#pragma mark - Public Methods
- (void)playMusicWithIndex:(NSInteger)index list:(NSArray *)list {
    self.musicList = list;
    
    GKWYMusicModel *model = list[index];
    
    if (![model.music_id isEqualToString:self.currentMusicId]) {
        self.currentMusicId = model.music_id;
        
        // 记录播放的id
        [[NSUserDefaults standardUserDefaults] setValue:model.music_id forKey:kPlayerLastPlayIDKey];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WYPlayerChangeMusicNotification" object:nil];
        
        self.model = model;
        
        [self getMusicInfo];
    }
}

- (void)playMusic {
    if (kPlayer.status != GKPlayerStatusPaused) {
        if (kPlayer.status == GKPlayerStatusStopped) {
            [kPlayer play];
        }else {
            [kPlayer pause];
        }
    }else {
        [kPlayer resume];
    }
}

- (void)pauseMusic {
    [kPlayer pause];
}

- (void)stopMusic {
    [kPlayer stop];
}

- (void)playNextMusic {
    if (self.isPlaying) {
        [kPlayer stop];
    }
    // 播放
    if (self.playStyle == GKWYPlayerPlayStyleLoop) {
        __block NSUInteger currentPlayIdx = 0;
        [self.musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.music_id isEqualToString:self.model.music_id]) {
                currentPlayIdx = idx;
                *stop = YES;
            }
        }];
        
        if (currentPlayIdx < self.musicList.count - 1) {
            currentPlayIdx ++;
        }else {
            currentPlayIdx = 0;
        }
        
        [self playMusicWithIndex:currentPlayIdx list:self.musicList];
    }else if (self.playStyle == GKWYPlayerPlayStyleOne) {
        if (self.isAutoPlay) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [kPlayer play];
            });
        }else {
            __block NSUInteger currentPlayIdx = 0;
            [self.musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.music_id isEqualToString:self.model.music_id]) {
                    currentPlayIdx = idx;
                    *stop = YES;
                }
            }];
            [self playMusicWithIndex:currentPlayIdx list:self.musicList];
        }
    }else {
        // 获取随机数
        NSInteger random = arc4random() % self.musicList.count;
        
        [self playMusicWithIndex:random list:self.musicList];
    }
}

- (void)playPrevMusic {
    // 首先停止上一曲
    if (self.isPlaying) {
        [kPlayer stop];
    }
    
    // 播放
    if (self.playStyle == GKWYPlayerPlayStyleLoop) {
        __block NSUInteger currentPlayIdx = 0;
        [self.musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.music_id isEqualToString:self.model.music_id]) {
                currentPlayIdx = idx;
                *stop = YES;
            }
        }];
        
        if (currentPlayIdx > 0) {
            currentPlayIdx --;
        }else if (currentPlayIdx == 0) {
            currentPlayIdx = self.musicList.count - 1;
        }
        
        [self playMusicWithIndex:currentPlayIdx list:self.musicList];
    }else if (self.playStyle == GKWYPlayerPlayStyleOne) {
        __block NSUInteger currentPlayIdx = 0;
        [self.musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.music_id isEqualToString:self.model.music_id]) {
                currentPlayIdx = idx;
                *stop = YES;
            }
        }];
        [self playMusicWithIndex:currentPlayIdx list:self.musicList];
    }else {
        // 获取随机数
        NSInteger random = arc4random() % self.musicList.count;
        
        [self playMusicWithIndex:random list:self.musicList];
    }
}

#pragma mark - Private Methods
- (void)setupUI {
    self.view.backgroundColor  = [UIColor whiteColor];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    
    // 获取播放方式，并设置
    self.playStyle = [[NSUserDefaults standardUserDefaults] integerForKey:kPlayerPlayStyleKey];
    self.controlView.style = self.playStyle;
    
    // 设置titleview
    self.titleView = [UIView new];
    self.titleView.frame = CGRectMake(0, 0, 80, 44);
    self.gk_navTitleView = self.titleView;
    
    self.nameLabel = [UILabel new];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont systemFontOfSize:16.0];
    [self.titleView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView).offset(3);
        make.centerX.equalTo(self.titleView);
    }];
    
    self.artistLabel = [UILabel new];
    self.artistLabel.textColor = [UIColor whiteColor];
    self.artistLabel.font = [UIFont systemFontOfSize:14.0];
    [self.titleView addSubview:self.artistLabel];
    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(2);
        make.centerX.equalTo(self.titleView);
    }];
}

- (void)getMusicInfo {
    self.nameLabel.text   = self.model.music_name;
    self.artistLabel.text = self.model.music_artist;
    
    if (self.isPlaying) {
        self.isPlaying = NO;
        [kPlayer stop];
    }
    // 初始化数据
    self.lyricList = nil;
    [self.lyricTable reloadData];
    
    self.tipsLabel.hidden  = NO;
    self.tipsLabel.text    = @"歌词加载中，请稍后...";
    
    self.controlView.value       = 0;
    self.controlView.currentTime = @"00:00";
    self.controlView.totalTime   = @"00:00";
    [self.controlView showLoadingAnim];
    // 重新设置锁屏控制界面
    [self setupLockScreenControlInfo];
    
    [self setupLockScreenMediaInfoNull];
    
    // 获取歌曲信息
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer     = [AFJSONRequestSerializer serializer];
    manager.responseSerializer    = [AFHTTPResponseSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:@"http://music.baidu.com/data/music/links?songIds=%@", self.model.music_id];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *songDic = [dic[@"data"][@"songList"] firstObject];
        self.songDic = songDic;
        
        // 背景图
        [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:songDic[@"songPicRadio"]] placeholderImage:[UIImage imageNamed:@"cm2_fm_bg-ip6"]];
        // 设置播放地址
        kPlayer.playUrlStr = songDic[@"songLink"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [kPlayer play];
        });
        
        // 解析歌词
        self.lyricList = [GKLyricParser lyricParserWithUrl:songDic[@"lrcLink"]];
        
        if (self.lyricList.count == 0) {
            self.tipsLabel.text = @"纯音乐，无歌词";
        }else {
            self.tipsLabel.hidden = YES;
            [self.lyricTable reloadData];
           
            // 显示第一句
            [self.lyricTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
    }];
}

- (void)addNotifications {
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    // 插拔耳机
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    // 播放打断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)removeNotifications {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)setupLockScreenControlInfo {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    // 锁屏播放
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self playMusic];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    // 锁屏暂停
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self pauseMusic];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [commandCenter.stopCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self pauseMusic];
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 喜欢按钮
    MPFeedbackCommand *likeCommand = commandCenter.likeCommand;
    likeCommand.enabled        = YES;
    likeCommand.active         = self.model.isLike;
    likeCommand.localizedTitle = self.model.isLike ? @"取消喜欢" : @"喜欢";
    [likeCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        if (self.model.isLike) {
            [self.musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.music_id == self.model.music_id) {
                    obj.isLike = NO;
                    self.model = obj;
                    *stop = YES;
                }
            }];
            [GKWYMusicTool saveMusicList:self.musicList];
        }else {
            [self.musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.music_id == self.model.music_id) {
                    obj.isLike = YES;
                    self.model = obj;
                    *stop = YES;
                }
            }];
            [GKWYMusicTool saveMusicList:self.musicList];
            
            [self setupLockScreenControlInfo];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WYMusicLovedMusicNotification" object:nil];
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    // 上一首
    MPFeedbackCommand *dislikeCommand = commandCenter.dislikeCommand;
    dislikeCommand.enabled = YES;
    dislikeCommand.localizedTitle = @"上一首";
    [dislikeCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        NSLog(@"上一首");
        
        [self playPrevMusic];
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 播放和暂停按钮（耳机控制）
    MPRemoteCommand *playPauseCommand = commandCenter.togglePlayPauseCommand;
    playPauseCommand.enabled = YES;
    [playPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
       
        if (self.isPlaying) {
            NSLog(@"暂停哦哦哦");
            [self pauseMusic];
        }else {
            NSLog(@"播放哦哦哦");
            [self playMusic];
        }
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 上一曲
    MPRemoteCommand *previousCommand = commandCenter.previousTrackCommand;
    [previousCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        [self playPrevMusic];
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 下一曲
    MPRemoteCommand *nextCommand = commandCenter.nextTrackCommand;
    nextCommand.enabled = YES;
    [nextCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        self.isAutoPlay = NO;
        
        [self playNextMusic];
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 快进
    MPRemoteCommand *forwardCommand = commandCenter.seekForwardCommand;
    forwardCommand.enabled = YES;
    [forwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        MPSeekCommandEvent *seekEvent = (MPSeekCommandEvent *)event;
        if (seekEvent.type == MPSeekCommandEventTypeBeginSeeking) {
            [self seekingForwardStart];
        }else {
            [self seekingForwardStop];
        }
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 快退
    MPRemoteCommand *backwardCommand = commandCenter.seekBackwardCommand;
    backwardCommand.enabled = YES;
    [backwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        MPSeekCommandEvent *seekEvent = (MPSeekCommandEvent *)event;
        if (seekEvent.type == MPSeekCommandEventTypeBeginSeeking) {
            [self seekingBackwardStart];
        }else {
            [self seekingBackwardStop];
        }
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 拖动进度条
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0) {
        [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            
            MPChangePlaybackPositionCommandEvent *positionEvent = (MPChangePlaybackPositionCommandEvent *)event;
            
            if (positionEvent.positionTime != self.positionTime) {
                self.positionTime = positionEvent.positionTime;
                
                self.currentTime = self.positionTime * 1000;
                
                kPlayer.progress = (float)self.currentTime / self.duration;
            }
            
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
}

- (void)setupLockScreenMediaInfo {
    // 1. 获取当前播放的歌曲的信息
    NSDictionary *songDic = self.songDic;
    if (!self.songDic) return;
    
    // 2. 获取锁屏界面中心
    MPNowPlayingInfoCenter *playingCenter = [MPNowPlayingInfoCenter defaultCenter];
    // 3. 设置展示的信息
    NSMutableDictionary *playingInfo = [NSMutableDictionary new];
    playingInfo[MPMediaItemPropertyAlbumTitle] = songDic[@"albumName"];
    playingInfo[MPMediaItemPropertyTitle]      = songDic[@"songName"];
    playingInfo[MPMediaItemPropertyArtist]     = songDic[@"artistName"];
    
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:self.bgImageView.image];
    playingInfo[MPMediaItemPropertyArtwork] = artwork;
    
    // 当前播放的时间
    playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = [NSNumber numberWithFloat:(self.duration * self.controlView.value) / 1000];
    // 进度的速度
    playingInfo[MPNowPlayingInfoPropertyPlaybackRate] = [NSNumber numberWithFloat:1.0];
    // 总时间
    playingInfo[MPMediaItemPropertyPlaybackDuration] = [NSNumber numberWithFloat:self.duration / 1000];
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 10.0) {
        playingInfo[MPNowPlayingInfoPropertyPlaybackProgress] = [NSNumber numberWithFloat:self.controlView.value];
    }
    playingCenter.nowPlayingInfo = playingInfo;
}

- (void)setupLockScreenMediaInfoNull {
    // 2. 获取锁屏界面中心
    MPNowPlayingInfoCenter *playingCenter = [MPNowPlayingInfoCenter defaultCenter];
    // 3. 设置展示的信息
    NSMutableDictionary *playingInfo = [NSMutableDictionary new];
    playingInfo[MPMediaItemPropertyAlbumTitle] = self.model.music_name;
    playingInfo[MPMediaItemPropertyTitle]      = self.model.music_name;
    playingInfo[MPMediaItemPropertyArtist]     = self.model.music_artist;
    
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"cm2_fm_bg-ip6"]];
    playingInfo[MPMediaItemPropertyArtwork] = artwork;
    
    // 当前播放的时间
    playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = [NSNumber numberWithFloat:(self.duration * self.controlView.value) / 1000];
    // 进度的速度
    playingInfo[MPNowPlayingInfoPropertyPlaybackRate] = [NSNumber numberWithFloat:1.0];
    // 总时间
    playingInfo[MPMediaItemPropertyPlaybackDuration] = [NSNumber numberWithFloat:self.duration / 1000];
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 10.0) {
        playingInfo[MPNowPlayingInfoPropertyPlaybackProgress] = [NSNumber numberWithFloat:self.controlView.value];
    }
    playingCenter.nowPlayingInfo = playingInfo;
}

- (void)scrollLyricWithCurrentTime:(NSTimeInterval)currentTime {
    if (self.lyricList.count == 0) self.lyricIndex = 0;
    
    for (NSInteger i = 0; i < self.lyricList.count; i++) {
        GKLyricModel *currentLyric = self.lyricList[i];
        GKLyricModel *nextLyric = nil;
        if (i < self.lyricList.count - 1) {
            nextLyric = self.lyricList[i + 1];
        }
        if ((self.lyricIndex != i && currentTime >= currentLyric.msTime) && (!nextLyric || currentTime < nextLyric.msTime)) {
            self.lyricIndex = i;
            
            [self.lyricTable reloadData];
            [self.lyricTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:(self.lyricIndex + 5) inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

#pragma mark - 快进快退方法

// 快进开始
- (void)seekingForwardStart {
    if (!self.isPlaying) return;
    self.isSeeking = YES;
    
    self.currentTime = self.controlView.value * self.duration;
    
    self.seekTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(seekingForwardAction) userInfo:nil repeats:YES];
}

// 快进结束
- (void)seekingForwardStop {
    if (!self.isPlaying) return;
    self.isSeeking = NO;
    [self seekTimeInvalidated];
    
    kPlayer.progress = (float)self.currentTime / self.duration;
}

- (void)seekingForwardAction {
    if (self.currentTime >= self.duration) {
        [self seekTimeInvalidated];
    }else {
        self.currentTime += 1000;
        
        self.controlView.value = self.duration == 0 ? 0 : (float)self.currentTime / self.duration;
        
        self.controlView.currentTime = [GKTool timeStrWithMsTime:self.currentTime];
    }
}

// 快退开始
- (void)seekingBackwardStart {
    if (!self.isPlaying) return;
    
    self.isSeeking   = YES;
    
    self.currentTime = self.controlView.value * self.duration;
    
    self.seekTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(seekingBackwardAction) userInfo:nil repeats:YES];
}

// 快退结束
- (void)seekingBackwardStop {
    if (!self.isPlaying) return;
    
    self.isSeeking = NO;
    
    [self seekTimeInvalidated];
    
    kPlayer.progress = (float)self.currentTime / self.duration;
}

- (void)seekingBackwardAction {
    if (self.currentTime <= 0) {
        [self seekTimeInvalidated];
    }else {
        self.currentTime-= 1000;
        
        self.controlView.value = self.duration == 0 ? 0 : (float)self.currentTime / self.duration;
        
        self.controlView.currentTime = [GKTool timeStrWithMsTime:self.currentTime];
    }
}

- (void)seekTimeInvalidated {
    [self.seekTimer invalidate];
    self.seekTimer = nil;
}

#pragma mark - Notifications
- (void)audioSessionRouteChange:(NSNotification *)notify {
    NSDictionary *interuptionDict = notify.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"耳机插入");
            // 继续播放音频，什么也不用做
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            NSLog(@"耳机拔出");
            // 注意：拔出耳机时系统会自动暂停你正在播放的音频，因此只需要改变UI为暂停状态即可
            if (self.isPlaying) {
                [self pauseMusic];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)audioSessionInterruption:(NSNotification *)notify {
    NSDictionary *interuptionDict = notify.userInfo;
    NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    NSInteger secoundReason = [[interuptionDict valueForKey:AVAudioSessionInterruptionOptionKey] integerValue];
    
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
        {
            NSLog(@"收到播放中断通知，暂停音频播放");
            if (self.isPlaying) {
                [self pauseMusic];
            }
        }
            break;
        case AVAudioSessionInterruptionTypeEnded:
        {
            if (!self.isPlaying) {
                [self playMusic];
            }
        }
            break;
    }
    switch (secoundReason) {
        case AVAudioSessionInterruptionOptionShouldResume:
            NSLog(@"恢复音频播放");
            break;
            
        default:
            break;
    }
}

#pragma mark - 代理
#pragma mark - GKPlayerDelegate
- (void)gkPlayer:(GKPlayer *)player statusChanged:(GKPlayerStatus)status {
    switch (status) {
        case GKPlayerStatusBuffering:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView hideLoadingAnim];
                [self.controlView setupPlayBtn];
            });
            self.isPlaying = YES;
        }
            break;
        case GKPlayerStatusPlaying:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView hideLoadingAnim];
                [self.controlView setupPlayBtn];
            });
            self.isPlaying = YES;
        }
            break;
        case GKPlayerStatusPaused:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView setupPauseBtn];
            });
            self.isPlaying = NO;
        }
            break;
        case GKPlayerStatusStopped:
        {
            NSLog(@"播放停止了");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView setupPauseBtn];
            });
            self.isPlaying = NO;
        }
            break;
        case GKPlayerStatusEnded:
        {
            NSLog(@"播放结束了");
            if (self.isPlaying) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.controlView setupPauseBtn];
                });
                self.isPlaying = NO;
                
                self.controlView.currentTime = self.controlView.totalTime;
                
                // 播放结束，自动播放下一首
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.isAutoPlay = YES;
                    
                    [self playNextMusic];
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.controlView setupPauseBtn];
                });
                self.isPlaying = NO;
            }
        }
            break;
        case GKPlayerStatusError:
        {
            NSLog(@"播放出错了");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView setupPauseBtn];
            });
            self.isPlaying = NO;
        }
            break;
            
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WYMusicPlayStateChanged" object:nil];
}

- (void)gkPlayer:(GKPlayer *)player currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime progress:(float)progress {
    if (self.isDraging) return;
    if (self.isSeeking) return;
    
    self.controlView.currentTime = [GKTool timeStrWithMsTime:currentTime];
    self.controlView.value       = progress;
    
    // 更新锁屏界面
    [self setupLockScreenMediaInfo];
    
    // 滚动歌词
    if (!self.isPlaying) return;
    if (self.isScrolling) return;
    
    [self scrollLyricWithCurrentTime:currentTime];
}

- (void)gkPlayer:(GKPlayer *)player duration:(NSTimeInterval)duration {
    self.controlView.totalTime = [GKTool timeStrWithMsTime:duration];
    
    self.duration = duration;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lyricList.count + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LyricCell" forIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.numberOfLines = 0;
    cell.selectedBackgroundView  = [UIView new];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font  = [UIFont systemFontOfSize:16.0];
    cell.textLabel.alpha = 1.0;
    
    if (indexPath.row < 5 || indexPath.row > self.lyricList.count + 4) {
        cell.textLabel.textColor = [UIColor clearColor];
        cell.textLabel.text = @"";
    }else {
        cell.textLabel.text = [self.lyricList[indexPath.row - 5] content];
        if (indexPath.row == self.lyricIndex + 5) {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont systemFontOfSize:18.0];
        }else {
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        }
    }
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
// 将要开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isWillDraging = YES;
    // 取消前面的延时操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    self.isScrolling = YES;
    // 显示分割线和时间
    self.timeLineView.hidden = NO;
    self.timeLabel.hidden = NO;
}
// 拖拽结束，是否需要减速
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.isWillDraging = NO;
        
        [self performSelector:@selector(endedScroll) withObject:nil afterDelay:1.0];
    }
}

// 将要开始减速，上面的decelerate为yes时触发
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
}

// 减速停止
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isWillDraging = NO;
    
    [self performSelector:@selector(endedScroll) withObject:nil afterDelay:1.0];
}

// scrollView滑动时
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!self.isScrolling) return; // 不是由拖拽产生的滚动
    
    // 获取滚动距离
    CGFloat offsetY  = scrollView.contentOffset.y;
    
    // 根据跟单距离计算行数（滚动距离 + tableview高度的一半）/ 行高 + 5 - 1
    NSInteger index = (offsetY + self.lyricTable.frame.size.height * 0.5) / 44 - 5 + 1;
    
    // 根据对应的索引取出歌词模型
    GKLyricModel *model = nil;
    if (index < 0) {
        model = self.lyricList.firstObject;
    }else if (index > self.lyricList.count - 1) {
        model = nil;
    }else {
        model = self.lyricList[index];
    }
    // 设置对应的时间
    if (model) {
        self.timeLabel.text   = [GKTool timeStrWithSecTime:model.secTime];
        self.timeLabel.hidden = NO;
    }else {
        self.timeLabel.text   = @"";
        self.timeLabel.hidden = YES;
    }
}

- (void)endedScroll {
    if (self.isWillDraging) return;
    self.timeLineView.hidden = YES;
    self.timeLabel.hidden    = YES;
    
    // 4秒后继续滚动歌词
    [self performSelector:@selector(endScrolling) withObject:nil afterDelay:4.0];
}

- (void)endScrolling {
    if (self.isWillDraging) return;
    
    self.isScrolling = NO;
}

#pragma mark - GKWYMusicVolumeViewDelegate
- (void)volumeSlideTouchBegan {
    self.gk_fullScreenPopDisabled = YES;
}

- (void)volumeSlideTouchEnded {
    self.gk_fullScreenPopDisabled = NO;
}

#pragma mark - GKWYMusicControlViewDelegate
- (void)controlView:(GKWYMusicControlView *)controlView didClickLoop:(UIButton *)loopBtn {
    if (self.playStyle == GKWYPlayerPlayStyleLoop) {  // 循环->单曲
        self.playStyle = GKWYPlayerPlayStyleOne;
    }else if (self.playStyle == GKWYPlayerPlayStyleOne) { // 单曲->随机
        self.playStyle = GKWYPlayerPlayStyleRandom;
    }else { // 随机-> 循环
        self.playStyle = GKWYPlayerPlayStyleLoop;
    }
    self.controlView.style = self.playStyle;
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.playStyle forKey:kPlayerPlayStyleKey];
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickPrev:(UIButton *)prevBtn {
    [self playPrevMusic];
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickPlay:(UIButton *)playBtn {
    [self playMusic];
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickNext:(UIButton *)nextBtn {
    self.isAutoPlay = NO;
    
    [self playNextMusic];
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickList:(UIButton *)listBtn {
    
    self.listView.gk_size = CGSizeMake(self.view.gk_width, 440);
    self.listView.listArr = self.musicList;
    
    [GKCover coverFrom:self.navigationController.view contentView:self.listView style:GKCoverStyleTranslucent showStyle:GKCoverShowStyleBottom animStyle:GKCoverAnimStyleBottom notClick:NO showBlock:^{
        self.gk_interactivePopDisabled = YES;
    } hideBlock:^{
        self.gk_interactivePopDisabled = NO;
    }];
}

- (void)controlView:(GKWYMusicControlView *)controlView didSliderTouchBegan:(float)value {
    self.isDraging = YES;
    // 防止手势冲突
    self.gk_fullScreenPopDisabled = YES;
}

- (void)controlView:(GKWYMusicControlView *)controlView didSliderTouchEnded:(float)value {
    self.isDraging = NO;
    kPlayer.progress = value;
    self.gk_fullScreenPopDisabled = NO;
    
    // 滚动歌词到对应位置
    [self scrollLyricWithCurrentTime:(self.duration * value)];
}

- (void)controlView:(GKWYMusicControlView *)controlView didSliderValueChange:(float)value {
    self.isDraging = YES;
    self.controlView.currentTime = [GKTool timeStrWithMsTime:(self.duration * value)];
}

- (void)controlView:(GKWYMusicControlView *)controlView didSliderTapped:(float)value {
    self.controlView.currentTime = [GKTool timeStrWithMsTime:(self.duration * value)];
    kPlayer.progress = value;
    
    [self scrollLyricWithCurrentTime:(self.duration * value)];
}

#pragma mark - GKWYMusicListViewDelegate
- (void)listViewDidClose {
    [GKCover hideView];
}

- (void)listView:(GKWYMusicListView *)listView didSelectRow:(NSInteger)row {
    [self playMusicWithIndex:row list:listView.listArr];
}

- (void)listView:(GKWYMusicListView *)listView didLovedWithRow:(NSInteger)row {
    GKWYMusicModel *model = self.musicList[row];
    model.isLike = !model.isLike;
    
    [GKWYMusicTool saveMusicList:self.musicList];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WYMusicLovedMusicNotification" object:nil];
}

#pragma mark - 懒加载
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        // 添加模糊效果
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        effectView.frame = _bgImageView.bounds;
        [_bgImageView addSubview:effectView];
    }
    return _bgImageView;
}

- (GKWYMusicVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [GKWYMusicVolumeView new];
        _volumeView.delegate = self;
    }
    return _volumeView;
}

- (GKWYMusicControlView *)controlView {
    if (!_controlView) {
        _controlView = [GKWYMusicControlView new];
        _controlView.delegate = self;
    }
    return _controlView;
}

- (UITableView *)lyricTable {
    if (!_lyricTable) {
        _lyricTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _lyricTable.dataSource      = self;
        _lyricTable.delegate        = self;
        _lyricTable.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _lyricTable.backgroundColor = [UIColor clearColor];
        [_lyricTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LyricCell"];
    }
    return _lyricTable;
}

- (UIImageView *)maskImageView {
    if (!_maskImageView) {
        _maskImageView = [UIImageView new];
//        _maskImageView.backgroundColor = [UIColor redColor];
//        _maskImageView.image = [UIImage imageNamed:@"cm2_act_cover_mask"];
    }
    return _maskImageView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [UILabel new];
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.font = [UIFont systemFontOfSize:17.0];
        _tipsLabel.hidden = YES;
    }
    return _tipsLabel;
}

- (UIView *)timeLineView {
    if (!_timeLineView) {
        _timeLineView = [UIView new];
        _timeLineView.backgroundColor = [UIColor darkGrayColor];
        _timeLineView.hidden = YES;
    }
    return _timeLineView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:13.0];
        _timeLabel.hidden = YES;
    }
    return _timeLabel;
}

- (GKWYMusicListView *)listView {
    if (!_listView) {
        _listView = [GKWYMusicListView new];
        _listView.delegate = self;
    }
    return _listView;
}

@end
