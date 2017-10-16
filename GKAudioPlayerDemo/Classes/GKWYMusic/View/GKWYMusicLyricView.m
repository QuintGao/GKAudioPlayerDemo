//
//  GKWYMusicLyricView.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/19.
//  Copyright © 2017年 高坤. All rights reserved.
//  歌词及转盘视图显示视图

#import "GKWYMusicLyricView.h"
#import "GKWYMusicVolumeView.h"
#import "GKPlayer.h"

@interface GKWYMusicLyricView()<GKWYMusicVolumeViewDelegate, UITableViewDataSource, UITableViewDelegate>

/** 音量控制视图 */
@property (nonatomic, strong) GKWYMusicVolumeView *volumeView;

/** 歌词列表 */
@property (nonatomic, strong) UITableView *lyricTable;

/** 提示 */
@property (nonatomic, strong) UILabel *tipsLabel;

/** 歌词滑动时的时间线及时间 */
@property (nonatomic, strong) UIView *timeLineView;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation GKWYMusicLyricView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.volumeView];
        
        [self addSubview:self.lyricTable];
        [self.lyricTable addSubview:self.tipsLabel];
        
        [self addSubview:self.timeLineView];
        [self addSubview:self.timeLabel];
        
        [self.volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self).offset(10);
            make.height.mas_equalTo(34);
        }];
        
        [self.lyricTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(self.volumeView.mas_bottom);
        }];
        
        [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.lyricTable);
        }];
        
        [self.timeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(50);
            make.right.equalTo(self).offset(-50);
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

- (void)setLyrics:(NSArray *)lyrics {
    _lyrics = lyrics;
    
    if (lyrics) {
        if (lyrics.count == 0) {
            self.tipsLabel.hidden = NO;
            self.tipsLabel.text   = @"纯音乐，无歌词";
            
            [self.lyricTable reloadData];
        }else {
            self.tipsLabel.hidden = YES;
            
            [self.lyricTable reloadData];
            
            // 滚动到中间行
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
            [self.lyricTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }else {
        self.tipsLabel.hidden = NO;
        self.tipsLabel.text   = @"歌词加载中...";
        
        [self.lyricTable reloadData];
    }
}


/**
 根据当前时间及总时间滚动歌词

 @param currentTime 当前时间
 @param totalTime 总时间
 */
- (void)scrollLyricWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (self.lyrics.count == 0) self.lyricIndex = 0;
    
    for (NSInteger i = 0; i < self.lyrics.count; i++) {
        GKLyricModel *currentLyric = self.lyrics[i];
        GKLyricModel *nextLyric    = nil;
        
        if (i < self.lyrics.count - 1) {
            nextLyric = self.lyrics[i + 1];
        }
        
        if ((self.lyricIndex != i && currentTime > currentLyric.msTime) && (!nextLyric || currentTime < nextLyric.msTime)) {
            self.lyricIndex = i;
            
            //刷表
            [self.lyricTable reloadData];
            
            // 不是由拖拽产生的滚动，自动滚滚动歌词
            if (!self.isScrolling) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.lyricIndex + 5) inSection:0];
                
                [self.lyricTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            }
        }
    }
}

- (void)hideSystemVolumeView {
    [self.volumeView hideSystemVolumeView];
}

- (void)showSystemVolumeView {
    [self.volumeView showSystemVolumeView];
}

#pragma mark - 代理
#pragma mark - GKWYMusicVolumeViewDelegate
- (void)volumeSlideTouchBegan {
    !self.volumeViewSliderBlock ? : self.volumeViewSliderBlock(YES);
}

- (void)volumeSlideTouchEnded {
    !self.volumeViewSliderBlock ? : self.volumeViewSliderBlock(NO);
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 多加10行，是为了上下留白
    return self.lyrics.count + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LyricCell" forIndexPath:indexPath];
    cell.textLabel.textColor     = [UIColor grayColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font          = [UIFont systemFontOfSize:16.0];
    cell.selectedBackgroundView  = [UIView new];
    cell.backgroundColor         = [UIColor clearColor];
    
    if (indexPath.row < 5 || indexPath.row > self.lyrics.count + 4) {
        cell.textLabel.textColor = [UIColor clearColor];
        cell.textLabel.text      = @"";
    }else {
        cell.textLabel.text = [self.lyrics[indexPath.row - 5] content];
        
        if (indexPath.row == self.lyricIndex + 5) {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font      = [UIFont systemFontOfSize:18.0];
        }else {
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font      = [UIFont systemFontOfSize:16.0];
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
    self.timeLabel.hidden    = NO;
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
    self.isScrolling = YES;
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
        model = self.lyrics.firstObject;
    }else if (index > self.lyrics.count - 1) {
        model = nil;
    }else {
        model = self.lyrics[index];
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

#pragma mark - 懒加载
- (GKWYMusicVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [GKWYMusicVolumeView new];
        _volumeView.delegate = self;
    }
    return _volumeView;
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
        _timeLabel           = [UILabel new];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font      = [UIFont systemFontOfSize:13.0];
        _timeLabel.hidden    = YES;
    }
    return _timeLabel;
}




@end
