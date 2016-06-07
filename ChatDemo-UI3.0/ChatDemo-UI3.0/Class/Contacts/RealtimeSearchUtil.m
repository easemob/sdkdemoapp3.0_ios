/************************************************************
  *  * Hyphenate CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2016 Hyphenate Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of Hyphenate Inc.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from Hyphenate Inc.
  */

#import "RealtimeSearchUtil.h"

static RealtimeSearchUtil *defaultUtil = nil;

@interface RealtimeSearchUtil()

@property (weak, nonatomic) id source;

@property (nonatomic) SEL selector;

@property (copy, nonatomic) RealtimeSearchResultsBlock resultBlock;
@property (strong, nonatomic) NSThread *searchThread;
@property (strong, nonatomic) dispatch_queue_t searchQueue;

@end

@implementation RealtimeSearchUtil

@synthesize source = _source;
@synthesize selector = _selector;
@synthesize resultBlock = _resultBlock;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _asWholeSearch = YES;
        _searchQueue = dispatch_queue_create("cn.realtimeSearch.queue", NULL);
    }
    
    return self;
}

+ (instancetype)currentUtil
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultUtil = [[RealtimeSearchUtil alloc] init];
    });
    
    return defaultUtil;
}

#pragma mark - private

- (void)realtimeSearch:(NSString *)string
{
    [self.searchThread cancel];
    
    self.searchThread = [[NSThread alloc] initWithTarget:self selector:@selector(searchBegin:) object:string];
    [self.searchThread start];
}

- (void)searchBegin:(NSString *)string
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.searchQueue, ^{
        if (string.length == 0) {
            weakSelf.resultBlock(weakSelf.source);
        }
        else{
            NSMutableArray *results = [NSMutableArray array];
            NSString *subStr = [string lowercaseString];
            for (id object in weakSelf.source) {
                NSString *tmpString = @"";
                if (weakSelf.selector) {
                    if([object respondsToSelector:weakSelf.selector])
                    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        tmpString = [[object performSelector:weakSelf.selector] lowercaseString];
#pragma clang diagnostic pop
                        
                    }
                }
                else if ([object isKindOfClass:[NSString class]])
                {
                    tmpString = [object lowercaseString];
                }
                else{
                    continue;
                }
                
                if([tmpString rangeOfString:subStr].location != NSNotFound)
                {
                    [results addObject:object];
                }
            }
            
            weakSelf.resultBlock(results);
        }
    });
}

#pragma mark - public

- (void)realtimeSearchWithSource:(id)source searchText:(NSString *)searchText collationStringSelector:(SEL)selector resultBlock:(RealtimeSearchResultsBlock)resultBlock
{
    if (!source || !searchText || !resultBlock) {
        if (resultBlock) {
            _resultBlock(source);
        }
        return;
    }
    
    _source = source;
    _selector = selector;
    _resultBlock = resultBlock;
    [self realtimeSearch:searchText];
}

- (BOOL)realtimeSearchString:(NSString *)searchString fromString:(NSString *)fromString
{
    if (!searchString || !fromString || (fromString.length == 0 && searchString.length != 0)) {
        return NO;
    }
    if (searchString.length == 0) {
        return YES;
    }
    
    NSUInteger location = [[fromString lowercaseString] rangeOfString:[searchString lowercaseString]].location;
    return (location == NSNotFound ? NO : YES);
}

- (void)realtimeSearchStop
{
    [self.searchThread cancel];
}

@end
