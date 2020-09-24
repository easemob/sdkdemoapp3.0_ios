//
//  EMGroupManageViewController.h
//  EaseIM
//
//  Created by 娜塔莎 on 2019/12/4.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroupManageViewController : EMRefreshViewController

- (instancetype)initWithGroup:(NSString *)aGroupId;

@end

NS_ASSUME_NONNULL_END
