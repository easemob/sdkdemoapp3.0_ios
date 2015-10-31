/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */


//  用来处理UIDemo上的数据，您使用时请自己处理相关部分db

#import <Foundation/Foundation.h>

@class ApplyEntity;
@interface InvitationManager : NSObject

+ (instancetype)sharedInstance;

-(void)addInvitation:(ApplyEntity *)applyEntity loginUser:(NSString *)username;

-(void)removeInvitation:(ApplyEntity *)applyEntity loginUser:(NSString *)username;

-(NSArray *)applyEmtitiesWithloginUser:(NSString *)username;

@end

@interface ApplyEntity : NSObject 

@property (nonatomic, strong) NSString * applicantUsername;
@property (nonatomic, strong) NSString * applicantNick;
@property (nonatomic, strong) NSString * reason;
@property (nonatomic, strong) NSString * receiverUsername;
@property (nonatomic, strong) NSString * receiverNick;
@property (nonatomic, strong) NSNumber * style;
@property (nonatomic, strong) NSString * groupId;
@property (nonatomic, strong) NSString * groupSubject;

@end
