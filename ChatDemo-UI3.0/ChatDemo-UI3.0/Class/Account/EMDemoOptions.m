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
        
        self.isAutoLogin = NO;
        self.isAutoAcceptGroupInvitation = NO;
        self.isAutoTransferMessageAttachments = NO;
        self.isAutoDownloadThumbnail = YES;
    }
    
    return self;
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
        
        self.isAutoLogin = [aDecoder decodeBoolForKey:kOptions_AutoLogin];
        self.isAutoAcceptGroupInvitation = [aDecoder decodeBoolForKey:kOptions_AutoAcceptGroupInvitation];
        self.isAutoTransferMessageAttachments = [aDecoder decodeBoolForKey:kOptions_AutoTransMsgFile];
        self.isAutoDownloadThumbnail = [aDecoder decodeBoolForKey:kOptions_AutoDownloadThumb];
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
    
    [aCoder encodeBool:self.isAutoLogin forKey:kOptions_AutoLogin];
    [aCoder encodeBool:self.isAutoAcceptGroupInvitation forKey:kOptions_AutoAcceptGroupInvitation];
    [aCoder encodeBool:self.isAutoTransferMessageAttachments forKey:kOptions_AutoTransMsgFile];
    [aCoder encodeBool:self.isAutoDownloadThumbnail forKey:kOptions_AutoDownloadThumb];
    
}

+ (instancetype)sharedOptions
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOptions = [EMDemoOptions getOptionsFromLocal];
    });
    
    return sharedOptions;
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

- (EMOptions *)toOptions
{
    EMOptions *retOpt = [EMOptions optionsWithAppkey:self.appkey];
    retOpt.apnsCertName = self.apnsCertName;
    retOpt.usingHttpsOnly = self.usingHttpsOnly;
    retOpt.isAutoLogin = YES;
    retOpt.isAutoAcceptGroupInvitation = self.isAutoTransferMessageAttachments;
    retOpt.isAutoTransferMessageAttachments = self.isAutoTransferMessageAttachments;
    retOpt.isAutoDownloadThumbnail = self.isAutoDownloadThumbnail;
    
    retOpt.enableConsoleLog = YES;
    if (self.specifyServer) {
        retOpt.enableDnsConfig = NO;
        retOpt.chatPort = self.chatPort;
        retOpt.chatServer = self.chatServer;
        retOpt.restServer = self.restServer;
    }
    
    return retOpt;
}

@end
