//
//  EMChatViewController+EMMsgLongPressIncident.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatViewController.h"
#import "EMMessageModel.h"
#import "EMMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatViewController (EMMsgLongPressIncident)

//长按操作栏
@property (strong, nonatomic) NSIndexPath *__nullable menuIndexPath;

@property (nonatomic, strong) UIMenuItem *deleteMenuItem;
@property (nonatomic, strong) UIMenuItem *copyMenuItem;
@property (nonatomic, strong) UIMenuItem *recallMenuItem;
@property (nonatomic, strong) UIMenuItem *transpondMenuItem;

- (NSMutableArray *)showMenuViewController:(EMMessageCell *)aCell
                                     model:(EMMessageModel *)aModel;

- (void)deleteMenuItemAction:(UIMenuItem *)aItem;

- (void)copyMenuItemAction:(UIMenuItem *)aItem;

- (void)transpondMenuItemAction:(UIMenuItem *)aItem;

- (void)recallMenuItemAction:(UIMenuItem *)aItem;

@end

NS_ASSUME_NONNULL_END
