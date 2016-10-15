//
//  EMChatBaseCell.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/27.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMChatBaseCell;
@protocol EMChatBaseCellDelegate <NSObject>

@optional

- (void)didHeadImagePressed:(EMMessage*)message;

- (void)didTextCellPressed:(EMMessage*)message;

- (void)didImageCellPressed:(EMMessage*)message;

- (void)didAudioCellPressed:(EMMessage*)message;

- (void)didVideoCellPressed:(EMMessage*)message;

- (void)didLocationCellPressed:(EMMessage*)message;

- (void)didCellLongPressed:(EMChatBaseCell*)cell;

- (void)didResendButtonPressed:(EMMessage*)message;

@end

@interface EMChatBaseCell : UITableViewCell

@property (weak, nonatomic) id<EMChatBaseCellDelegate> delegate;

- (instancetype)initWithMessage:(EMMessage*)message;

- (void)setMessage:(EMMessage*)message;

+ (CGFloat)heightForMessage:(EMMessage*)message;

+ (NSString *)cellIdentifierForMessage:(EMMessage *)message;

@end
