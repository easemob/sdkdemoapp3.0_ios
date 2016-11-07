//
//  NSObject+EMAlertView.m
//  ChatDemo-UI3.0
//
//  Created by WYZ on 2016/11/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "NSObject+EMAlertView.h"

@implementation NSObject (EMAlertView)

- (void)showAlertWithMessage:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"common.ok", @"OK")
                                              otherButtonTitles:nil, nil];
    [alertView show];
}


- (void)showAlertWithMessage:(NSString *)msg delegate:(id)delegate {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:msg
                                                       delegate:delegate
                                              cancelButtonTitle:NSLocalizedString(@"common.ok", @"OK")
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

@end
