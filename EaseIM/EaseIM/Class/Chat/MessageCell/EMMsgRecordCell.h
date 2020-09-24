//
//  EMMsgRecordCell.h
//  EaseIM
//
//  Created by 娜塔莎 on 2019/12/9.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 聊天记录
*/
@protocol EMMsgRecordCellDelegate;
@interface EMMsgRecordCell : UITableViewCell

@property (nonatomic, weak) id<EMMsgRecordCellDelegate> delegate;

@property (nonatomic, strong) NSArray<EMMessageModel *> *models;

@end

@protocol EMMsgRecordCellDelegate <NSObject>

@optional

- (void)imageViewDidTouch:(EMMessageModel *)aModel;

- (void)videoViewDidTouch:(EMMessageModel *)aModel;

@end

NS_ASSUME_NONNULL_END
