//
//  ConfInviteUserCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "ConfInviteUserCell.h"

@interface ConfInviteUserCell()

@property (nonatomic, weak) IBOutlet UIImageView *checkView;

@end

@implementation ConfInviteUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.checkView.contentMode = UIViewContentModeScaleAspectFit;
    self.checkView.image = [UIImage imageNamed:@"unCheck"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsChecked:(BOOL)isChecked
{
    if (_isChecked != isChecked) {
        _isChecked = isChecked;
        if (isChecked) {
            self.checkView.image = [UIImage imageNamed:@"check"];
        } else {
            self.checkView.image = [UIImage imageNamed:@"unCheck"];
        }
    }
}

@end
