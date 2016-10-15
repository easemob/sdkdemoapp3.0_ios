//
//  EMRealtimeSearchUtil.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/22.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMRealtimeSearchUtil.h"

static EMRealtimeSearchUtil *defaultUtil = nil;

@interface EMRealtimeSearchUtil()

@property (weak, nonatomic) id source;

@property (nonatomic) SEL selector;

@property (copy, nonatomic) RealtimeSearchResultsBlock resultBlock;

@property (strong, nonatomic) NSThread *searchThread;

@property (strong, nonatomic) dispatch_queue_t searchQueue;

@end

@implementation EMRealtimeSearchUtil

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
        defaultUtil = [[EMRealtimeSearchUtil alloc] init];
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
