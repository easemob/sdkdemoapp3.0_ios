//
//  EMConferenceInviteViewController.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/6/8.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EM1v1CallViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMConferenceInviteViewController : EM1v1CallViewController
- (instancetype)initWithMessage:(EMMessage *)msg;
@end

NS_ASSUME_NONNULL_END
