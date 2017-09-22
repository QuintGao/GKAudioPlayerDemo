//
//  AppDelegate.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, assign) BOOL isFirstLaunch;

- (void)showPlayBtn;
- (void)hidePlayBtn;

@end

