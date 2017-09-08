//
//  UIViewController+GKCategory.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/8.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "UIViewController+GKCategory.h"

@implementation UIViewController (GKWYCategory)

- (UIViewController *)visibleViewControllerIfExist {
    
    if (self.presentedViewController) {
        return [self.presentedViewController visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).topViewController visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController visibleViewControllerIfExist];
    }
    
    if ([self isViewLoaded] && self.view.window) {
        return self;
    } else {
        NSLog(@"visibleViewControllerIfExist:，找不到可见的viewController。self = %@, self.view.window = %@", self, self.view.window);
        return nil;
    }
}


@end
