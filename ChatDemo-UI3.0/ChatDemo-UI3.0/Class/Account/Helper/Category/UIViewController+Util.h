//
//  UIViewController+Util.h
//  dxstudio
//
//  Created by XieYajie on 25/08/2017.
//  Copyright © 2017 dxstudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Util)

- (void)addPopBackLeftItem;

- (void)addKeyboardNotificationsWithShowSelector:(SEL _Nullable )aShowSelector
                                    hideSelector:(SEL _Nullable )aHideSelector;

- (void)removeKeyboardNotifications;

//+ (BOOL)isUseChinese;

@end
