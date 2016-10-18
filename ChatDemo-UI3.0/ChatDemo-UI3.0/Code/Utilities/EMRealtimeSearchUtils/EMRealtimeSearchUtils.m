//
//  EMRealtimeSearchUtils.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/10.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMRealtimeSearchUtils.h"
#import "IEMRealtimeSearch.h"


static EMRealtimeSearchUtils *defaultUtils = nil;

@interface EMRealtimeSearchUtils()

@property (nonatomic, weak) id source;

@property (nonatomic, strong) NSString *searchString;

@property (nonatomic, copy) EMRealtimeSearchResultsBlock resultBlock;

@property (nonatomic, strong) NSThread *searchThread;

@end


@implementation EMRealtimeSearchUtils

+ (instancetype)defaultUtil {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(){
        defaultUtils = [[EMRealtimeSearchUtils alloc] init];
    });
    return defaultUtils;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
#pragma mark - private

- (void)realtimeSearchDidStart {
    if (_searchThread) {
        [_searchThread cancel];
    }
    _searchThread = [[NSThread alloc] initWithTarget:self selector:@selector(realtimeSearchBegin) object:nil];
    [_searchThread start];
}

- (void)realtimeSearchBegin {
    
    NSMutableArray *results = [NSMutableArray array];
    for (id obj in _source) {
        NSString * searchKey = @"";
        if ([obj conformsToProtocol:@protocol(IEMRealtimeSearch)]) {
            id<IEMRealtimeSearch> searchModel = (id<IEMRealtimeSearch>)obj;
            searchKey = [searchModel.searchKey lowercaseString];
        }
        else if ([obj isKindOfClass:[NSString class]]) {
            searchKey = [(NSString *)obj lowercaseString];
        }
        else {
            continue;
        }
        if (_searchString.length == 0) {
            break;
        }
        if ([searchKey rangeOfString:_searchString].length > 0) {
            [results addObject:obj];
        }
    }
    if (_resultBlock) {
        _resultBlock(results);
    }
}

#pragma mark - public

- (void)realtimeSearchWithSource:(id)source
                    searchString:(NSString *)searchString
                     resultBlock:(EMRealtimeSearchResultsBlock)block
{
    _resultBlock = block;
    if (!source || searchString.length == 0) {
        if (_resultBlock) {
            _resultBlock(source);
        }
        return;
    }
    _source = source;
    _searchString = [searchString lowercaseString];
    [self realtimeSearchDidStart];
}

- (void)realtimeSearchDidFinish {
    [_searchThread cancel];
    _source = nil;
    _searchString = nil;
}

@end
