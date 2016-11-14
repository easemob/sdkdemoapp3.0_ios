//
//  EMMainViewController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/19.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMMainViewController : UITabBarController

-(void)setupUnreadMessageCount;

- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

@end
