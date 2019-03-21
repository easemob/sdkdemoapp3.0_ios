//
//  EMCreateGroupViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EMInviteGroupMemberViewController;
@interface EMCreateGroupViewController : UITableViewController

@property (nonatomic, copy) void (^successCompletion)(EMGroup *aGroup);

@property (nonatomic, strong) EMInviteGroupMemberViewController *inviteController;

- (instancetype)initWithSelectedMembers:(NSArray *)aMembers;

@end

NS_ASSUME_NONNULL_END
