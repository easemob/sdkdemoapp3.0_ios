//
//  EMMemberCell.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 09/03/2017.
//  Copyright © 2017 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMMemberCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UILabel *leftLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightLabel;

@property (nonatomic) BOOL showAccessoryViewInDelete;
@property (nonatomic, strong) UIView *accessoryDefaultView;
@property (nonatomic, strong) UIView *accessoryDeleteView;

@end
