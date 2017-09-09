//
//  GKAudioViewCell.m
//  GKMobileVLCKitDemo
//
//  Created by QuintGao on 2017/8/23.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKWYMusicListViewCell.h"
#import "GKWYPlayerViewController.h"

@interface GKWYMusicListViewCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeight;

@property (weak, nonatomic) IBOutlet UIButton *playingBtn;

@property (weak, nonatomic) IBOutlet UIButton *loveBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playingCon;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noPlayCon;

@end

@implementation GKWYMusicListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lineHeight.constant = 0.5;
    
    self.playingBtn.hidden = YES;
    self.playingBtn.userInteractionEnabled = NO;
}

- (void)setModel:(GKWYMusicModel *)model {
    _model = model;
    
    self.nameLabel.text   = model.music_name;
    [self.nameLabel sizeToFit];
    
    self.artistLabel.text = [NSString stringWithFormat:@"- %@", model.music_artist];
    
    self.loveBtn.selected = model.isLike;
    
    if (model.isPlaying && kWYPlayerVC.isPlaying) {
        self.noPlayCon.active  = NO;
        self.playingCon.active = YES;
        
        self.playingBtn.hidden = NO;
        
        self.nameLabel.textColor   = GKColorRGB(200, 38, 39);
        self.artistLabel.textColor = GKColorRGB(200, 38, 39);
        
        NSMutableArray *images = [NSMutableArray new];
        
        for (NSInteger i = 0; i < 4; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"cm2_list_icn_loading%zd", i + 1]];
            [images addObject:image];
        }
        
        for (NSInteger i = 4; i > 0; i--) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_list_icn_loading%zd", i];
            [images addObject:[UIImage imageNamed:imageName]];
        }
        
        self.playingBtn.imageView.animationImages = images;
        self.playingBtn.imageView.animationDuration = 0.85;
        [self.playingBtn.imageView startAnimating];
    }else {
        self.playingCon.active = NO;
        self.noPlayCon.active  = YES;
        
        self.playingBtn.hidden = YES;
        [self.playingBtn.imageView stopAnimating];
        
        self.nameLabel.textColor   = [UIColor blackColor];
        self.artistLabel.textColor = [UIColor lightGrayColor];
    }
}


- (IBAction)deleteBtnClick:(id)sender {
    
    !self.likeClicked ? : self.likeClicked(self.model);
}

@end
