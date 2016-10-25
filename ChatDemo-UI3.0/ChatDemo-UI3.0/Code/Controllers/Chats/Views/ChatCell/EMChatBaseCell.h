//
//  EMChatBaseCell.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/27.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMChatBaseCell;
@class EMMessageModel;
@protocol EMChatBaseCellDelegate <NSObject>

@optional

- (void)didHeadImagePressed:(EMMessageModel*)model;

- (void)didTextCellPressed:(EMMessageModel*)model;

- (void)didImageCellPressed:(EMMessageModel*)model;

- (void)didAudioCellPressed:(EMMessageModel*)model;

- (void)didVideoCellPressed:(EMMessageModel*)model;

- (void)didLocationCellPressed:(EMMessageModel*)model;

- (void)didCellLongPressed:(EMChatBaseCell*)cell;

- (void)didResendButtonPressed:(EMMessageModel*)model;

@end

@interface EMChatBaseCell : UITableViewCell

@property (weak, nonatomic) id<EMChatBaseCellDelegate> delegate;

- (instancetype)initWithMessageModel:(EMMessageModel*)model;

- (void)setMessageModel:(EMMessageModel*)model;

+ (CGFloat)heightForMessageModel:(EMMessageModel*)model;

+ (NSString *)cellIdentifierForMessageModel:(EMMessageModel *)model;

@end
