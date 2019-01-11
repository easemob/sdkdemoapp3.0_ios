//
//  EMNotifications.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/10.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMNotifications.h"

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

static EMNotifications *shared = nil;
@interface EMNotifications()

@property (nonatomic, strong) EMMulticastDelegate<EMNotificationsDelegate> *delegates;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation EMNotifications

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[EMNotifications alloc] init];
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
        
        [self getNotificationsFromLocal];
    }
    
    return self;
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

@end
