//
//  EMLocationViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/29.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMLocationViewController : UIViewController

@property (nonatomic, copy) void (^sendCompletion)(CLLocationCoordinate2D aCoordinate, NSString *aAddress);

- (instancetype)initWithLocation:(CLLocationCoordinate2D)aLocationCoordinate;

@end

NS_ASSUME_NONNULL_END
