//
//  EMAudioPlayerHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/29.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMAudioPlayerHelper : NSObject

@property (nonatomic, strong) id model;

+ (instancetype)sharedHelper;

- (void)startPlayerWithPath:(NSString *)aPath
                      model:(id)aModel
                 completion:(void(^)(NSError *error))aCompleton;

- (void)stopPlayer;

@end

NS_ASSUME_NONNULL_END
