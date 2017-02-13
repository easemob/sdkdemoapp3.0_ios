/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "AppDelegate+UMeng.h"
#import <UMMobClick/MobClick.h>

@implementation AppDelegate (UMeng)

-(void)setupUMeng{
    //友盟
    NSString *bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if ([bundleID isEqualToString:@"com.easemob.enterprise.demo.ui"]) {
        UMAnalyticsConfig *config = [UMAnalyticsConfig sharedInstance];
        config.appKey = @"5389bb7f56240ba94208ac97";
        config.ePolicy = BATCH;
        [MobClick startWithConfigure:config];
#if DEBUG
        [MobClick setLogEnabled:YES];
#else
        [MobClick setLogEnabled:NO];
#endif
    }
}

@end
