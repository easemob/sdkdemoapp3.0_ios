//
//  EMRealtimeSearchUtil.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/22.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RealtimeSearchResultsBlock)(NSArray *results);

@interface EMRealtimeSearchUtil : NSObject

@property (nonatomic) BOOL asWholeSearch;

+ (instancetype)currentUtil;

- (void)realtimeSearchWithSource:(id)source
                      searchText:(NSString *)searchText
         collationStringSelector:(SEL)selector
                     resultBlock:(RealtimeSearchResultsBlock)resultBlock;

- (BOOL)realtimeSearchString:(NSString *)searchString
                  fromString:(NSString *)fromString;

- (void)realtimeSearchStop;

@end
