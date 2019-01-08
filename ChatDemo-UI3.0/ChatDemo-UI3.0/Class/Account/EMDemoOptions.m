//
//  EMDemoOptions.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/17.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMDemoOptions.h"

#import <Hyphenate/EMOptions+PrivateDeploy.h>

static EMDemoOptions *sharedOptions = nil;
@implementation EMDemoOptions

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reInit];
    }
    
    return self;
}

+ (instancetype)sharedOptions
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOptions = [EMDemoOptions getOptionsFromLocal];
    });
    
    return sharedOptions;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        NSString *appkey = [aDecoder decodeObjectForKey:kOptions_Appkey];
        if ([appkey length] == 0) {
            appkey = DEF_APPKEY;
        }
        self.appkey = appkey;
        self.apnsCertName = [aDecoder decodeObjectForKey:kOptions_ApnsCertname];
        self.usingHttpsOnly = [aDecoder decodeBoolForKey:kOptions_HttpsOnly];
        
        self.specifyServer = [aDecoder decodeBoolForKey:kOptions_SpecifyServer];
        self.chatPort = [aDecoder decodeIntForKey:kOptions_IMPort];
        self.chatServer = [aDecoder decodeObjectForKey:kOptions_IMServer];
        self.restServer = [aDecoder decodeObjectForKey:kOptions_RestServer];
        
        self.isDeleteMessagesWhenExitGroup = [aDecoder decodeBoolForKey:kOptions_DeleteChatExitGroup];
        self.isAutoAcceptGroupInvitation = [aDecoder decodeBoolForKey:kOptions_AutoAcceptGroupInvitation];
        self.isAutoTransferMessageAttachments = [aDecoder decodeBoolForKey:kOptions_AutoTransMsgFile];
        self.isAutoDownloadThumbnail = [aDecoder decodeBoolForKey:kOptions_AutoDownloadThumb];
        self.isSortMessageByServerTime = [aDecoder decodeBoolForKey:kOptions_SortMessageByServerTime];
        self.isPriorityGetMsgFromServer = [aDecoder decodeBoolForKey:kOptions_PriorityGetMsgFromServer];
        
        self.isAutoLogin = [aDecoder decodeBoolForKey:kOptions_AutoLogin];
        self.loggedInUsername = [aDecoder decodeObjectForKey:kOptions_LoggedinUsername];
        self.loggedInPassword = [aDecoder decodeObjectForKey:kOptions_LoggedinPassword];
        
        self.isChatTyping = [aDecoder decodeBoolForKey:kOptions_ChatTyping];
        self.isAutoDeliveryAck = [aDecoder decodeBoolForKey:kOptions_AutoDeliveryAck];
        
        self.isShowCallInfo = [aDecoder decodeBoolForKey:kOptions_ShowCallInfo];
        self.isUseBackCamera = [aDecoder decodeBoolForKey:kOptions_UseBackCamera];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.appkey forKey:kOptions_Appkey];
    [aCoder encodeObject:self.apnsCertName forKey:kOptions_ApnsCertname];
    [aCoder encodeBool:self.usingHttpsOnly forKey:kOptions_HttpsOnly];
    
    [aCoder encodeBool:self.specifyServer forKey:kOptions_SpecifyServer];
    [aCoder encodeInt:self.chatPort forKey:kOptions_IMPort];
    [aCoder encodeObject:self.chatServer forKey:kOptions_IMServer];
    [aCoder encodeObject:self.restServer forKey:kOptions_RestServer];
    
    [aCoder encodeBool:self.isDeleteMessagesWhenExitGroup forKey:kOptions_DeleteChatExitGroup];
    [aCoder encodeBool:self.isAutoAcceptGroupInvitation forKey:kOptions_AutoAcceptGroupInvitation];
    [aCoder encodeBool:self.isAutoTransferMessageAttachments forKey:kOptions_AutoTransMsgFile];
    [aCoder encodeBool:self.isAutoDownloadThumbnail forKey:kOptions_AutoDownloadThumb];
    [aCoder encodeBool:self.isSortMessageByServerTime forKey:kOptions_SortMessageByServerTime];
    [aCoder encodeBool:self.isPriorityGetMsgFromServer forKey:kOptions_PriorityGetMsgFromServer];
    
    [aCoder encodeBool:self.isAutoLogin forKey:kOptions_AutoLogin];
    [aCoder encodeObject:self.loggedInUsername forKey:kOptions_LoggedinUsername];
    [aCoder encodeObject:self.loggedInPassword forKey:kOptions_LoggedinPassword];
    
    [aCoder encodeBool:self.isChatTyping forKey:kOptions_ChatTyping];
    [aCoder encodeBool:self.isAutoDeliveryAck forKey:kOptions_AutoDeliveryAck];
    
    [aCoder encodeBool:self.isShowCallInfo forKey:kOptions_ShowCallInfo];
    [aCoder encodeBool:self.isUseBackCamera forKey:kOptions_UseBackCamera];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    EMDemoOptions *retModel = [[[self class] alloc] init];
    retModel.appkey = self.appkey;
    retModel.apnsCertName = self.apnsCertName;
    retModel.usingHttpsOnly = self.usingHttpsOnly;
    retModel.specifyServer = self.specifyServer;
    retModel.chatPort = self.chatPort;
    retModel.chatServer = self.chatServer;
    retModel.restServer = self.restServer;
    retModel.isDeleteMessagesWhenExitGroup = self.isDeleteMessagesWhenExitGroup;
    retModel.isAutoAcceptGroupInvitation = self.isAutoAcceptGroupInvitation;
    retModel.isAutoTransferMessageAttachments = self.isAutoTransferMessageAttachments;
    retModel.isAutoDownloadThumbnail = self.isAutoDownloadThumbnail;
    retModel.isSortMessageByServerTime = self.isSortMessageByServerTime;
    retModel.isPriorityGetMsgFromServer = self.isPriorityGetMsgFromServer;
    retModel.isAutoLogin = self.isAutoLogin;
    retModel.loggedInUsername = self.loggedInUsername;
    retModel.loggedInPassword = self.loggedInPassword;
    retModel.isChatTyping = self.isChatTyping;
    retModel.isAutoDeliveryAck = self.isAutoDeliveryAck;
    retModel.isShowCallInfo = self.isShowCallInfo;
    retModel.isUseBackCamera = self.isUseBackCamera;
    
    return retModel;
}

- (void)setLoggedInUsername:(NSString *)loggedInUsername
{
    if (![_loggedInUsername isEqualToString:loggedInUsername]) {
        _loggedInUsername = loggedInUsername;
        _loggedInPassword = @"";
    }
}

+ (EMDemoOptions *)getOptionsFromLocal
{
    EMDemoOptions *retModel = nil;
    NSString *fileName = @"emdemo_options.data";
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
    retModel = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    if (!retModel) {
        retModel = [[EMDemoOptions alloc] init];
        [retModel archive];
    }
    
    return retModel;
}

- (void)archive
{
    NSString *fileName = @"emdemo_options.data";
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
    [NSKeyedArchiver archiveRootObject:self toFile:file];
}

- (void)reInit
{
    self.appkey = DEF_APPKEY;
#if DEBUG
    self.apnsCertName = @"chatdemoui_dev";
#else
    self.apnsCertName = @"chatdemoui";
#endif
    self.usingHttpsOnly = NO;
    self.specifyServer = NO;
    self.chatServer = @"msync-im1.sandbox.easemob.com";
    self.chatPort = 6717;
    self.restServer = @"a1.sdb.easemob.com";
    
    self.isDeleteMessagesWhenExitGroup = NO;
    self.isAutoAcceptGroupInvitation = NO;
    self.isAutoTransferMessageAttachments = YES;
    self.isAutoDownloadThumbnail = YES;
    self.isSortMessageByServerTime = NO;
    self.isPriorityGetMsgFromServer = NO;
    
    self.isAutoLogin = NO;
    self.loggedInUsername = @"";
    self.loggedInPassword = @"";
    
    self.isChatTyping = NO;
    self.isAutoDeliveryAck = NO;
    
    self.isShowCallInfo = NO;
    self.isUseBackCamera = NO;
}

- (EMOptions *)toOptions
{
    EMOptions *retOpt = [EMOptions optionsWithAppkey:self.appkey];
    retOpt.apnsCertName = self.apnsCertName;
    retOpt.usingHttpsOnly = self.usingHttpsOnly;

    retOpt.enableConsoleLog = YES;
    if (self.specifyServer) {
        retOpt.enableDnsConfig = NO;
        retOpt.chatPort = self.chatPort;
        retOpt.chatServer = self.chatServer;
        retOpt.restServer = self.restServer;
    }
    
    retOpt.isAutoLogin = self.isAutoLogin;
    
    retOpt.isDeleteMessagesWhenExitGroup = self.isDeleteMessagesWhenExitGroup;
    retOpt.isAutoAcceptGroupInvitation = self.isAutoTransferMessageAttachments;
    retOpt.isAutoTransferMessageAttachments = self.isAutoTransferMessageAttachments;
    retOpt.isAutoDownloadThumbnail = self.isAutoDownloadThumbnail;
    retOpt.sortMessageByServerTime = self.isSortMessageByServerTime;
    
    retOpt.enableDeliveryAck = self.isAutoDeliveryAck;
    
    return retOpt;
}

@end
