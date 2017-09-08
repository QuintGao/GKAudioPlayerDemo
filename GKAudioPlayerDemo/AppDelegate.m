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
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setupNavStyle];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [UINavigationController rootVC:[GKWYMusicViewController new] translationScale:NO];
    
    [self.window makeKeyAndVisible];
    
    [self setupPlayBtn];
    
    return YES;
}

- (void)setupNavStyle {
    // 设置导航栏风格
    [GKConfigure setupCustomConfigure:^(GKNavigationBarConfigure *configure) {
        // 导航栏背景色
        configure.backgroundColor = [UIColor blackColor];
        // 标题文字颜色
        configure.titleColor = [UIColor whiteColor];
        // 标题文字字体
        configure.titleFont = [UIFont systemFontOfSize:18.0];
        // 导航栏风格
        configure.statusBarStyle = UIStatusBarStyleLightContent;
        // 返回按钮
        configure.backStyle = GKNavigationBarBackStyleWhite;
    }];
}

- (void)setupPlayBtn {
    self.playBtn = [UIButton new];
    [self.playBtn setImage:[UIImage imageNamed:@"cm2_topbar_icn_playing1"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"cm2_topbar_icn_playing1_prs"] forState:UIControlStateHighlighted];
    [self.playBtn addTarget:self action:@selector(topbarPlayBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:self.playBtn];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.window).offset(28);
        make.right.equalTo(self.window).offset(-12);
        make.width.height.mas_equalTo(28);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatusChanged:) name:@"WYMusicPlayStateChanged" object:nil];
}

- (void)topbarPlayBtnAction:(id)sender {
    NSString *currentMusicID = [[NSUserDefaults standardUserDefaults] objectForKey:kPlayerLastPlayIDKey];
    
    NSInteger index = [GKWYMusicTool indexFromID:currentMusicID];
    
    [kWYPlayerVC playMusicWithIndex:index list:[GKWYMusicTool musicList]];
    
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
