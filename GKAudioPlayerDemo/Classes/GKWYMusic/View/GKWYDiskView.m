//
//  GKWYDiskView.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/10/9.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKWYDiskView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface GKWYDiskView()

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation GKWYDiskView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.diskImgView];
        [self.diskImgView addSubview:self.imgView];
        
        [self.diskImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(66);
            make.width.height.mas_equalTo(KScreenW - 80);
        }];
        
        CGFloat imgWH = KScreenW - 80 - 100;
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.diskImgView);
            make.width.height.mas_equalTo(imgWH);
        }];
        self.imgView.layer.cornerRadius  = imgWH * 0.5;
        self.imgView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setImgurl:(NSString *)imgurl {
    _imgurl = imgurl;
    
    if (imgurl) {
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:imgurl] placeholderImage:[UIImage imageNamed:@"cm2_fm_bg-ip6"]];
    }else {
        self.imgView.image = nil;
    }
}

- (UIImageView *)diskImgView {
    if (!_diskImgView) {
        _diskImgView = [UIImageView new];
        _diskImgView.image = [UIImage imageNamed:@"cm2_play_disc-ip6"];
    }
    return _diskImgView;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
    }
    return _imgView;
}

@end
