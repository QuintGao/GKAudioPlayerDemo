//
//  GKWYNavigationController.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/10/12.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKWYNavigationController.h"

@interface GKWYNavigationController ()

@end

@implementation GKWYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) {
        
        UIViewController *root = self.childViewControllers[0];
        
        if (viewController != root) {
            
            if ([viewController isKindOfClass:[GKNavigationBarViewController class]]) {
                GKNavigationBarViewController *vc = (GKNavigationBarViewController *)viewController;
                vc.gk_navLeftBarButtonItem = [UIBarButtonItem itemWithImageName:@"cm2_topbar_icn_back" target:self action:@selector(backAction)];
            }
        }
    }
    
    [super pushViewController:viewController animated:animated];
}

- (void)backAction {
    [self popViewControllerAnimated:YES];
}

@end
