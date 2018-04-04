//
//  EMConfAddUserCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "EMConfAddUserCell.h"

@implementation EMConfAddUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    [self.checkButton setImage:[UIImage imageNamed:@"conf_checked"] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - action

- (IBAction)checkAction:(id)sender
{
//    self.checkButton.selected = !self.checkButton.selected;
//    
//    if (_delegate && [_delegate respondsToSelector:@selector(cell:checkUserAction:)]) {
//        [_delegate cell:self checkUserAction:self.nameLabel.text];
//    }
}

@end
