/************************************************************
  *  * Hyphenate CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2016 Hyphenate Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of Hyphenate Inc.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from Hyphenate Inc.
  */

#import <UIKit/UIKit.h>

@protocol ApplyFriendCellDelegate;

@interface ApplyFriendCell : UITableViewCell

@property (nonatomic) id<ApplyFriendCellDelegate> delegate;

@property (strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) UIImageView *headerImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) UIButton *refuseButton;
@property (strong, nonatomic) UIView *bottomLineView;

+ (CGFloat)heightWithContent:(NSString *)content;

@end

@protocol ApplyFriendCellDelegate <NSObject>

- (void)applyCellAddFriendAtIndexPath:(NSIndexPath *)indexPath;
- (void)applyCellRefuseFriendAtIndexPath:(NSIndexPath *)indexPath;

@end
