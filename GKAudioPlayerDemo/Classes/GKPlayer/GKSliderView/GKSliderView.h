//
//  GKSliderView.h
//  GKSliderView
//
//  Created by QuintGao on 2017/9/6.
//  Copyright © 2017年 高坤. All rights reserved.
//  自定义的一个slider

#import <UIKit/UIKit.h>

@protocol GKSliderViewDelegate <NSObject>

@optional

- (void)sliderTouchBegin:(float)value;
- (void)sliderValueChanged:(float)value;
- (void)sliderTouchEnded:(float)value;
- (void)sliderTapped:(float)value;

@end

@interface GKSliderView : UIView

@property (nonatomic, weak) id<GKSliderViewDelegate> delegate;

/** 默认滑杆的颜色 */
@property (nonatomic, strong) UIColor *maximumTrackTintColor;
/** 滑杆进度颜色 */
@property (nonatomic, strong) UIColor *minimumTrackTintColor;
/** 缓存进度颜色 */
@property (nonatomic, strong) UIColor *bufferTrackTintColor;

/** 默认滑杆的图片 */
@property (nonatomic, strong) UIImage *maximumTrackImage;
/** 滑杆进度的图片 */
@property (nonatomic, strong) UIImage *minimumTrackImage;
/** 缓存进度的图片 */
@property (nonatomic, strong) UIImage *bufferTrackImage;

/** 滑杆进度 */
@property (nonatomic, assign) float value;
/** 缓存进度 */
@property (nonatomic, assign) float bufferValue;

/** 是否允许点击，默认是yes */
@property (nonatomic, assign) BOOL allowTapped;

@property (nonatomic, assign) CGFloat sliderHeight;

// 设置滑块的属性
// 滑块背景
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
// 滑块图片
- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state;

- (void)showLoading;
- (void)hideLoading;

@end

@interface GKSliderButton : UIButton

- (void)showActivityAnim;
- (void)hideActivityAnim;

@end

@interface UIView (GKFrame)

@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@end
