//
//  ShareFilesViewController.m
//  ChatDemo-UI3.0
//
//  Created by 杜洁鹏 on 15/03/2017.
//  Copyright © 2017 杜洁鹏. All rights reserved.
//

#import "ShareFilesViewController.h"
#import "ChatViewController.h"
#import "UserProfileManager.h"

@interface ShareFilesViewController () <EMUserListViewControllerDelegate,EMUserListViewControllerDataSource>
{
    NSURL *_url;
}
@end

@implementation ShareFilesViewController

- (instancetype)initWithUrl:(NSURL *)url {
    if(self = [super init]) {
        _url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    self.delegate = self;
    self.dataSource = self;
}

- (void)setupUI {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    backButton.accessibilityIdentifier = @"back";
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EMUserListViewControllerDelegate
- (void)userListViewController:(EaseUsersListViewController *)userListViewController
            didSelectUserModel:(id<IUserModel>)userModel{
    
    NSString *strPath = _url.absoluteString;
    NSString *suffix = [strPath pathExtension];
    NSData *data = [NSData dataWithContentsOfURL:_url];
    if (data.length > 1024 * 1024 * 10) {
        return;
    }
    
    EMMessageBody *body = nil;
    NSString *name = [[_url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding].lastPathComponent;
    if ([suffix isEqualToString:@"jpg"] || [suffix isEqualToString:@"png"]) {
        body = [[EMImageMessageBody alloc] initWithData:data displayName:name];
    } else if ([suffix isEqualToString:@"mp4"]) {
        body = [[EMVideoMessageBody alloc] initWithData:data displayName:name];
    } else {
        body = [[EMFileMessageBody alloc] initWithData:data displayName:name];
    }
    
    [self clearInBox];
    NSString *from = [EMClient sharedClient].currentUsername;
    EMMessage *newMsg = [[EMMessage alloc] initWithConversationID:userModel.buddy from:from to:userModel.buddy body:body ext:nil];
    __weak typeof(self) weakSelf = self;

    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[weakSelf.navigationController viewControllers]];
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:userModel.buddy conversationType:EMConversationTypeChat];
    chatController.title = userModel.nickname.length != 0 ? userModel.nickname : userModel.buddy;
    [array removeLastObject];
    [array addObject:chatController];
    [weakSelf.navigationController setViewControllers:array animated:YES];
    [chatController viewDidLoad];
    [chatController sendFileMessageWith:newMsg];
}

#pragma mark - EMUserListViewControllerDataSource
- (id<IUserModel>)userListViewController:(EaseUsersListViewController *)userListViewController
                           modelForBuddy:(NSString *)buddy
{
    id<IUserModel> model = nil;
    model = [[EaseUserModel alloc] initWithBuddy:buddy];
    UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:model.buddy];
    if (profileEntity) {
        model.nickname= profileEntity.nickname == nil ? profileEntity.username : profileEntity.nickname;
        model.avatarURLPath = profileEntity.imageUrl;
    }
    return model;
}

- (id<IUserModel>)userListViewController:(EaseUsersListViewController *)userListViewController
                   userModelForIndexPath:(NSIndexPath *)indexPath
{
    id<IUserModel> model = nil;
    model = [self.dataArray objectAtIndex:indexPath.row];
    UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:model.buddy];
    if (profileEntity) {
        model.nickname= profileEntity.nickname == nil ? profileEntity.username : profileEntity.nickname;
        model.avatarURLPath = profileEntity.imageUrl;
    }
    return model;
}

#pragma mark - action
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clearInBox {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    [fm removeItemAtURL:_url error:&error];
    if (error) {
        NSLog(@"删除失败");
    }
}

@end
