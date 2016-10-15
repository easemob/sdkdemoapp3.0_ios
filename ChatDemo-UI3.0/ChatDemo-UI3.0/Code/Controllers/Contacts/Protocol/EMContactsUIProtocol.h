//
//  EMContactsUIProtocol.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EMContactsUIProtocol <NSObject>

@optional

- (void)needRefreshContacts:(BOOL)isNeedRefresh;

- (void)needRefreshContactsFromServer:(BOOL)isNeedRefresh;

@end
