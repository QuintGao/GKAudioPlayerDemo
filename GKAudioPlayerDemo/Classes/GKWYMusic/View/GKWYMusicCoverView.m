//
//  GKWYMusicCoverView.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/19.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKWYMusicCoverView.h"
#import "GKWYDiskView.h"

@interface GKWYMusicCoverView()<UIScrollViewDelegate>

/** 顶部分割线 */
@property (nonatomic, strong) UIView *sepLineView;

/** 唱片背景 */
@property (nonatomic, strong) UIView *diskBgView;

///** 切换唱片的scrollview */
//@property (nonatomic, strong) UIScrollView *diskScrollView;

/** 唱片视图 */
@property (nonatomic, strong) GKWYDiskView *leftDiskView;
@property (nonatomic, strong) GKWYDiskView *centerDiskView;
@property (nonatomic, strong) GKWYDiskView *rightDiskView;

@property (nonatomic, assign) NSInteger currentIndex;

/** 指针 */
@property (nonatomic, strong) UIImageView *needleView;

/** 定时器 */
@property (nonatomic, strong) CADisplayLink *displayLink;

/** 是否正在动画 */
@property (nonatomic, assign) BOOL isAnimation;

@property (nonatomic, strong) NSArray *musics;

@property (nonatomic, copy) finished finished;
/** 是否是由用户点击切换歌曲 */
@property (nonatomic, assign) BOOL isChanged;

@end

@implementation GKWYMusicCoverView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 超出部分裁剪
        self.clipsToBounds = YES;
        
        [self addSubview:self.sepLineView];
        
        [self addSubview:self.diskBgView];
        
        [self addSubview:self.diskScrollView];
        
        [self addSubview:self.needleView];
        
        [self.sepLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.diskBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(66 - 2.5);
            make.width.height.mas_equalTo(KScreenW - 75);
        }];
        
        self.diskBgView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor;
        self.diskBgView.layer.borderWidth = 10;
        self.diskBgView.layer.cornerRadius = (KScreenW - 75) * 0.5;
        
        [self.diskScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        self.isAnimation = YES;
        
        [self.diskScrollView addSubview:self.leftDiskView];
        [self.diskScrollView addSubview:self.centerDiskView];
        [self.diskScrollView addSubview:self.rightDiskView];
        
        self.diskScrollView.contentSize = CGSizeMake(KScreenW * 3, 0);
        
        [self setScrollViewContentOffsetCenter];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChanged:) name:@"NetworkStateChangedNotification" object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.needleView.gk_centerX = KScreenW * 0.5 + 25;
    
    self.needleView.gk_y       = -25;
    
    [self pausedWithAnimated:NO];
    
    CGFloat diskW = CGRectGetWidth(self.diskScrollView.frame);
    CGFloat diskH = CGRectGetHeight(self.diskScrollView.frame);
    
    // 设置frame
    self.leftDiskView.frame   = CGRectMake(0, 0, diskW, diskH);
    self.centerDiskView.frame = CGRectMake(diskW, 0, diskW, diskH);
    self.rightDiskView.frame  = CGRectMake(2 * diskW, 0, diskW, diskH);
}

- (void)networkStateChanged:(NSNotification *)notify {
    self.currentIndex = self.currentIndex;
}

- (void)setupMusicList:(NSArray *)musics idx:(NSInteger)currentIndex {
   
    [self resetCover];
    
    self.musics         = musics;
    
    [self setCurrentIndex:currentIndex needChange:YES];
}

// 重置列表顺序
- (void)resetMusicList:(NSArray *)musics idx:(NSInteger)currentIndex {
    self.musics          = musics;
    
    [self setCurrentIndex:currentIndex needChange:NO];
}

// 滑动切换歌曲
- (void)scrollChangeIsNext:(BOOL)isNext Finished:(finished)finished {
    
    self.isChanged = YES;
    
    self.finished = finished;
    
    CGFloat pointX = isNext ? 2 * KScreenW : 0;
    
    CGPoint offset = CGPointMake(pointX, 0);
    
    [self pausedWithAnimated:YES];
    
    [self.diskScrollView setContentOffset:offset animated:YES];
}

- (void)setCurrentIndex:(NSInteger)currentIndex needChange:(BOOL)needChange {
    if (currentIndex >= 0) {
        self.currentIndex    = currentIndex;
        
        NSInteger count      = self.musics.count;
        NSInteger leftIndex  = (currentIndex + count - 1) % count;
        NSInteger rightIndex = (currentIndex + 1) % count;
        
        GKWYMusicModel *leftM   = self.musics[leftIndex];
        GKWYMusicModel *centerM = self.musics[currentIndex];
        GKWYMusicModel *rightM  = self.musics[rightIndex];
        
        // 设置图片
        self.centerDiskView.imgurl = centerM.music_cover;
        
        if (needChange) {
            // 每次设置后，移到中间
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setScrollViewContentOffsetCenter];
                
                self.leftDiskView.imgurl   = leftM.music_cover;
                self.rightDiskView.imgurl  = rightM.music_cover;
                
                if (self.isChanged) {
                    !self.finished ? : self.finished();
                    self.isChanged = NO;
                }
            });
        }else {
            self.leftDiskView.imgurl  = leftM.music_cover;
            self.rightDiskView.imgurl = rightM.music_cover;
        }
    }
}

- (void)setScrollViewContentOffsetCenter {
    [self.diskScrollView setContentOffset:CGPointMake(KScreenW, 0)];
}

// 播放音乐时，指针恢复，图片旋转
- (void)playedWithAnimated:(BOOL)animated {
    
    if (self.isAnimation) return;
    
    self.isAnimation = YES;
    
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

// 停止音乐时，指针旋转-30°，图片停止旋转
- (void)pausedWithAnimated:(BOOL)animated {
    
    if (!self.isAnimation) return;
    
    self.isAnimation = NO;
    
    [self setAnchorPoint:CGPointMake(25.0/97, 25.0/153) forView:self.needleView];
    
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            self.needleView.transform = CGAffineTransformMakeRotation(-M_PI_2 / 3);
        }];
    }else {
        self.needleView.transform = CGAffineTransformMakeRotation(-M_PI_2 / 3);
    }
    
    [self.displayLink invalidate];
    self.displayLink = nil;
}

// 重置封面
- (void)resetCover {
    // 恢复转盘
    self.centerDiskView.diskImgView.transform = CGAffineTransformIdentity;
    
    [self.displayLink invalidate];
    self.displayLink = nil;
}

// 图片旋转
- (void)animation {
    self.centerDiskView.diskImgView.transform = CGAffineTransformRotate(self.centerDiskView.diskImgView.transform, M_PI_4 / 100);
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self caculateCurIndex];
    
    CGFloat scrollW = CGRectGetWidth(scrollView.frame);
    
    if (scrollW == 0) return;
    // 滚动超过一半时
    CGFloat offsetX = scrollView.contentOffset.x;
    
    if (offsetX == 2 * scrollW) {
//        self.currentIndex = (self.currentIndex + 1) % self.musics.count;
    }else if (offsetX == 0) {
//        self.currentIndex = (self.currentIndex - 1 + self.musics.count) % self.musics.count;
//        NSLog(@"滑动中，当前索引%zd", self.currentIndex);
    }else if (offsetX <= 0.5 * scrollW) { // 左滑
        NSInteger idx = (self.currentIndex - 1 + self.musics.count) % self.musics.count;
        GKWYMusicModel *model = self.musics[idx];
        
        if ([self.delegate respondsToSelector:@selector(scrollWillChangeModel:)]) {
            [self.delegate scrollWillChangeModel:model];
        }
    }else if (offsetX >= 1.5 * scrollW) { // 右滑
        NSInteger idx = (self.currentIndex + 1) % self.musics.count;
        GKWYMusicModel *model = self.musics[idx];
        
        if ([self.delegate respondsToSelector:@selector(scrollWillChangeModel:)]) {
            [self.delegate scrollWillChangeModel:model];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pausedWithAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(scrollDidScroll)]) {
        [self.delegate scrollDidScroll];
    }
}

// scrollview拖动时结束减速时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"滑动结束，当前索引%zd", self.currentIndex);
    
    [self scrollViewDidEnd:scrollView];
}

// scrollview结束动画时调用
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    NSLog(@"滑动结束，当前索引%zd", self.currentIndex);
    
    [self scrollViewDidEnd:scrollView];
}

- (void)scrollViewDidEnd:(UIScrollView *)scrollView {
    // 获取结束时，获取索引
    CGFloat scrollW = CGRectGetWidth(scrollView.frame);
    CGFloat offsetX = scrollView.contentOffset.x;
    
    if (offsetX == 2 * scrollW) {
        NSInteger currentIndex = (self.currentIndex + 1) % self.musics.count;
        
        [self setCurrentIndex:currentIndex needChange:YES];
        
    }else if (offsetX == 0) {
        NSInteger currentIndex = (self.currentIndex - 1 + self.musics.count) % self.musics.count;
        
        [self setCurrentIndex:currentIndex needChange:YES];
    }else {
        [self setScrollViewContentOffsetCenter];
    }
    
    GKWYMusicModel *model = self.musics[self.currentIndex];
    
    if ([self.delegate respondsToSelector:@selector(scrollDidChangeModel:)]) {
        [self.delegate scrollDidChangeModel:model];
    }
}

#pragma mark - 懒加载
- (UIView *)sepLineView {
    if (!_sepLineView) {
        _sepLineView = [UIView new];
        _sepLineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    }
    return _sepLineView;
}

- (UIView *)diskBgView {
    if (!_diskBgView) {
        _diskBgView = [UIView new];
        _diskBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
    return _diskBgView;
}

- (UIScrollView *)diskScrollView {
    if (!_diskScrollView) {
        _diskScrollView = [[UIScrollView alloc] init];
        _diskScrollView.delegate        = self;
        _diskScrollView.pagingEnabled   = YES;
        _diskScrollView.backgroundColor = [UIColor clearColor];
        _diskScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _diskScrollView;
}

- (GKWYDiskView *)leftDiskView {
    if (!_leftDiskView) {
        _leftDiskView = [GKWYDiskView new];
    }
    return _leftDiskView;
}

- (GKWYDiskView *)centerDiskView {
    if (!_centerDiskView) {
        _centerDiskView = [GKWYDiskView new];
    }
    return _centerDiskView;
}

- (GKWYDiskView *)rightDiskView {
    if (!_rightDiskView) {
        _rightDiskView = [GKWYDiskView new];
    }
    return _rightDiskView;
}

- (UIImageView *)needleView {
    if (!_needleView) {
        _needleView = [UIImageView new];
        _needleView.image = [UIImage imageNamed:@"cm2_play_needle_play"];
        [_needleView sizeToFit];
    }
    return _needleView;
}

@end
