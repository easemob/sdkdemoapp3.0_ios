//
//  EMFriendProfileViewController.h
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/12/10.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMPersonalDataViewController : EMRefreshViewController

- (instancetype)initWithNickName:(NSString *)aNickName;

@end

NS_ASSUME_NONNULL_END
