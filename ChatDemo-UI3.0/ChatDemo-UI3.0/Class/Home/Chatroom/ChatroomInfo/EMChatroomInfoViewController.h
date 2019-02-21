//
//  EMChatroomInfoViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/11.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMRefreshTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatroomInfoViewController : EMRefreshTableViewController

@property (nonatomic, copy) void (^leaveCompletion)(void);

- (instancetype)initWithChatroomId:(NSString *)aChatroomId;

@end

NS_ASSUME_NONNULL_END
