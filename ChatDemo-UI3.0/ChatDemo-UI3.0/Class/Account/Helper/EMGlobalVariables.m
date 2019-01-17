//
//  EMGlobalVariables.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMGlobalVariables.h"

MainViewController *gMainController = nil;
BOOL gIsInitializedSDK = NO;

EMHomeViewController *gHomeController = nil;

BOOL gIsCalling = NO;

static EMGlobalVariables *shared = nil;
@implementation EMGlobalVariables

+ (instancetype)shareGlobal
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[EMGlobalVariables alloc] init];
    });
    
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

+ (void)setGlobalMainController:(nullable MainViewController *)aMainController
{
    gMainController = aMainController;
}

@end
