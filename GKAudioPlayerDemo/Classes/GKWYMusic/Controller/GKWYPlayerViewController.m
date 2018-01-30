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

#import "GKWYMusicLyricView.h"
#import "GKWYMusicListView.h"
#import "GKWYMusicCoverView.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "AppDelegate.h"

//#import <FXBlurView/FXBlurView.h>

@interface GKWYPlayerViewController ()<GKWYMusicControlViewDelegate, GKPlayerDelegate, GKWYMusicListViewDelegate, GKWYMusicCoverViewDelegate>

/*****************UI**********************/
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *artistLabel;

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) GKWYMusicCoverView *coverView;

/** 歌词视图 */
@property (nonatomic, strong) GKWYMusicLyricView *lyricView;

@property (nonatomic, strong) GKWYMusicControlView *controlView;

@property (nonatomic, strong) GKWYMusicListView *listView;

/**********************data*************************/

@property (nonatomic, strong) UIImage *coverImage;
/** 音乐原始播放列表 */
@property (nonatomic, strong) NSArray *musicList;
/** 当前播放的列表 */
@property (nonatomic, strong) NSArray *playList;
@property (nonatomic, strong) GKWYMusicModel *model;
@property (nonatomic, strong) NSDictionary *songDic;
/** 乱序后的列表 */
@property (nonatomic, strong) NSArray *outOrderList;

@property (nonatomic, assign) GKWYPlayerPlayStyle playStyle; // 循环类型

@property (nonatomic, assign) BOOL isAutoPlay;    // 是否自动播放
@property (nonatomic, assign) BOOL isDraging;     // 是否正在拖拽
@property (nonatomic, assign) BOOL isSeeking;     // 是否在快进快退
@property (nonatomic, assign) BOOL isChanged;     // 是否正在切换歌曲
@property (nonatomic, assign) BOOL isCoverScroll; // 是否转盘在滑动

@property (nonatomic, assign) NSTimeInterval duration;      // 总时间
@property (nonatomic, assign) NSTimeInterval currentTime;   // 当前时间
@property (nonatomic, assign) NSTimeInterval positionTime;  // 锁屏时的滑杆时间

@property (nonatomic, strong) NSTimer *seekTimer;  // 快进、快退定时器

/** 是否立即播放 */
@property (nonatomic, assign) BOOL ifNowPlay;

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
        [self.view addSubview:self.coverView];
        [self.view addSubview:self.lyricView];
        [self.view addSubview:self.controlView];
        
        [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            //            make.height.mas_equalTo(150);
            make.height.mas_equalTo(170);
        }];
        
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.gk_navigationBar.mas_bottom);
            make.bottom.equalTo(self.controlView.mas_top).offset(20);
        }];
        
        [self.lyricView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.gk_navigationBar.mas_bottom);
            make.bottom.equalTo(self.controlView.mas_top).offset(20);
        }];
        
        [self.coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLyricView)]];
        [self.lyricView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCoverView)]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self addNotifications];
    
    // 设置播放器的代理
    kPlayer.delegate = self;
    
    // 禁用全屏滑动返回手势
    self.gk_fullScreenPopDisabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [GKWYMusicTool hidePlayBtn];
    
    // 解决边缘滑动与UIScrollView滑动的冲突
    NSArray *gestures = self.navigationController.view.gestureRecognizers;
    
    for (UIGestureRecognizer *gesture in gestures) {
        if ([gesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            [self.coverView.diskScrollView.panGestureRecognizer requireGestureRecognizerToFail:gesture];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [GKWYMusicTool showPlayBtn];
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"didReceiveMemoryWarning");
}

#pragma mark - Public Methods
- (void)setupMusicList:(NSArray *)list {
    self.musicList = list;
    
    switch (self.playStyle) {
        case GKWYPlayerPlayStyleLoop:
        {
            self.outOrderList = nil;
            [self setCoverList:list];
        }
            break;
        case GKWYPlayerPlayStyleOne:
        {
            self.outOrderList = nil;
            [self setCoverList:list];
        }
            break;
        case GKWYPlayerPlayStyleRandom:
        {
            self.outOrderList = [self randomArray:list];
            [self setCoverList:self.outOrderList];
        }
            break;
            
        default:
            break;
    }
}

- (void)playMusicWithIndex:(NSInteger)index list:(NSArray *)list {
    self.playList = list;
    
    GKWYMusicModel *model = list[index];
    
    if (![model.music_id isEqualToString:self.currentMusicId]) {
        
        [self.coverView setupMusicList:list idx:index];
        
        self.currentMusicId = model.music_id;
        
        self.ifNowPlay = YES;
        
        // 记录播放的id
        [[NSUserDefaults standardUserDefaults] setValue:model.music_id forKey:kPlayerLastPlayIDKey];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WYPlayerChangeMusicNotification" object:nil];
        
        self.model = model;
        
        [self getMusicInfo];
    }else {
        self.ifNowPlay = YES;
        
        if (self.isPlaying) {
            return;
        }
        
        if (self.model) {
            NSString *networkState = [GKWYMusicTool networkState];
            
            if ([networkState isEqualToString:@"none"]) {
                return;
            }
            [kPlayer play];
        }
    }
}

- (void)loadMusicWithIndex:(NSInteger)index list:(NSArray *)list {
    self.musicList = list;
    
    GKWYMusicModel *model = list[index];
    
    if (![model.music_id isEqualToString:self.currentMusicId]) {
        
        [self.coverView setupMusicList:list idx:index];
        
        self.currentMusicId = model.music_id;
        
        self.ifNowPlay = NO;
        
        // 记录播放的id
        [[NSUserDefaults standardUserDefaults] setValue:model.music_id forKey:kPlayerLastPlayIDKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WYPlayerChangeMusicNotification" object:nil];
        
        self.model = model;
        
        [self getMusicInfo];
    }
}

- (void)playMusic {
    // 首先检查网络状态
    NSString *networkState = [GKWYMusicTool networkState];
    if ([networkState isEqualToString:@"none"]) {
        [GKMessageTool showError:@"网络连接失败"];
        // 设置播放状态为暂停
        [self.controlView setupPauseBtn];
        return;
    }else {
        if (!kPlayer.playUrlStr) { // 没有播放地址
            // 需要重新请求
            [self getMusicInfo];
        }else {
            if (kPlayer.status != GKPlayerStatusPaused) {
                [kPlayer play];
            }else {
                [kPlayer resume];
            }
        }
    }
}

- (void)pauseMusic {
    [kPlayer pause];
}

- (void)stopMusic {
    [kPlayer stop];
}

- (void)playNextMusic {
    // 重置封面
    [self.coverView resetCover];
    
    // 播放
    if (self.playStyle == GKWYPlayerPlayStyleLoop) {
        NSArray *musicList = self.musicList;
        
        __block NSUInteger currentIndex = 0;
        [musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.music_id isEqualToString:self.model.music_id]) {
                currentIndex = idx;
                *stop = YES;
            }
        }];
        
        [self playNextMusicWithList:musicList index:currentIndex];
    }else if (self.playStyle == GKWYPlayerPlayStyleOne) {
        if (self.isAutoPlay) {  // 循环播放自动播放完毕
            NSArray *musicList = self.musicList;
            __block NSUInteger currentIndex = 0;
            [musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.music_id isEqualToString:self.model.music_id]) {
                    currentIndex = idx;
                    *stop = YES;
                }
            }];
            
            // 重置列表
            [self.coverView resetMusicList:musicList idx:currentIndex];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [kPlayer play];
                [self playMusic];
            });
        }else {  // 循环播放切换歌曲
            NSArray *musicList = self.musicList;
            
            __block NSUInteger currentIndex = 0;
            [musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.music_id isEqualToString:self.model.music_id]) {
                    currentIndex = idx;
                    *stop = YES;
                }
            }];
            
            [self playNextMusicWithList:musicList index:currentIndex];
        }
    }else {
        if (!self.outOrderList) {
            self.outOrderList = [self randomArray:self.musicList];
        }
        NSArray *musicList = self.outOrderList;
        
        // 找出乱序后当前播放歌曲的索引
        __block NSInteger currentIndex = 0;
        [musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.music_id isEqualToString:self.model.music_id]) {
                currentIndex = idx;
                *stop = YES;
            }
        }];
        
        [self playNextMusicWithList:musicList index:currentIndex];
    }
}


- (void)playNextMusicWithList:(NSArray *)musicList index:(NSInteger)currentIndex {
    // 列表已经打乱顺序，直接播放下一首即可
    if (currentIndex < musicList.count - 1) {
        currentIndex ++;
    }else {
        currentIndex = 0;
    }
    
    // 切换到下一首
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.coverView scrollChangeIsNext:YES Finished:^{
            [self playMusicWithIndex:currentIndex list:musicList];
        }];
    });
}

- (void)playPrevMusic {
    // 重置封面
    [self.coverView resetCover];
    
    // 播放
    if (self.playStyle == GKWYPlayerPlayStyleLoop) {
        NSArray *musicList = self.musicList;
        
        __block NSUInteger currentIndex = 0;
        [musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.music_id isEqualToString:self.model.music_id]) {
                currentIndex = idx;
                *stop = YES;
            }
        }];
        
        if (currentIndex > 0) {
            currentIndex --;
        }else if (currentIndex == 0) {
            currentIndex = musicList.count - 1;
        }
        
        [self playPrevMusicWithList:musicList index:currentIndex];
        
    }else if (self.playStyle == GKWYPlayerPlayStyleOne) {
        NSArray *musicList = self.musicList;
        
        __block NSUInteger currentIndex = 0;
        [musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.music_id isEqualToString:self.model.music_id]) {
                currentIndex = idx;
                *stop = YES;
            }
        }];
        
        [self playPrevMusicWithList:musicList index:currentIndex];
    }else {
        if (!self.outOrderList) {
            self.outOrderList = [self randomArray:self.musicList];
        }
        NSArray *musicList = self.outOrderList;
        
        // 找出乱序后当前播放歌曲的索引
        __block NSInteger currentIndex = 0;
        [musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.music_id isEqualToString:self.model.music_id]) {
                currentIndex = idx;
                *stop = YES;
            }
        }];
        
        [self playPrevMusicWithList:musicList index:currentIndex];
    }
}

- (void)playPrevMusicWithList:(NSArray *)musicList index:(NSInteger)currentIndex {
    // 列表已经打乱顺序，直接播放上一首一首即可
    if (currentIndex > 0) {
        currentIndex --;
    }else if (currentIndex == 0) {
        currentIndex = self.musicList.count - 1;
    }
    
    // 切换到下一首
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.coverView scrollChangeIsNext:NO Finished:^{
            [self playMusicWithIndex:currentIndex list:musicList];
        }];
    });
}

- (NSArray *)randomArray:(NSArray *)arr {
    NSArray *randomArr = [arr sortedArrayUsingComparator:^NSComparisonResult(GKWYMusicModel *obj1, GKWYMusicModel *obj2) {
        int seed = arc4random_uniform(2);
        if (seed) {
            return [obj1.music_id compare:obj2.music_id];
        }else {
            return [obj2.music_id compare:obj1.music_id];
        }
    }];
    
    return randomArr;
}

#pragma mark - Private Methods
- (void)setupUI {
    self.view.backgroundColor  = [UIColor redColor];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    //    self.gk_navBarAlpha = 0.0;
    
    self.gk_navRightBarButtonItem = [UIBarButtonItem itemWithImageName:@"cm2_topbar_icn_share" target:self action:@selector(shareAction)];
    
    // 获取播放方式，并设置
    self.playStyle = [[NSUserDefaults standardUserDefaults] integerForKey:kPlayerPlayStyleKey];
    self.controlView.style = self.playStyle;
    
    // 设置titleview
    self.titleView       = [UIView new];
    self.titleView.frame = CGRectMake(0, 0, 160, 44);
    self.gk_navTitleView = self.titleView;
    
    self.nameLabel              = [UILabel new];
    self.nameLabel.textColor    = [UIColor whiteColor];
    self.nameLabel.font         = [UIFont systemFontOfSize:16.0];
    [self.titleView addSubview:self.nameLabel];
    
    self.artistLabel            = [UILabel new];
    self.artistLabel.textColor  = [UIColor whiteColor];
    self.artistLabel.font       = [UIFont systemFontOfSize:14.0];
    [self.titleView addSubview:self.artistLabel];
    
    self.nameLabel.gk_y         = 3;
    self.artistLabel.gk_y       = self.nameLabel.gk_bottom + 2;
}

- (void)showLyricView {
    self.lyricView.hidden = NO;
    [self.lyricView hideSystemVolumeView];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.lyricView.alpha            = 1.0;
        
        self.coverView.alpha            = 0.0;
        self.controlView.topView.alpha  = 0.0;
    }completion:^(BOOL finished) {
        self.lyricView.hidden           = NO;
        self.coverView.hidden           = YES;
        self.controlView.topView.hidden = YES;
    }];
}

- (void)showCoverView {
    self.coverView.hidden           = NO;
    self.controlView.topView.hidden = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.lyricView.alpha            = 0.0;
        
        self.coverView.alpha            = 1.0;
        self.controlView.topView.alpha  = 1.0;
    }completion:^(BOOL finished) {
        self.lyricView.hidden           = YES;
        [self.lyricView showSystemVolumeView];
        self.coverView.hidden           = NO;
        self.controlView.topView.hidden = NO;
    }];
}

- (void)getMusicInfo {
    [self setupTitleWithModel:self.model];
    
    if (self.isPlaying) {
        self.isPlaying = NO;
        [kPlayer stop];
    }
    
    self.bgImageView.image = [UIImage imageNamed:@"cm2_fm_bg-ip6"];
    
    // 初始化数据
    self.lyricView.lyrics = nil;
    
    [self.controlView setupInitialData];
    
    if (self.ifNowPlay) {
        [self.controlView showLoadingAnim];
    }
    
    self.controlView.is_love = self.model.isLike;
    
    // 重新设置锁屏控制界面
    [self setupLockScreenControlInfo];
    
    [self setupLockScreenMediaInfoNull];
    
    if (self.ifNowPlay) {
        [self.coverView playedWithAnimated:YES];
    }
    
    // 获取歌曲信息
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer     = [AFJSONRequestSerializer serializer];
    manager.responseSerializer    = [AFHTTPResponseSerializer serializer];
    
    //    NSString *url = [NSString stringWithFormat:@"http://music.baidu.com/data/music/links?songIds={%@}", self.model.music_id];
    NSString *url = @"http://music.baidu.com/data/music/links";
    
    NSString *networkState = [GKWYMusicTool networkState];
    if ([networkState isEqualToString:@"none"]) {
        [GKMessageTool showTips:@"网络连接失败"];
        
        return;
    }
    
    [manager GET:url parameters:@{@"songIds": self.model.music_id} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *songDic = [dic[@"data"][@"songList"] firstObject];
        self.songDic = songDic;
        
        // 背景图
        [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:songDic[@"songPicRadio"]] placeholderImage:[UIImage imageNamed:@"cm2_fm_bg-ip6"]];
        
        // 设置播放地址
        kPlayer.playUrlStr = songDic[@"songLink"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (self.ifNowPlay) {
                [kPlayer play];
            }
        });
        
        // 解析歌词
        self.lyricView.lyrics = [GKLyricParser lyricParserWithUrl:songDic[@"lrcLink"] isDelBlank:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
        [GKMessageTool showError:@"数据请求失败，请检查网络后重试！"];
    }];
    
    //    NSDictionary *params = @{@"id": self.model.music_id};
    //    // 获取歌曲信息
    //    [GKHttpManager getRequestWithApi:@"gkMusticInfo" params:params successBlock:^(id responseObject) {
    //
    //        NSDictionary *songDic = [responseObject[@"songList"] firstObject];
    //
    //        self.songDic = songDic;
    //
    //        // 背景图
    //        [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:songDic[@"songPicRadio"]] placeholderImage:[UIImage imageNamed:@"cm2_fm_bg-ip6"]];
    //
    //        // 设置播放地址
    //        kPlayer.playUrlStr = songDic[@"songLink"];
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //
    //            if (self.ifNowPlay) {
    //                [kPlayer play];
    //            }
    //        });
    //
    //        // 解析歌词
    //        self.lyricView.lyrics = [GKLyricParser lyricParserWithUrl:songDic[@"lrcLink"] isDelBlank:YES];
    //
    //    } failureBlock:^(NSError *error) {
    //        NSLog(@"请求失败");
    //    }];
}

- (void)setupTitleWithModel:(GKWYMusicModel *)model {
    self.nameLabel.text   = model.music_name;
    self.artistLabel.text = model.music_artist;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.gk_centerX = self.titleView.gk_width * 0.5;
    
    [self.artistLabel sizeToFit];
    self.artistLabel.gk_y       = self.nameLabel.gk_bottom + 2;
    self.artistLabel.gk_centerX = self.titleView.gk_width * 0.5;
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

- (void)shareAction {
    [GKMessageTool showText:@"点击分享"];
}

- (void)setupLockScreenControlInfo {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    // 锁屏播放
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        if (!self.isPlaying) {
            [self playMusic];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    // 锁屏暂停
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (self.isPlaying) {
            [self pauseMusic];
        }
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
        
        [self lovedCurrentMusic];
        
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

- (void)lovedCurrentMusic {
    [self.musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.music_id isEqualToString:self.model.music_id]) {
            obj.isLike = !obj.isLike;
            self.model = obj;
            *stop      = YES;
        }
    }];
    
    [GKWYMusicTool saveMusicList:self.musicList];
    self.controlView.is_love = self.model.isLike;
    
    [self setupLockScreenControlInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WYMusicLovedMusicNotification" object:nil];
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
    
    NSInteger interruptionType = [interuptionDict[AVAudioSessionInterruptionTypeKey] integerValue];
    NSInteger interruptionOption = [interuptionDict[AVAudioSessionInterruptionOptionKey] integerValue];
    
    if (interruptionType == AVAudioSessionInterruptionTypeBegan) {
        // 收到播放中断的通知，暂停播放
        if (self.isPlaying) {
            [self pauseMusic];
            self.isPlaying = NO;
        }
    }else {
        // 中断结束，判断是否需要恢复播放
        if (interruptionOption == AVAudioSessionInterruptionOptionShouldResume) {
            if (!self.isPlaying) {
                [self playMusic];
                self.isPlaying = YES;
            }
        }
    }
}

#pragma mark - 代理
#pragma mark - GKPlayerDelegate
- (void)gkPlayer:(GKPlayer *)player statusChanged:(GKPlayerStatus)status {
    switch (status) {
        case GKPlayerStatusBuffering:       
        {
            [self.controlView hideLoadingAnim];
            [self.controlView setupPlayBtn];
            
            self.isPlaying = YES;
            
            [self.coverView playedWithAnimated:YES];
        }
            break;
        case GKPlayerStatusPlaying:
        {
            [self.controlView hideLoadingAnim];
            [self.controlView setupPlayBtn];
            self.isPlaying = YES;
            
            [self.coverView playedWithAnimated:YES];
        }
            break;
        case GKPlayerStatusPaused:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView setupPauseBtn];
            });
            self.isPlaying = NO;
            
            if (self.isChanged) {
                self.isChanged = NO;
            }else {
                [self.coverView pausedWithAnimated:YES];
            }
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
        }
            break;
        case GKPlayerStatusStopped:
        {
            NSLog(@"播放停止了");
            [self.controlView setupPauseBtn];
            self.isPlaying = NO;
            
            if (self.isChanged) {
                self.isChanged = NO;
            }else {
                [self.coverView pausedWithAnimated:YES];
            }
        }
            break;
        case GKPlayerStatusEnded:
        {
            NSLog(@"播放结束了");
            if (self.isPlaying) {
                [self.controlView setupPauseBtn];
                self.isPlaying = NO;
                
                [self.coverView pausedWithAnimated:YES];
                
                self.controlView.currentTime = self.controlView.totalTime;
                
                // 播放结束，自动播放下一首
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.isAutoPlay = YES;
                    
                    [self playNextMusic];
                });
            }else {
                [self.controlView setupPauseBtn];
                self.isPlaying = NO;
                
                [self.coverView pausedWithAnimated:YES];
            }
        }
            break;
        case GKPlayerStatusError:
        {
            NSLog(@"播放出错了");
            [self.controlView setupPauseBtn];
            self.isPlaying = NO;
            
            [self.coverView pausedWithAnimated:YES];
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
    
    [self.lyricView scrollLyricWithCurrentTime:currentTime totalTime:totalTime];
}

- (void)gkPlayer:(GKPlayer *)player duration:(NSTimeInterval)duration {
    self.controlView.totalTime = [GKTool timeStrWithMsTime:duration];
    
    self.duration = duration;
}

#pragma mark - GKWYMusicVolumeViewDelegate
- (void)volumeSlideTouchBegan {
    //    self.gk_fullScreenPopDisabled = YES;
}

- (void)volumeSlideTouchEnded {
    //    self.gk_fullScreenPopDisabled = NO;
}

#pragma mark - GKWYMusicControlViewDelegate
- (void)controlView:(GKWYMusicControlView *)controlView didClickLove:(UIButton *)loveBtn {
    [self lovedCurrentMusic];
    if (self.model.isLike) {
        [GKMessageTool showSuccess:@"已添加到我喜欢的音乐" toView:self.view imageName:@"cm2_play_icn_loved" bgColor:[UIColor blackColor]];
    }else {
        [GKMessageTool showText:@"已取消喜欢" toView:self.view bgColor:[UIColor blackColor]];
    }
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickDownload:(UIButton *)downloadBtn {
    NSLog(@"下载");
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickComment:(UIButton *)commentBtn {
    NSLog(@"评论");
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickMore:(UIButton *)moreBtn {
    NSLog(@"更多");
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickLoop:(UIButton *)loopBtn {
    if (self.playStyle == GKWYPlayerPlayStyleLoop) {  // 循环->单曲
        self.playStyle = GKWYPlayerPlayStyleOne;
        self.outOrderList = nil;
        
        [self setCoverList:self.musicList];
    }else if (self.playStyle == GKWYPlayerPlayStyleOne) { // 单曲->随机
        self.playStyle = GKWYPlayerPlayStyleRandom;
        self.outOrderList = [self randomArray:self.musicList];
        
        [self setCoverList:self.outOrderList];
    }else { // 随机-> 循环
        self.playStyle = GKWYPlayerPlayStyleLoop;
        self.outOrderList = nil;
        
        [self setCoverList:self.musicList];
    }
    self.controlView.style = self.playStyle;
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.playStyle forKey:kPlayerPlayStyleKey];
}

- (void)setCoverList:(NSArray *)musicList {
    __block NSUInteger currentIndex = 0;
    [musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.music_id isEqualToString:self.model.music_id]) {
            currentIndex = idx;
            *stop = YES;
        }
    }];
    
    // 重置列表
    [self.coverView resetMusicList:musicList idx:currentIndex];
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickPrev:(UIButton *)prevBtn {
    if (self.isCoverScroll) return;
    self.isChanged = YES;
    
    if (self.isPlaying) {
        [kPlayer stop];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self playPrevMusic];
    });
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickPlay:(UIButton *)playBtn {
    if (self.isPlaying) {
        [self pauseMusic];
    }else {
        [self playMusic];
    }
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickNext:(UIButton *)nextBtn {
    if (self.isCoverScroll) return;
    
    self.isAutoPlay = NO;
    
    if (self.isPlaying) {
        [kPlayer stop];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.isChanged  = YES;
        
        [self playNextMusic];
    });
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
    //    // 防止手势冲突
    //    self.gk_fullScreenPopDisabled = YES;
}

- (void)controlView:(GKWYMusicControlView *)controlView didSliderTouchEnded:(float)value {
    self.isDraging = NO;
    kPlayer.progress = value;
    //    self.gk_fullScreenPopDisabled = NO;
    
    // 滚动歌词到对应位置
    [self.lyricView scrollLyricWithCurrentTime:(self.duration * value) totalTime:self.duration];
}

- (void)controlView:(GKWYMusicControlView *)controlView didSliderValueChange:(float)value {
    self.isDraging = YES;
    self.controlView.currentTime = [GKTool timeStrWithMsTime:(self.duration * value)];
}

- (void)controlView:(GKWYMusicControlView *)controlView didSliderTapped:(float)value {
    self.controlView.currentTime = [GKTool timeStrWithMsTime:(self.duration * value)];
    kPlayer.progress = value;
    
    // 滚动歌词到对应位置
    [self.lyricView scrollLyricWithCurrentTime:(self.duration * value) totalTime:self.duration];
}

#pragma mark - GKWYMusicCoverViewDelegate
- (void)scrollDidScroll {
    self.isCoverScroll = YES;
}

- (void)scrollWillChangeModel:(GKWYMusicModel *)model {
    //    NSLog(@"%@", model.music_name);
    [self setupTitleWithModel:model];
}

- (void)scrollDidChangeModel:(GKWYMusicModel *)model {
    //    NSLog(@"%@", model.music_name);
    self.isCoverScroll = NO;
    
    NSLog(@"结束");
    
    if (self.isChanged) return;
    
    [self setupTitleWithModel:model];
    
    if ([model.music_id isEqualToString:self.model.music_id]) {
        if (self.isPlaying) {
            [self.coverView playedWithAnimated:YES];
        }
    }else {
        __block NSInteger index = 0;

        [self.playList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.music_id isEqualToString:model.music_id]) {
                index = idx;
            }
        }];

        self.isChanged = YES;

        [self playMusicWithIndex:index list:self.playList];
    }
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
    if ([model.music_id isEqualToString:self.model.music_id]) {
        self.model = model;
        self.controlView.is_love = model.isLike;
    }
    
    listView.listArr = self.musicList;
    
    [self setupLockScreenControlInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WYMusicLovedMusicNotification" object:nil];
}

#pragma mark - 懒加载
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.userInteractionEnabled = NO;
        _bgImageView.clipsToBounds = YES;
        // 添加模糊效果
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        effectView.frame = _bgImageView.bounds;
        [_bgImageView addSubview:effectView];
    }
    return _bgImageView;
}

- (GKWYMusicCoverView *)coverView {
    if (!_coverView) {
        _coverView = [GKWYMusicCoverView new];
        _coverView.delegate = self;
    }
    return _coverView;
}

- (GKWYMusicLyricView *)lyricView {
    if (!_lyricView) {
        _lyricView = [GKWYMusicLyricView new];
        _lyricView.backgroundColor = [UIColor clearColor];
        
        //        __weak typeof(self) weakSelf = self;
        
        _lyricView.volumeViewSliderBlock = ^(BOOL isBegan) {
            //            weakSelf.gk_fullScreenPopDisabled = isBegan;
        };
        
        _lyricView.hidden = YES;
    }
    return _lyricView;
}

- (GKWYMusicControlView *)controlView {
    if (!_controlView) {
        _controlView = [GKWYMusicControlView new];
        _controlView.delegate = self;
    }
    return _controlView;
}

- (GKWYMusicListView *)listView {
    if (!_listView) {
        _listView = [GKWYMusicListView new];
        _listView.delegate = self;
    }
    return _listView;
}

@end

