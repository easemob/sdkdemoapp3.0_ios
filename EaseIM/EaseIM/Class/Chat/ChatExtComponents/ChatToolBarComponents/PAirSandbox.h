//
//  PAirSandbox.h
//  AirSandboxDemo
//
//  Created by gao feng on 2017/7/18.
//  Copyright © 2017年 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAirSandbox : NSObject

+ (instancetype)sharedInstance;

- (void)showSandboxBrowser;

@property (nonatomic, copy) void (^sendCompletion)(NSURL *url);

@end
