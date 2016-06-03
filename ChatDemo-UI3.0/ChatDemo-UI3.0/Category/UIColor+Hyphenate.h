//
//  UIColor+Hyphenate.h
//  ChatDemo-UI3.0
//
//  Created by Jerry Wu on 6/3/16.
//  Copyright © 2016 Jerry Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hyphenate)

+ (UIColor *)HIColorGreenMajor;
+ (UIColor *)HIColorGreenDark;
+ (UIColor *)HIColorGreenLight;
+ (UIColor *)HIColorRed;

+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end
