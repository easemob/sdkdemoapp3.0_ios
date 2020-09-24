//
//  NotificationService.m
//  EMPushNotificationService
//
//  Created by 娜塔莎 on 2020/9/1.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    NSString *contentId = [[request.content.userInfo objectForKey:@"e"] objectForKey:@"need-delete-content-id"];
    __weak typeof(self) weakSelf = self;
    
    [self removeSingleNotification:contentId callBack:^(int invalidBadge) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.bestAttemptContent.badge = [NSNumber numberWithInt:([weakSelf.bestAttemptContent.badge intValue] - invalidBadge)];
            weakSelf.contentHandler(weakSelf.bestAttemptContent);
        });
    }];
}

- (void)removeSingleNotification:(NSString *)contentId
                        callBack:(void(^)(int invalidBadge))callBack{
    [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
        int invalidBadge = 0;
        for (UNNotification *notification in notifications) {
            UNNotificationRequest *request = notification.request;
            NSString *preContentId = [[request.content.userInfo objectForKey:@"e"] objectForKey:@"target-content-id"];
            if (preContentId && [preContentId isEqualToString:contentId]) {
                [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[request.identifier]];
                ++invalidBadge;
            }
        }
        callBack(invalidBadge);
    }];
}
- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
