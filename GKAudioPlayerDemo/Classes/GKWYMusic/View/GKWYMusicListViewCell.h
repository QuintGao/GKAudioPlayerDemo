//
//  GKAudioViewCell.h
//  GKMobileVLCKitDemo
//
//  Created by QuintGao on 2017/8/23.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYMusicModel.h"

@interface GKWYMusicListViewCell : UITableViewCell

@property (nonatomic, strong) GKWYMusicModel *model;

@property (nonatomic, copy) void(^likeClicked)(GKWYMusicModel *model);

@end
