//
//  GKWYMusicListCell.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GKWYMusicModel.h"

static NSString * const kWYMusicListCellID = @"WYMusicListCellID";

@interface GKWYMusicListCell : UITableViewCell

@property (nonatomic, strong) GKWYMusicModel *model;

@property (nonatomic, assign) NSInteger row;

@property (nonatomic, copy) void(^likeClicked)(GKWYMusicModel *model);

@end
