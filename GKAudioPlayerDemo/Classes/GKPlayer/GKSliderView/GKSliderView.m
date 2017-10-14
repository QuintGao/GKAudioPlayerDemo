//
//  GKSliderView.m
//  GKSliderView
//
//  Created by QuintGao on 2017/9/6.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKSliderView.h"

/** 滑块的大小 */
#define kSliderBtnWH  19.0
/** 间距 */
#define kProgressMargin 2.0
/** 进度的宽度 */
#define kProgressW    self.frame.size.width - kProgressMargin
/** 进度的高度 */
#define kProgressH    3.0

@interface GKSliderView()

/** 进度背景 */
@property (nonatomic, strong) UIImageView *bgProgressView;
/** 缓存进度 */
@property (nonatomic, strong) UIImageView *bufferProgressView;
/** 滑动进度 */
@property (nonatomic, strong) UIImageView *sliderProgressView;

/** 滑块 */
@property (nonatomic, strong) GKSliderButton *sliderBtn;

@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation GKSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.allowTapped = YES;
        
        [self addSubViews];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bgProgressView.centerY     = self.height * 0.5;
    self.bufferProgressView.centerY = self.height * 0.5;
    self.sliderProgressView.centerY = self.height * 0.5;
    self.bgProgressView.width       = self.width - kProgressMargin * 2;
    self.sliderBtn.centerY          = self.height * 0.5;
}

/**
 添加子视图
 */
- (void)addSubViews {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.bgProgressView];
    [self addSubview:self.bufferProgressView];
    [self addSubview:self.sliderProgressView];
    [self addSubview:self.sliderBtn];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    
    [self addGestureRecognizer:self.tapGesture];
    
    self.bgProgressView.frame = CGRectMake(kProgressMargin, 0, 0, kProgressH);
    
    self.bufferProgressView.frame = self.bgProgressView.frame;
    
    self.sliderProgressView.frame = self.bgProgressView.frame;
    
    self.sliderBtn.frame = CGRectMake(0, 0, kSliderBtnWH, kSliderBtnWH);
    
    [self.sliderBtn hideActivityAnim];
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _maximumTrackTintColor = maximumTrackTintColor;
    
    self.bgProgressView.backgroundColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    _minimumTrackTintColor = minimumTrackTintColor;
    
    self.sliderProgressView.backgroundColor = minimumTrackTintColor;
}

- (void)setBufferTrackTintColor:(UIColor *)bufferTrackTintColor {
    _bufferTrackTintColor = bufferTrackTintColor;
    
    self.bufferProgressView.backgroundColor = bufferTrackTintColor;
}

- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage {
    _maximumTrackImage = maximumTrackImage;
    
    self.bgProgressView.image = maximumTrackImage;
    self.maximumTrackTintColor = [UIColor clearColor];
}

- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage {
    _minimumTrackImage = minimumTrackImage;
    
    self.sliderProgressView.image = minimumTrackImage;
    
    self.minimumTrackTintColor = [UIColor clearColor];
}

- (void)setBufferTrackImage:(UIImage *)bufferTrackImage {
    _bufferTrackImage = bufferTrackImage;
    
    self.bufferProgressView.image = bufferTrackImage;
    
    self.bufferTrackTintColor = [UIColor clearColor];
}

- (void)setValue:(float)value {
    _value = value;

    CGFloat finishValue  = self.bgProgressView.frame.size.width * value;
    self.sliderProgressView.width = finishValue;
    
    CGFloat buttonX = (self.width - self.sliderBtn.width) * value;
    self.sliderBtn.left = buttonX;
    
    self.lastPoint = self.sliderBtn.center;
}

- (void)setBufferValue:(float)bufferValue {
    _bufferValue = bufferValue;
    
    CGFloat finishValue = self.bgProgressView.width * bufferValue;

    self.bufferProgressView.width = finishValue;
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setBackgroundImage:image forState:state];
    
    [self.sliderBtn sizeToFit];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setImage:image forState:state];
    
    [self.sliderBtn sizeToFit];
}

- (void)showLoading {
    [self.sliderBtn showActivityAnim];
}

- (void)hideLoading {
    [self.sliderBtn hideActivityAnim];
}

- (void)setAllowTapped:(BOOL)allowTapped {
    _allowTapped = allowTapped;
    
    if (!allowTapped) {
        [self removeGestureRecognizer:self.tapGesture];
    }
}

- (void)setSliderHeight:(CGFloat)sliderHeight {
    _sliderHeight = sliderHeight;
    
    self.bgProgressView.height     = sliderHeight;
    self.bufferProgressView.height = sliderHeight;
    self.sliderProgressView.height = sliderHeight;
}

#pragma mark - User Action
- (void)sliderBtnTouchBegin:(UIButton *)btn {
    
    if ([self.delegate respondsToSelector:@selector(sliderTouchBegin:)]) {
        [self.delegate sliderTouchBegin:self.value];
    }
}

- (void)sliderBtnTouchEnded:(UIButton *)btn {
    
    if ([self.delegate respondsToSelector:@selector(sliderTouchEnded:)]) {
        [self.delegate sliderTouchEnded:self.value];
    }
}

- (void)sliderBtnDragMoving:(UIButton *)btn event:(UIEvent *)event {
    
    // 点击的位置
    CGPoint point = [event.allTouches.anyObject locationInView:self];
    
    // 获取进度值 由于btn是从 0-(self.width - btn.width)
    float value = (point.x - btn.width * 0.5) / (self.width - btn.width);
    value = value >= 1.0 ? 1.0 : value <= 0.0 ? 0.0 : value;
    [self setValue:value];
    
    if ([self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:value];
    }
}

- (void)tapped:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    
    // 获取进度
    float value = (point.x - self.bgProgressView.left) * 1.0 / self.bgProgressView.width;
    value = value >= 1.0 ? 1.0 : value <= 0 ? 0 : value;
    
    [self setValue:value];
    
    if ([self.delegate respondsToSelector:@selector(sliderTapped:)]) {
        [self.delegate sliderTapped:value];
    }
}

#pragma mark - 懒加载
- (UIImageView *)bgProgressView {
    if (!_bgProgressView) {
        _bgProgressView = [UIImageView new];
        _bgProgressView.backgroundColor = [UIColor grayColor];
//        _bgProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _bgProgressView.clipsToBounds = YES;
    }
    return _bgProgressView;
}

- (UIImageView *)bufferProgressView {
    if (!_bufferProgressView) {
        _bufferProgressView = [UIImageView new];
        _bufferProgressView.backgroundColor = [UIColor whiteColor];
//        _bufferProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _bufferProgressView.clipsToBounds = YES;
    }
    return _bufferProgressView;
}

- (UIImageView *)sliderProgressView {
    if (!_sliderProgressView) {
        _sliderProgressView = [UIImageView new];
        _sliderProgressView.backgroundColor = [UIColor redColor];
//        _sliderProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _sliderProgressView.clipsToBounds = YES;
    }
    return _sliderProgressView;
}

- (GKSliderButton *)sliderBtn {
    if (!_sliderBtn) {
        _sliderBtn = [GKSliderButton new];
//        _sliderBtn.backgroundColor = [UIColor whiteColor];
        [_sliderBtn addTarget:self action:@selector(sliderBtnTouchBegin:) forControlEvents:UIControlEventTouchDown];
        [_sliderBtn addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchCancel];
        [_sliderBtn addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
        [_sliderBtn addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
        [_sliderBtn addTarget:self action:@selector(sliderBtnDragMoving:event:) forControlEvents:UIControlEventTouchDragInside];
    }
    return _sliderBtn;
}

@end

@interface GKSliderButton()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation GKSliderButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicatorView.hidesWhenStopped = NO;
        self.indicatorView.userInteractionEnabled = NO;
        self.indicatorView.frame = CGRectMake(0, 0, 20, 20);
        self.indicatorView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        
        [self addSubview:self.indicatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.indicatorView.center = CGPointMake(self.width / 2, self.height/ 2);
    self.indicatorView.transform = CGAffineTransformMakeScale(0.6, 0.6);
}

- (void)showActivityAnim {
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimating];
}

- (void)hideActivityAnim {
    self.indicatorView.hidden = YES;
    [self.indicatorView stopAnimating];
}

// 重写此方法将按钮的点击范围扩大
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    
    // 扩大点击区域
    bounds = CGRectInset(bounds, -20, -20);
    
    // 若点击的点在新的bounds里面。就返回yes
    return CGRectContainsPoint(bounds, point);
}

@end


@implementation UIView (GKFrame)

- (void)setLeft:(CGFloat)left {
    CGRect f = self.frame;
    f.origin.x = left;
    self.frame = f;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setTop:(CGFloat)top {
    CGRect f = self.frame;
    f.origin.y = top;
    self.frame = f;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setRight:(CGFloat)right {
    CGRect f = self.frame;
    f.origin.x = right - f.size.width;
    self.frame = f;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect f = self.frame;
    f.origin.y = bottom - f.size.height;
    self.frame = f;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setWidth:(CGFloat)width {
    CGRect f = self.frame;
    f.size.width = width;
    self.frame = f;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height {
    CGRect f = self.frame;
    f.size.height = height;
    self.frame = f;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setCenterX:(CGFloat)centerX {
    CGPoint c = self.center;
    c.x = centerX;
    self.center = c;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY {
    CGPoint c = self.center;
    c.y = centerY;
    self.center = c;
}

- (CGFloat)centerY {
    return self.center.y;
}

@end

