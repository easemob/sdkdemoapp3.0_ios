//
//  EMAvatarNameCell.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/9.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMAvatarNameCellDelegate;
@interface EMAvatarNameCell : UITableViewCell

@property (nonatomic, weak) id<EMAvatarNameCellDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UIButton *accessoryButton;

@end

@protocol EMAvatarNameCellDelegate<NSObject>

@optional

- (void)cellAccessoryButtonAction:(EMAvatarNameCell *)aCell;

@end

NS_ASSUME_NONNULL_END
