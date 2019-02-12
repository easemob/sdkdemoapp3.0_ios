//
//  EMGroupInfoViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMRefreshTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroupInfoViewController : EMRefreshTableViewController

@property (nonatomic, copy) void (^leaveOrDestroyCompletion)(void);

- (instancetype)initWithGroupId:(NSString *)aGroupId;

@end

NS_ASSUME_NONNULL_END
