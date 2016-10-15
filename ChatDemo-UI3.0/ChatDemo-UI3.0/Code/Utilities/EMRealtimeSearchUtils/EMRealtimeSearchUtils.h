//
//  EMRealtimeSearchUtils.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/10.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^EMRealtimeSearchResultsBlock)(NSArray *results);

@interface EMRealtimeSearchUtils : NSObject

+ (instancetype)defaultUtil;

- (void)realtimeSearchWithSource:(id)source
                    searchString:(NSString *)searchString
                     resultBlock:(EMRealtimeSearchResultsBlock)block;

- (void)realtimeSearchDidFinish;

@end
