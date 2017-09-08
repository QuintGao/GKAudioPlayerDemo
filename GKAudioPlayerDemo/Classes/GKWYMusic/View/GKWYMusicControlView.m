//
//  GKWYMusicControlView.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKWYMusicControlView.h"
#import "GKSliderView.h"

@interface GKWYMusicControlView()<GKSliderViewDelegate>

@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *loopBtn;
@property (nonatomic, strong) UIButton *prevBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *listBtn;

@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic, strong) UILabel *currentLabel;
@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) GKSliderView *slider;

@end

@implementation GKWYMusicControlView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.playBtn];
        [self addSubview:self.loopBtn];
        [self addSubview:self.prevBtn];
        [self addSubview:self.nextBtn];
        [self addSubview:self.listBtn];
        
        [self addSubview:self.sliderView];
        [self.sliderView addSubview:self.currentLabel];
        [self.sliderView addSubview:self.slider];
        [self.sliderView addSubview:self.totalLabel];
        
        [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self).offset(30);
            make.height.mas_equalTo(30);
        }];
        
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.sliderView);
            make.left.equalTo(self.sliderView).offset(60);
            make.right.equalTo(self.sliderView).offset(-60);
        }];
        
        [self.currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.slider.mas_left).offset(-30);
            make.centerY.equalTo(self.sliderView.mas_centerY);
        }];
        
        [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.slider.mas_right).offset(30);
            make.centerY.equalTo(self.sliderView.mas_centerY);
        }];
        
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-20);
            make.centerX.equalTo(self);
        }];
        
        [self.prevBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.playBtn.mas_left).offset(-20);
            make.centerY.equalTo(self.playBtn.mas_centerY);
        }];
        
        [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playBtn.mas_right).offset(20);
            make.centerY.equalTo(self.playBtn.mas_centerY);
        }];
        
        [self.loopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.prevBtn.mas_left).offset(-20);
            make.centerY.equalTo(self.playBtn.mas_centerY);
        }];
        
        [self.listBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nextBtn.mas_right).offset(20);
            make.centerY.equalTo(self.playBtn.mas_centerY);
        }];
    }
    return self;
}

- (void)setStyle:(GKWYPlayerPlayStyle)style {
    switch (style) {
        case GKWYPlayerPlayStyleLoop:
        {
            [self.loopBtn setImage:[UIImage imageNamed:@"cm2_icn_loop"] forState:UIControlStateNormal];
            [self.loopBtn setImage:[UIImage imageNamed:@"cm2_icn_loop_prs"] forState:UIControlStateHighlighted];
        }
            break;
        case GKWYPlayerPlayStyleRandom:
        {
            [self.loopBtn setImage:[UIImage imageNamed:@"cm2_icn_shuffle"] forState:UIControlStateNormal];
            [self.loopBtn setImage:[UIImage imageNamed:@"cm2_icn_shuffle_prs"] forState:UIControlStateHighlighted];
        }
            break;
        case GKWYPlayerPlayStyleOne:
        {
            [self.loopBtn setImage:[UIImage imageNamed:@"cm2_icn_one"] forState:UIControlStateNormal];
            [self.loopBtn setImage:[UIImage imageNamed:@"cm2_icn_one_prs"] forState:UIControlStateHighlighted];
        }
            break;
            
        default:
            break;
    }
}

- (void)setCurrentTime:(NSString *)currentTime {
    _currentTime = currentTime;
    
    self.currentLabel.text = currentTime;
}

- (void)setTotalTime:(NSString *)totalTime {
    _totalTime = totalTime;
    
    self.totalLabel.text = totalTime;
}

- (void)setValue:(float)value {
    _value = value;
    
    self.slider.value = value;
}

- (void)showLoadingAnim {
    [self.slider showLoading];
}

- (void)hideLoadingAnim {
    [self.slider hideLoading];
}

- (void)setupPlayBtn {
    [self.playBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_pause"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_pause_prs"] forState:UIControlStateHighlighted];
}

- (void)setupPauseBtn {
    [self.playBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_play"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_play_prs"] forState:UIControlStateHighlighted];
}

#pragma mark - UserAction
- (void)playBtnClick:(id)sender {
    self.playBtn.selected = !self.playBtn.selected;
    if (self.playBtn.selected) {
        [self setupPlayBtn];
    }else {
        [self setupPauseBtn];
    }
    
    if ([self.delegate respondsToSelector:@selector(controlView:didClickPlay:)]) {
        [self.delegate controlView:self didClickPlay:sender];
    }
}

- (void)loopBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlView:didClickLoop:)]) {
        [self.delegate controlView:self didClickLoop:sender];
    }
}

- (void)prevBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlView:didClickPrev:)]) {
        [self.delegate controlView:self didClickPrev:sender];
    }
}

- (void)nextBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlView:didClickNext:)]) {
        [self.delegate controlView:self didClickNext:sender];
    }
}

- (void)listBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlView:didClickList:)]) {
        [self.delegate controlView:self didClickList:sender];
    }
}

#pragma mark - GKSliderViewDelegate
- (void)sliderTouchBegin:(float)value {
    if ([self.delegate respondsToSelector:@selector(controlView:didSliderTouchBegan:)]) {
        [self.delegate controlView:self didSliderTouchBegan:value];
    }
}

- (void)sliderTouchEnded:(float)value {
    if ([self.delegate respondsToSelector:@selector(controlView:didSliderTouchEnded:)]) {
        [self.delegate controlView:self didSliderTouchEnded:value];
    }
}

- (void)sliderTapped:(float)value {
    if ([self.delegate respondsToSelector:@selector(sliderTapped:)]) {
        [self.delegate controlView:self didSliderTapped:value];
    }
}

- (void)sliderValueChanged:(float)value {
    if ([self.delegate respondsToSelector:@selector(controlView:didSliderValueChange:)]) {
        [self.delegate controlView:self didSliderValueChange:value];
    }
}

#pragma mark - 懒加载
- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton new];
        [_playBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_play_prs"] forState:UIControlStateHighlighted];
        [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)loopBtn {
    if (!_loopBtn) {
        _loopBtn = [UIButton new];
        [_loopBtn setImage:[UIImage imageNamed:@"cm2_icn_loop"] forState:UIControlStateNormal];
        [_loopBtn setImage:[UIImage imageNamed:@"cm2_icn_loop_prs"] forState:UIControlStateHighlighted];
        [_loopBtn addTarget:self action:@selector(loopBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loopBtn;
}

- (UIButton *)prevBtn {
    if (!_prevBtn) {
        _prevBtn = [UIButton new];
        [_prevBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_previous"] forState:UIControlStateNormal];
        [_prevBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_previous_prs"] forState:UIControlStateHighlighted];
        [_prevBtn addTarget:self action:@selector(prevBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _prevBtn;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton new];
        [_nextBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_next"] forState:UIControlStateNormal];
        [_nextBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_next_prs"] forState:UIControlStateHighlighted];
        [_nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (UIButton *)listBtn {
    if (!_listBtn) {
        _listBtn = [UIButton new];
        [_listBtn setImage:[UIImage imageNamed:@"cm2_icn_list"] forState:UIControlStateNormal];
        [_listBtn setImage:[UIImage imageNamed:@"cm2_icn_list_prs"] forState:UIControlStateHighlighted];
        [_listBtn addTarget:self action:@selector(listBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _listBtn;
}

- (UIView *)sliderView {
    if (!_sliderView) {
        _sliderView = [UIView new];
        _sliderView.backgroundColor = [UIColor clearColor];
    }
    return _sliderView;
}

- (UILabel *)currentLabel {
    if (!_currentLabel) {
        _currentLabel = [UILabel new];
        _currentLabel.textColor = [UIColor whiteColor];
        _currentLabel.font = [UIFont systemFontOfSize:16.0];
    }
    return _currentLabel;
}

- (UILabel *)totalLabel {
    if (!_totalLabel) {
        _totalLabel = [UILabel new];
        _totalLabel.textColor = [UIColor whiteColor];
        _totalLabel.font = [UIFont systemFontOfSize:16.0];
    }
    return _totalLabel;
}

- (GKSliderView *)slider {
    if (!_slider) {
        _slider = [GKSliderView new];
        [_slider setBackgroundImage:[UIImage imageNamed:@"cm2_fm_playbar_btn"] forState:UIControlStateNormal];
        [_slider setBackgroundImage:[UIImage imageNamed:@"cm2_fm_playbar_btn"] forState:UIControlStateSelected];
        [_slider setBackgroundImage:[UIImage imageNamed:@"cm2_fm_playbar_btn"] forState:UIControlStateHighlighted];
        
        [_slider setThumbImage:[UIImage imageNamed:@"cm2_fm_playbar_btn_dot"] forState:UIControlStateNormal];
        [_slider setThumbImage:[UIImage imageNamed:@"cm2_fm_playbar_btn_dot"] forState:UIControlStateSelected];
        [_slider setThumbImage:[UIImage imageNamed:@"cm2_fm_playbar_btn_dot"] forState:UIControlStateHighlighted];
        _slider.maximumTrackImage = [UIImage imageNamed:@"cm2_fm_playbar_bg"];
        _slider.minimumTrackImage = [UIImage imageNamed:@"cm2_fm_playbar_curr"];
        _slider.bufferTrackImage  = [UIImage imageNamed:@"cm2_fm_playbar_ready"];
        _slider.delegate = self;
    }
    return _slider;
}

@end
