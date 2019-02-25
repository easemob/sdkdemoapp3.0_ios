//
//  EMInviteGroupMemberViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/17.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMSearchViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMInviteGroupMemberViewController : EMSearchViewController

@property (nonatomic, copy) void (^doneCompletion)(NSArray *aSelectedArray);

- (instancetype)initWithBlocks:(NSArray *)aBlocks;

@end

NS_ASSUME_NONNULL_END
