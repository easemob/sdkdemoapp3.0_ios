//
//  DemoCallManager.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DemoCallManager : NSObject

+ (instancetype)sharedManager;

- (void)answerCall:(NSString *)aCallId;

- (void)endCallWithId:(NSString *)aCallId
               reason:(EMCallEndReason)aReason;

- (void)saveCallOptions;

@end
