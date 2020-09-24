//
//  EMFeedBackType.h
//  EMIMDEMO
//
//  Created by 娜塔莎 on 2020/2/19.
//  Copyright © 2020 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMFeedBackType : UIView

@property (nonatomic, copy) void (^doneCompletion)(NSString *aConfirm);

@end

NS_ASSUME_NONNULL_END
