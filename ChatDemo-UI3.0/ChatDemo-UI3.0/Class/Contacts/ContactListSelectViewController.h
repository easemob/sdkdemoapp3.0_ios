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

@interface ContactListSelectViewController : EaseUsersListViewController

@property (strong ,nonatomic) EaseMessageModel *messageModel;

@property (assign, nonatomic) BOOL isVcard;

@property (nonatomic, copy) void(^SelectedBuddy)(id<IUserModel> userModel);

@end
