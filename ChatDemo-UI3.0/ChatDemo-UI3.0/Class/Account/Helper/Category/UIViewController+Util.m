//
//  UIViewController+Util.m
//  dxstudio
//
//  Created by XieYajie on 25/08/2017.
//  Copyright © 2017 dxstudio. All rights reserved.
//

#import "UIViewController+Util.h"

@implementation UIViewController (Util)

- (void)addPopBackLeftItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back_gary"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(popBackLeftItemAction)];
}

- (void)addKeyboardNotificationsWithShowSelector:(SEL)aShowSelector
                                    hideSelector:(SEL)aHideSelector
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:aShowSelector name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:aHideSelector name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)popBackLeftItemAction
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
