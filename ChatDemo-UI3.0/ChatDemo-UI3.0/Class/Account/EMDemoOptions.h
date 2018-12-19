//
//  EMDemoOptions.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/17.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kOptions_Appkey = @"Appkey";
static NSString *kOptions_ApnsCertname = @"ApnsCertname";
static NSString *kOptions_HttpsOnly = @"HttpsOnly";

static NSString *kOptions_SpecifyServer = @"SpecifyServer";
static NSString *kOptions_IMPort = @"IMPort";
static NSString *kOptions_IMServer = @"IMServer";
static NSString *kOptions_RestServer = @"RestServer";

static NSString *kOptions_AutoLogin = @"AutoLogin";
static NSString *kOptions_AutoAcceptGroupInvitation = @"AutoAcceptGroupInvitation";
static NSString *kOptions_AutoTransMsgFile = @"AutoTransferMessageAttachments";
static NSString *kOptions_AutoDownloadThumb = @"AutoDownloadThumbnail";

static NSString *kOptions_LoggedinUsername = @"LoggedinUsername";

#define DEF_APPKEY @"easemob-demo#chatdemoui"

NS_ASSUME_NONNULL_BEGIN

@class EMOptions;
@interface EMDemoOptions : NSObject <NSCoding>

@property (nonatomic, copy) NSString *appkey;

@property (nonatomic, copy) NSString *apnsCertName;

@property (nonatomic, assign) BOOL usingHttpsOnly;

@property (nonatomic) BOOL specifyServer;

@property (nonatomic, assign) int chatPort;

@property (nonatomic, copy) NSString *chatServer;

@property (nonatomic, copy) NSString *restServer;

@property (nonatomic) BOOL isAutoLogin;
@property (nonatomic) BOOL isAutoAcceptGroupInvitation;
@property (nonatomic) BOOL isAutoTransferMessageAttachments;
@property (nonatomic) BOOL isAutoDownloadThumbnail;

@property (nonatomic, strong) NSString *loggedInUsername;

+ (instancetype)sharedOptions;

- (void)archive;

- (EMOptions *)toOptions;

@end

NS_ASSUME_NONNULL_END
