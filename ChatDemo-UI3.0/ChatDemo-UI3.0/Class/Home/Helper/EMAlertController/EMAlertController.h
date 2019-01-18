//
//  EMAlertController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/24.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EMAlertViewStyle) {
    EMAlertViewStyleDefault,
    EMAlertViewStyleError,
    EMAlertViewStyleInfo,
    EMAlertViewStyleSuccess,
};

@interface EMAlertController : UIView

+ (void)showErrorAlert:(NSString *)aStr;

+ (void)showSuccessAlert:(NSString *)aMessage;

+ (void)showInfoAlert:(NSString *)aMessage;

@end

NS_ASSUME_NONNULL_END
