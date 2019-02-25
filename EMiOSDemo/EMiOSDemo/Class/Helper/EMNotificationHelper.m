//
//  EMNotificationHelper.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/10.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMNotificationHelper.h"

#import "EMMulticastDelegate.h"

static NSString *kNotifications_Sender = @"sender";
static NSString *kNotifications_Receiver = @"receiver";
static NSString *kNotifications_GroupId = @"groupId";
static NSString *kNotifications_Message = @"message";
static NSString *kNotifications_Time = @"time";
static NSString *kNotifications_Status = @"status";
static NSString *kNotifications_Type = @"type";
static NSString *kNotifications_IsRead = @"isRead";

@implementation EMNotificationModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.groupId = @"";
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.sender = [aDecoder decodeObjectForKey:kNotifications_Sender];
        self.receiver = [aDecoder decodeObjectForKey:kNotifications_Receiver];
        self.groupId = [aDecoder decodeObjectForKey:kNotifications_GroupId];
        self.message = [aDecoder decodeObjectForKey:kNotifications_Message];
        self.time = [aDecoder decodeObjectForKey:kNotifications_Time];
        self.status = [aDecoder decodeIntegerForKey:kNotifications_Status];
        self.type = [aDecoder decodeIntegerForKey:kNotifications_Type];
        self.isRead = [aDecoder decodeBoolForKey:kNotifications_IsRead];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.sender forKey:kNotifications_Sender];
    [aCoder encodeObject:self.receiver forKey:kNotifications_Receiver];
    [aCoder encodeObject:self.groupId forKey:kNotifications_GroupId];
    [aCoder encodeObject:self.message forKey:kNotifications_Message];
    [aCoder encodeObject:self.time forKey:kNotifications_Time];
    [aCoder encodeInteger:self.status forKey:kNotifications_Status];
    [aCoder encodeInteger:self.type forKey:kNotifications_Type];
    [aCoder encodeBool:self.isRead forKey:kNotifications_IsRead];
}

@end

static EMNotificationHelper *shared = nil;
@interface EMNotificationHelper()

@property (nonatomic, strong) EMMulticastDelegate<EMNotificationsDelegate> *delegates;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation EMNotificationHelper

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[EMNotificationHelper alloc] init];
    });
    
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fileName = [NSString stringWithFormat:@"emdemo_notifications_%@.data", [EMClient sharedClient].currentUsername];
        _notificationList = [[NSMutableArray alloc] init];
        _isCheckUnreadCount = YES;
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
        
        _delegates = (EMMulticastDelegate<EMNotificationsDelegate> *)[[EMMulticastDelegate alloc] init];
        
        [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
        [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
        [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
        
        [self getNotificationsFromLocal];
    }
    
    return self;
}

- (void)dealloc
{
    [self.delegates removeAllDelegates];
    
    [[EMClient sharedClient] removeMultiDevicesDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
}

#pragma mark - Private

- (void)getNotificationsFromLocal
{
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:self.fileName];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    [self.notificationList removeAllObjects];
    [self.notificationList addObjectsFromArray:array];
    
    _unreadCount = [self getUnreadCount];
    if (self.isCheckUnreadCount) {
        [self.delegates didNotificationsUnreadCountUpdate:_unreadCount];
    }
}

- (NSInteger)getUnreadCount
{
    NSInteger ret = 0;
    for (EMNotificationModel *model in self.notificationList) {
        if (!model.isRead) {
            ++ret;
        }
    }
    
    return ret;
}

#pragma mark - Public

- (void)addDelegate:(id<EMNotificationsDelegate>)aDelegate
{
    [self.delegates addDelegate:aDelegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<EMNotificationsDelegate>)aDelegate
{
    [self.delegates removeDelegate:aDelegate];
}

- (void)archive
{
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:self.fileName];
    [NSKeyedArchiver archiveRootObject:self.notificationList toFile:file];
}

- (void)markAllAsRead
{
    BOOL isArchive = NO;
    for (EMNotificationModel *model in self.notificationList) {
        if (!model.isRead) {
            model.isRead = YES;
            isArchive = YES;
        }
    }
    
    if (isArchive) {
        [self archive];
    }
    
    if (self.unreadCount != 0) {
        _unreadCount = 0;
        
        if (self.isCheckUnreadCount) {
            [self.delegates didNotificationsUnreadCountUpdate:0];
        }
    }
}

- (void)insertModel:(EMNotificationModel *)aModel
{
    NSString *time = [self.dateFormatter stringFromDate:[NSDate date]];
    for (EMNotificationModel *model in self.notificationList) {
        if (model.type == aModel.type && model.status == aModel.status && [model.sender isEqualToString:aModel.sender] && [model.groupId isEqualToString:aModel.groupId]) {
            [self.notificationList removeObject:model];
            break;
        }
    }
    
    aModel.time = time;
    if ([aModel.message length] == 0) {
        if (aModel.type == EMNotificationModelTypeContact) {
            aModel.message = @"申请添加您为好友";
        } else if (aModel.type == EMNotificationModelTypeGroupInvite) {
            aModel.message = [NSString stringWithFormat:@"邀请您加入群组\"%@\"", aModel.groupId];
        }
    }
    
    if (!self.isCheckUnreadCount) {
        aModel.isRead = YES;
    } else {
        ++_unreadCount;
        [self.delegates didNotificationsUnreadCountUpdate:self.unreadCount];
    }
    
    [self.notificationList insertObject:aModel atIndex:0];
    [self archive];
    
    [self.delegates didNotificationsUpdate];
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesContactEventDidReceive:(EMMultiDevicesEvent)aEvent
                                  username:(NSString *)aTarget
                                       ext:(NSString *)aExt
{
    if (aEvent == EMMultiDevicesEventContactAccept || aEvent == EMMultiDevicesEventContactDecline) {
        for (EMNotificationModel *model in self.notificationList) {
            if (model.type == EMNotificationModelTypeContact && [model.sender isEqualToString:aTarget]) {
                if (!model.isRead && self.unreadCount > 0) {
                    model.isRead = YES;
                    --_unreadCount;
                    
                    if (self.isCheckUnreadCount) {
                        [self.delegates didNotificationsUnreadCountUpdate:_unreadCount];
                    }
                }
                model.status = aEvent == EMMultiDevicesEventContactAccept ? EMNotificationModelStatusAgreed : EMNotificationModelStatusDeclined;
                [self archive];
                [self.delegates didNotificationsUpdate];
                
                break;
            }
        }
    }
}

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt
{
    if (aEvent == EMMultiDevicesEventGroupInviteDecline || aEvent == EMMultiDevicesEventGroupInviteAccept || aEvent == EMMultiDevicesEventGroupApplyAccept || aEvent == EMMultiDevicesEventGroupApplyDecline) {
        EMNotificationModelType type = EMNotificationModelTypeGroupInvite;
        if (aEvent == EMMultiDevicesEventGroupApplyAccept || aEvent == EMMultiDevicesEventGroupApplyDecline) {
            type = EMNotificationModelTypeGroupJoin;
        }
        
        EMNotificationModelStatus status = EMNotificationModelStatusAgreed;
        if (aEvent == EMMultiDevicesEventGroupInviteDecline || aEvent == EMMultiDevicesEventGroupApplyDecline) {
            status = EMNotificationModelStatusDeclined;
        }
        
        for (EMNotificationModel *model in self.notificationList) {
            if (model.type == EMNotificationModelTypeGroupJoin && [model.groupId isEqualToString:aGroupId]) {
                if (!model.isRead && self.unreadCount > 0) {
                    model.isRead = YES;
                    --_unreadCount;
                    
                    if (self.isCheckUnreadCount) {
                        [self.delegates didNotificationsUnreadCountUpdate:_unreadCount];
                    }
                }
                
                model.status = status;
                [self archive];
                [self.delegates didNotificationsUpdate];
                
                break;
            }
        }
    }
}


#pragma mark - EMContactManagerDelegate

- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername
                                message:(NSString *)aMessage
{
    if ([aUsername length] == 0) {
        return;
    }
    
    if ([aMessage length] == 0) {
        aMessage = @"申请添加您为好友";
    }
    
    EMNotificationModel *model = [[EMNotificationModel alloc] init];
    model.sender = aUsername;
    model.message = aMessage;
    model.type = EMNotificationModelTypeContact;
    [self insertModel:model];
}

#pragma mark - EMGroupManagerDelegate

- (void)groupInvitationDidReceive:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage
{
    if ([aGroupId length] == 0 || [aInviter length] == 0) {
        return;
    }
    
    EMNotificationModel *model = [[EMNotificationModel alloc] init];
    model.sender = aInviter;
    model.groupId = aGroupId;
    model.type = EMNotificationModelTypeGroupInvite;
    model.message = aMessage;
    [[EMNotificationHelper shared] insertModel:model];
}

- (void)joinGroupRequestDidReceive:(EMGroup *)aGroup
                              user:(NSString *)aUsername
                            reason:(NSString *)aReason
{
    if ([aGroup.groupId length] == 0 || [aUsername length] == 0) {
        return;
    }
    
    EMNotificationModel *model = [[EMNotificationModel alloc] init];
    model.sender = aUsername;
    model.groupId = aGroup.groupId;
    model.type = EMNotificationModelTypeGroupJoin;
    model.message = [NSString stringWithFormat:@"申请加入群组\"%@\"", aGroup.groupId];;
    [[EMNotificationHelper shared] insertModel:model];
}

@end
