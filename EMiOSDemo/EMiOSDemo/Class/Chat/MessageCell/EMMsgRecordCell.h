//
//  EMMsgRecordCell.h
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/12/9.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMMsgRecordCellDelegate;
@interface EMMsgRecordCell : UITableViewCell

@property (nonatomic, weak) id<EMMsgRecordCellDelegate> delegate;

@property (nonatomic, strong) NSArray *models;

@end

@protocol EMMsgRecordCellDelegate <NSObject>

@optional

- (void)imageViewDidTouch:(EMMessageModel *)aModel;

- (void)videoViewDidTouch:(EMMessageModel *)aModel;

@end

NS_ASSUME_NONNULL_END
