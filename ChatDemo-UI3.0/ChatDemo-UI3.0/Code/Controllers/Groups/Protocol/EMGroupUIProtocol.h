//
//  EMGroupUIProtocol.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/10.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMUserModel;
@class EMGroupModel;

@protocol EMGroupUIProtocol <NSObject>

@optional

- (void)addSelectOccupants:(NSArray<EMUserModel *> *)modelArray;

- (void)removeSelectOccupants:(NSArray<EMUserModel *> *)modelArray;

- (void)joinPublicGroup:(EMGroupModel *)groupModel;

@end
