//
//  EMMessageReadManager.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMMessageReadManager : NSObject

+ (instancetype)shareInstance;

- (void)showBrowserWithImages:(NSArray *)imageArray;

@end
