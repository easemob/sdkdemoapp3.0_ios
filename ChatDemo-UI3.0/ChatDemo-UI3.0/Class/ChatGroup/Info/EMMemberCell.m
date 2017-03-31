//
//  EMMemberCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 09/03/2017.
//  Copyright © 2017 XieYajie. All rights reserved.
//

#import "EMMemberCell.h"

@implementation EMMemberCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    
    if (self.showAccessoryViewInDelete) {
        if (state == UITableViewCellStateShowingDeleteConfirmationMask) {
            self.accessoryView = self.accessoryDeleteView;
        } else if (state == UITableViewCellStateDefaultMask) {
            self.accessoryView = self.accessoryDefaultView;
        }
    }
}

#pragma mark - setter

- (void)setShowAccessoryViewInDelete:(BOOL)showAccessoryViewInDelete
{
    if (_showAccessoryViewInDelete != showAccessoryViewInDelete) {
        _showAccessoryViewInDelete = showAccessoryViewInDelete;
        if (showAccessoryViewInDelete) {
            self.accessoryDefaultView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shape_left"]];
            self.accessoryDeleteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shape_right"]];
            self.accessoryView = self.accessoryDefaultView;
        } else {
            self.accessoryDefaultView = nil;
            self.accessoryDeleteView = nil;
            self.accessoryView = nil;
        }
    }
}

@end
