//
//  GKAudioListView.m
//  GKMobileVLCKitDemo
//
//  Created by QuintGao on 2017/8/24.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKWYMusicListView.h"
#import "GKWYMusicListViewCell.h"

@interface GKWYMusicListView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *topLine;

@property (nonatomic, strong) UILabel *listLabel;
@property (nonatomic, strong) UILabel *countLabel;


@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIView *closeLine;

@property (nonatomic, strong) UITableView *listTable;

@end

@implementation GKWYMusicListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topView];
        [self addSubview:self.listTable];
        [self addSubview:self.closeBtn];
        
        [self.topView addSubview:self.topLine];
        [self.topView addSubview:self.listLabel];
        [self.topView addSubview:self.countLabel];
        
        [self.closeBtn addSubview:self.closeLine];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(50);
        }];
        
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(50);
        }];
        
        [self.listTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.topView.mas_bottom);
            make.bottom.equalTo(self.closeBtn.mas_top);
        }];
        
        [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.topView);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.listLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topView).offset(10);
            make.centerY.equalTo(self.topView);
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.listLabel.mas_right).offset(5);
            make.centerY.equalTo(self.topView);
        }];
        
        [self.closeLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.closeBtn);
            make.height.mas_equalTo(0.5);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusChanged:) name:@"AudioPlayStateChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerIdChanged:) name:@"PlayerPlayIdChanged" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setListArr:(NSArray *)listArr {
    _listArr = listArr;
    
    self.countLabel.text = [NSString stringWithFormat:@"%zd首", listArr.count];
    
    __block NSInteger playIndex = 0;
    [listArr enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isPlaying) {
            playIndex = idx;
            *stop = YES;
        }
    }];
    
    [self.listTable reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:playIndex inSection:0];
        
        [self.listTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    });
}

- (void)closeBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(listViewDidClose)]) {
        [self.delegate listViewDidClose];
    }
}

- (void)statusChanged:(NSNotification *)notify {
    [self.listTable reloadData];
}

- (void)playerIdChanged:(NSNotification *)notify {
    [self.listTable reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYMusicListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    
    cell.model = self.listArr[indexPath.row];
    
    cell.likeClicked = ^(GKWYMusicModel *model) {
        if ([self.delegate respondsToSelector:@selector(listView:didLovedWithRow:)]) {
            [self.delegate listView:self didLovedWithRow:indexPath.row];
        }
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(listView:didSelectRow:)]) {
        [self.delegate listView:self didSelectRow:indexPath.row];
    }
}

#pragma mark - 懒加载
- (UIView *)topView {
    if (!_topView) {
        _topView = [UIView new];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [UIView new];
        _topLine.backgroundColor = GKColorGray(222);
    }
    return _topLine;
}

- (UILabel *)listLabel {
    if (!_listLabel) {
        _listLabel = [UILabel new];
        _listLabel.textColor = [UIColor blackColor];
        _listLabel.text = @"播放列表";
    }
    return _listLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [UILabel new];
        _countLabel.font = [UIFont systemFontOfSize:13];
        _countLabel.textColor = [UIColor lightGrayColor];
    }
    return _countLabel;
}

- (UITableView *)listTable {
    if (!_listTable) {
        _listTable = [UITableView new];
        _listTable.dataSource = self;
        _listTable.delegate   = self;
        _listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_listTable registerNib:[UINib nibWithNibName:NSStringFromClass([GKWYMusicListViewCell class]) bundle:nil] forCellReuseIdentifier:@"ListCell"];
        _listTable.rowHeight = 44;
        if (@available(iOS 11.0, *)) {
            _listTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return _listTable;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton new];
        _closeBtn.backgroundColor = [UIColor whiteColor];
        [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIView *)closeLine {
    if (!_closeLine) {
        _closeLine = [UIView new];
        _closeLine.backgroundColor = GKColorGray(222);
    }
    return _closeLine;
}

@end
