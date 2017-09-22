//
//  GKWYMusicCoverView.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/19.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKWYMusicCoverView.h"

@interface GKWYMusicCoverView()

@property (nonatomic, strong) UIView *sepLineView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIImageView *needleView;

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation GKWYMusicCoverView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 超出部分裁剪
        self.clipsToBounds = YES;
        
        [self addSubview:self.sepLineView];
        [self addSubview:self.imageView];
        [self addSubview:self.coverView];
        
        [self addSubview:self.needleView];
        
        [self.sepLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-12);
            make.width.height.mas_equalTo(KScreenW - 80);
        }];
        
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-12);
            make.width.height.mas_equalTo(KScreenW - 75);
        }];
        
        self.coverView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor;
        self.coverView.layer.borderWidth = 10;
        self.coverView.layer.cornerRadius = (KScreenW - 75) * 0.5;
        
        [self addSubview:self.imgView];
        
        CGFloat imgWH = KScreenW - 80 - 100;
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.imageView);
            make.width.height.mas_equalTo(imgWH);
        }];
        
        self.imgView.layer.cornerRadius = imgWH * 0.5;
        self.imgView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.needleView.gk_centerX = KScreenW * 0.5 + 25;
    
    self.needleView.gk_y       = -25;
    
    [self pausedWithAnimated:NO];
}

- (void)playedWithAnimated:(BOOL)animated {
    [self setAnchorPoint:CGPointMake(25.0/97, 25.0/153) forView:self.needleView];
    
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            self.needleView.transform = CGAffineTransformIdentity;
        }];
    }else {
        self.needleView.transform = CGAffineTransformIdentity;
    }
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animation)];
    
    // 加入到主循环中
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)animation {
    self.imgView.transform = CGAffineTransformRotate(self.imgView.transform, M_PI_4 / 100);
}

- (void)pausedWithAnimated:(BOOL)animated {
    
    [self setAnchorPoint:CGPointMake(25.0/97, 25.0/153) forView:self.needleView];
    
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            self.needleView.transform = CGAffineTransformMakeRotation(-M_PI_4);
        }];
    }else {
        self.needleView.transform = CGAffineTransformMakeRotation(-M_PI_4);
    }
    
    [self.displayLink invalidate];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = view.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    
    view.center = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
}

#pragma mark - 懒加载
- (UIView *)sepLineView {
    if (!_sepLineView) {
        _sepLineView = [UIView new];
        _sepLineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    }
    return _sepLineView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.image = [UIImage imageNamed:@"cm2_play_disc-ip6"];
    }
    return _imageView;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [UIView new];
        _coverView.backgroundColor = [UIColor clearColor];
    }
    return _coverView;
}

- (UIImageView *)needleView {
    if (!_needleView) {
        _needleView = [UIImageView new];
        _needleView.image = [UIImage imageNamed:@"cm2_play_needle_play"];
        [_needleView sizeToFit];
    }
    return _needleView;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
    }
    return _imgView;
}

@end
