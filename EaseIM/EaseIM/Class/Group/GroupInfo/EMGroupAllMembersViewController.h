//
//  EMGroupAllMembersViewController.h
//  EaseIM
//
//  Created by 娜塔莎 on 2019/12/5.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroupAllMembersViewController : EMRefreshViewController
- (instancetype)initWithGroup:(EMGroup *)aGroup;
@end

NS_ASSUME_NONNULL_END
