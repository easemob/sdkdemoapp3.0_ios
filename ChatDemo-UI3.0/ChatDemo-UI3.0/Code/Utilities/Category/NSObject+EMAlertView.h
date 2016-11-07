//
//  NSObject+EMAlertView.h
//  ChatDemo-UI3.0
//
//  Created by WYZ on 2016/11/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (EMAlertView)

- (void)showAlertWithMessage:(NSString *)msg;

- (void)showAlertWithMessage:(NSString *)msg delegate:(id)delegate;

@end
