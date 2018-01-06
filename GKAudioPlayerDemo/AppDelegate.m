//
//  AppDelegate.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "AppDelegate.h"
#import "GKWYMusicViewController.h"
#import "GKWYPlayerViewController.h"
#import "GKWYNavigationController.h"
#import <AVFoundation/AVFoundation.h>
#import "GKWYMusicModel.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setupNavStyle];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [GKWYNavigationController rootVC:[GKWYMusicViewController new] translationScale:NO];
    
    [self.window makeKeyAndVisible];
    
    self.isFirstLaunch = YES;
    
    [self setupPlayBtn];
    
    [self loadMusicList];
    
    // 网络监测
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [GKWYMusicTool setNetworkState:@"wwan"];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [GKWYMusicTool setNetworkState:@"wifi"];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                [GKWYMusicTool setNetworkState:@"none"];
                break;
            case AFNetworkReachabilityStatusUnknown:
                [GKWYMusicTool setNetworkState:@"none"];
                break;
                
            default:
                break;
        }
        // 发送网络状态改变的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkStateChangedNotification" object:nil];
    }];
    
    [manager startMonitoring];
    
    return YES;
}

- (void)setupNavStyle {
    // 设置导航栏风格
    [GKConfigure setupCustomConfigure:^(GKNavigationBarConfigure *configure) {
        // 导航栏背景色
        configure.backgroundColor   = [UIColor blackColor];
        // 标题文字颜色
        configure.titleColor        = [UIColor whiteColor];
        // 标题文字字体
        configure.titleFont         = [UIFont systemFontOfSize:18.0];
        // 导航栏风格
        configure.statusBarStyle    = UIStatusBarStyleLightContent;
        // 返回按钮
        configure.backStyle         = GKNavigationBarBackStyleNone;
        
        configure.navItem_space     = 4;
    }];
    
    // 适配iOS11
    if (@available(iOS 11.0, *)) {
        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [UITableView appearance].estimatedRowHeight = 0;
        [UITableView appearance].estimatedSectionFooterHeight = 0;
        [UITableView appearance].estimatedSectionHeaderHeight = 0;
    }
}

- (void)loadMusicList {
    
    //    [GKHttpManager getRequestWithApi:@"gkMustic" params:nil successBlock:^(id responseObject) {
    //
    //        NSArray *musics = [NSArray yy_modelArrayWithClass:[GKWYMusicModel class] json:responseObject];
    //
    //        [GKWYMusicTool saveMusicList:musics];
    //
    //        NSString *currentMusicID = [[NSUserDefaults standardUserDefaults] objectForKey:kPlayerLastPlayIDKey];
    //
    //        NSInteger index = [GKWYMusicTool indexFromID:currentMusicID];
    //
    //        [kWYPlayerVC loadMusicWithIndex:index list:[GKWYMusicTool musicList]];
    //
    //    } failureBlock:^(NSError *error) {
    //        NSLog(@"%@", error);
    //    }];
    
    NSArray *musics = [GKWYMusicTool musicList];
    
    [GKWYMusicTool saveMusicList:musics];
    
    NSString *currentMusicID = [[NSUserDefaults standardUserDefaults] objectForKey:kPlayerLastPlayIDKey];
    
    NSInteger index = [GKWYMusicTool indexFromID:currentMusicID];
    
    [kWYPlayerVC loadMusicWithIndex:index list:[GKWYMusicTool musicList]];
    
}

- (void)setupPlayBtn {
    self.playBtn = [UIButton new];
    [self.playBtn setImage:[UIImage imageNamed:@"cm2_topbar_icn_playing1"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"cm2_topbar_icn_playing1_prs"] forState:UIControlStateHighlighted];
    [self.playBtn addTarget:self action:@selector(topbarPlayBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:self.playBtn];
    
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.window).offset(statusBarFrame.size.height);
        make.right.equalTo(self.window).offset(-4);
        make.width.height.mas_equalTo(44);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatusChanged:) name:@"WYMusicPlayStateChanged" object:nil];
}

- (void)topbarPlayBtnAction:(id)sender {
    [[GKWYMusicTool visibleViewController].navigationController pushViewController:kWYPlayerVC animated:YES];
}

- (void)showPlayBtn {
    self.playBtn.hidden = NO;
}

- (void)hidePlayBtn {
    self.playBtn.hidden = YES;
}

- (void)playStatusChanged:(NSNotification *)notify {
    if (kWYPlayerVC.isPlaying) {
        NSMutableArray *images = [NSMutableArray new];
        for (NSInteger i = 0; i < 6; i++) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_topbar_icn_playing%zd", i + 1];
            [images addObject:[UIImage imageNamed:imageName]];
        }
        
        for (NSInteger i = 6; i > 0; i--) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_topbar_icn_playing%zd", i];
            [images addObject:[UIImage imageNamed:imageName]];
        }
        
        self.playBtn.imageView.animationImages   = images;
        self.playBtn.imageView.animationDuration = 0.75;
        [self.playBtn.imageView startAnimating];
    }else {
        if (self.playBtn.imageView.isAnimating) {
            [self.playBtn.imageView stopAnimating];
        }
        [self.playBtn setImage:[UIImage imageNamed:@"cm2_topbar_icn_playing1"] forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"cm2_topbar_icn_playing1_prs"] forState:UIControlStateHighlighted];
    }
}

@end
