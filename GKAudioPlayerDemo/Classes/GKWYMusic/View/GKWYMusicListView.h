//
//  GKAudioListView.h
//  GKMobileVLCKitDemo
//
//  Created by QuintGao on 2017/8/24.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKWYMusicListView;

@protocol GKWYMusicListViewDelegate <NSObject>

- (void)listViewDidClose;

- (void)listView:(GKWYMusicListView *)listView didSelectRow:(NSInteger)row;

- (void)listView:(GKWYMusicListView *)listView didLovedWithRow:(NSInteger)row;

@end

@interface GKWYMusicListView : UIView

@property (nonatomic, weak) id<GKWYMusicListViewDelegate> delegate;

@property (nonatomic, strong) NSArray *listArr;

@end
