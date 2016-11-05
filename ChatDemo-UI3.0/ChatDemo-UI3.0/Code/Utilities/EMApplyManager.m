//
//  EMApplyManager.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMApplyManager.h"
#import "EMApplyModel.h"
static EMApplyManager *manager = nil;

@interface EMApplyManager(){
    NSUserDefaults *_userDefaults;
    NSMutableArray *_contactApplys;
    NSMutableArray *_groupApplys;
}


@end

@implementation EMApplyManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[EMApplyManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _contactApplys = [NSMutableArray array];
        _groupApplys = [NSMutableArray array];
        [self loadAllApplys];
    }
    return self;
}

- (NSString *)localContactApplysKey {
    NSString *loginHyphenateId = [EMClient sharedClient].currentUsername;
    if (loginHyphenateId.length == 0) {
        return nil;
    }
    NSString *key = [loginHyphenateId stringByAppendingString:@"_contactApplys"];
    return key;
}

- (NSString *)localGroupApplysKey {
    NSString *loginHyphenateId = [EMClient sharedClient].currentUsername;
    if (loginHyphenateId.length == 0) {
        return nil;
    }
    NSString *key = [loginHyphenateId stringByAppendingString:@"_groupApplys"];
    return key;
}


- (void)loadAllApplys {
    NSString *contactKey = [manager localContactApplysKey];
    if (contactKey.length > 0) {
        NSData *contactData = [_userDefaults objectForKey:contactKey];
        if (contactData.length > 0) {
            _contactApplys = [NSKeyedUnarchiver unarchiveObjectWithData:contactData];
        }
    }
    
    NSString *groupKey = [manager localGroupApplysKey];
    if (groupKey.length > 0) {
        NSData *groupData = [_userDefaults objectForKey:groupKey];
        if (groupData.length > 0) {
            _groupApplys = [NSKeyedUnarchiver unarchiveObjectWithData:groupData];
        }
    }
}


#pragma mark - public

- (NSUInteger)unHandleApplysCount {
    return _contactApplys.count + _groupApplys.count;
}

- (NSArray *)contactApplys {
    [_contactApplys removeAllObjects];
    NSString *contactKey = [manager localContactApplysKey];
    if (contactKey.length > 0) {
        NSData *contactData = [_userDefaults objectForKey:contactKey];
        if (contactData.length > 0) {
            _contactApplys = [NSKeyedUnarchiver unarchiveObjectWithData:contactData];
        }
    }
    return _contactApplys;
}

- (NSArray *)groupApplys {
    [_groupApplys removeAllObjects];
    NSString *groupKey = [manager localGroupApplysKey];
    if (groupKey.length > 0) {
        NSData *groupData = [_userDefaults objectForKey:groupKey];
        if (groupData.length > 0) {
            _groupApplys = [NSKeyedUnarchiver unarchiveObjectWithData:groupData];
        }
    }
    return _groupApplys;
}


- (BOOL)isExistingRequest:(NSString *)applyHyphenateId
               applyStyle:(EMApplyStyle)applyStyle {
    NSArray *sources = nil;
    __block BOOL isExistingRequest = NO;
    if (applyStyle == EMApplyStyle_contact && _contactApplys.count > 0) {
        sources = _contactApplys;
    }
    else if (applyStyle != EMApplyStyle_contact && _groupApplys.count > 0) {
        sources = _groupApplys;
    }
    if (sources.count > 0) {
        [sources enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj conformsToProtocol:@protocol(IEMApplyModel)]) {
                id<IEMApplyModel> model = (id<IEMApplyModel>)obj;
                if ([model.applyHyphenateId isEqualToString:applyHyphenateId] && model.style == applyStyle) {
                    isExistingRequest = YES;
                    *stop = YES;
                }
            }
        }];
    }
    return isExistingRequest;
}

- (void)addApplyRequest:(EMApplyModel *)model {
    NSString *key = @"";
    NSArray *array = [NSArray array];
    if (model.style == EMApplyStyle_contact) {
        key = [manager localContactApplysKey];
        [_contactApplys addObject:model];
        array = _contactApplys;
    }
    else {
        key = [manager localGroupApplysKey];
        [_groupApplys addObject:model];
        array = _groupApplys;
    }
    if (key.length == 0) {
        return;
    }
    @synchronized (self) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        [_userDefaults setObject:data forKey:key];
        [_userDefaults synchronize];
    }
}

- (void)removeApplyRequest:(EMApplyModel *)model {
    
    NSString *key = @"";
    NSMutableArray *array = [NSMutableArray array];
    if (model.style == EMApplyStyle_contact) {
        key = [manager localContactApplysKey];
        array = _contactApplys;
    }
    else {
        key = [manager localGroupApplysKey];
        array = _groupApplys;
    }
    if (key.length == 0) {
        return;
    }
    @synchronized (self) {
        __block NSInteger index = -1;
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj conformsToProtocol:@protocol(IEMApplyModel)]) {
                id<IEMApplyModel> applyModel = (id<IEMApplyModel>)obj;
                if ([applyModel.recordId isEqualToString:model.recordId]) {
                    index = idx;
                    *stop = YES;
                }
            }
        }];
        if (index >= 0) {
            [array removeObjectAtIndex:index];
        }
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        [_userDefaults setObject:data forKey:key];
        [_userDefaults synchronize];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [manager loadAllApplys];
        });
    }
}

@end
