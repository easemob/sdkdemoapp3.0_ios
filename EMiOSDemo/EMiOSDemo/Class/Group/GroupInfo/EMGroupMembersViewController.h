//
//  EMGroupMembersViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/19.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMRefreshTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroupMembersViewController : EMRefreshTableViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup;

@end

NS_ASSUME_NONNULL_END
