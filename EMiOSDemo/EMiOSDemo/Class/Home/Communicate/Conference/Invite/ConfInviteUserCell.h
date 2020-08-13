//
//  ConfInviteUserCell.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConfInviteUserCellDelegate;

@interface ConfInviteUserCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic) BOOL isChecked;

@end
