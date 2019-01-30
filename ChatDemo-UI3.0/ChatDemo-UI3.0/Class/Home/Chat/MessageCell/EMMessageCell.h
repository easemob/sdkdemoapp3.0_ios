//
//  EMMessageCell.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMMessageCellDelegate;

@class EMMessageModel;
@interface EMMessageCell : UITableViewCell

@property (nonatomic, weak) id<EMMessageCellDelegate> delegate;

@property (nonatomic) EMMessageDirection direction;

@property (nonatomic, strong) EMMessageModel *model;

+ (NSString *)cellIdentifierWithDirection:(EMMessageDirection)aDirection
                                     type:(EMMessageBodyType)aType;

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageBodyType)aType;

@end


@protocol EMMessageCellDelegate <NSObject>

@optional
- (void)messageCellDidSelected:(EMMessageCell *)aCell;

@end

NS_ASSUME_NONNULL_END
