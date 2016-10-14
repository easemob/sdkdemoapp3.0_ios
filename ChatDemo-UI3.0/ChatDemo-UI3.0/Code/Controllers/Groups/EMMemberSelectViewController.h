//
//  EMContactsSelectViewController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/6.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMUserModel;
#import "EMGroupUIProtocol.h"

typedef NS_ENUM(NSUInteger, EMContactSelectStyle) {
    EMContactSelectStyle_Add      =       0,
    EMContactSelectStyle_Invite
};

@interface EMMemberSelectViewController : UIViewController

@property (nonatomic, assign) EMContactSelectStyle style;

@property (nonatomic, assign) id<EMGroupUIProtocol> delegate;

- (instancetype)initWithInvitees:(NSArray *)hasInvitees;

@end
