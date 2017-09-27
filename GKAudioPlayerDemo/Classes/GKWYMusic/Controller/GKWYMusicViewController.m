//
//  GKWYMusicViewController.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKWYMusicViewController.h"
#import "GKWYMusicListCell.h"
#import "GKWYPlayerViewController.h"
#import "GKWYMusicTool.h"

@interface GKWYMusicViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *listTable;

@property (nonatomic, strong) NSArray *listArr;

@end

@implementation GKWYMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBackgroundColor = GKColorRGB(200, 38, 39);
    
    self.gk_navigationItem.title = @"我的音乐";
    
    [self.view addSubview:self.listTable];
    [self.listTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
        make.bottom.equalTo(self.view);
    }];
    
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"WYMusicLovedMusicNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"WYPlayerChangeMusicNotification" object:nil];
}

- (void)loadData {
    
    self.listArr = [GKWYMusicTool musicList];
    
    [self.listTable reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYMusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:kWYMusicListCellID forIndexPath:indexPath];
    
    cell.row   = indexPath.row;
    
    cell.model = self.listArr[indexPath.row];
    
    cell.likeClicked = ^(GKWYMusicModel *model) {
        model.isLike = !model.isLike;
        
        [GKWYMusicTool saveMusicList:self.listArr];
        
        [self.listTable reloadData];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GKWYPlayerViewController *playerVC = [GKWYPlayerViewController sharedInstance];
    
    [playerVC playMusicWithIndex:indexPath.row list:self.listArr];
    
    [self.navigationController pushViewController:playerVC animated:YES];
}

#pragma mark - 懒加载

- (UITableView *)listTable {
    if (!_listTable) {
        _listTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _listTable.dataSource   = self;
        _listTable.delegate     = self;
        _listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_listTable registerClass:[GKWYMusicListCell class] forCellReuseIdentifier:kWYMusicListCellID];
        _listTable.rowHeight = 54;
    }
    return _listTable;
}

@end
