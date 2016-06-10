/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

#define kPARSE_HXUSER @"hxuser"
#define kPARSE_HXUSER_USERNAME @"username"
#define kPARSE_HXUSER_NICKNAME @"nickname"
#define kPARSE_HXUSER_AVATAR @"avatar"

@class MessageModel;
@class PFObject;
@class UserProfileEntity;

@interface UserProfileManager : NSObject

+ (instancetype)sharedInstance;

- (void)initParse;

- (void)clearParse;
- (void)uploadUserHeadImageProfileInBackground:(UIImage*)image
                                    completion:(void (^)(BOOL success, NSError *error))completion;
- (void)updateUserProfileInBackground:(NSDictionary*)param
                                    completion:(void (^)(BOOL success, NSError *error))completion;
- (void)loadUserProfileInBackground:(NSArray*)usernames
                       saveToLoacal:(BOOL)save
                         completion:(void (^)(BOOL success, NSError *error))completion;
- (void)loadUserProfileInBackgroundWithBuddy:(NSArray*)buddyList
                                saveToLoacal:(BOOL)save
                                  completion:(void (^)(BOOL success, NSError *error))completion;
- (UserProfileEntity*)getUserProfileByUsername:(NSString*)username;
- (UserProfileEntity*)getCurUserProfile;
- (NSString*)getNickNameWithUsername:(NSString*)username;

@end


@interface UserProfileEntity : NSObject

+ (instancetype)initWithPFObject:(PFObject*)object;

@property (nonatomic,strong) NSString *objectId;
@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *nickname;
@property (nonatomic,strong) NSString *imageUrl;

@end
