//
//  EMMsgTranspondViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/20.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMRefreshTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class EMMessageModel;
@interface EMMsgTranspondViewController : EMRefreshTableViewController

@property (nonatomic, copy) void (^doneCompletion)(EMMessageModel *aModel, NSString *aUsername);

- (instancetype)initWithModel:(EMMessageModel *)aModel;

@end

NS_ASSUME_NONNULL_END
