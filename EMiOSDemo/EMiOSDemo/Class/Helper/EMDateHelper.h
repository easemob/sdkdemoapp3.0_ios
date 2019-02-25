//
//  EMDateHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/12.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

#define D_MINUTE    60
#define D_HOUR      3600
#define D_DAY       86400
#define D_WEEK      604800
#define D_YEAR      31556926

NS_ASSUME_NONNULL_BEGIN

@interface EMDateHelper : NSObject

+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)aMilliSecond;

+ (NSString *)formattedTimeFromTimeInterval:(long long)aTimeInterval;

+ (NSString *)formattedTime:(NSDate *)aDate;

@end

NS_ASSUME_NONNULL_END
