//
//  EMChatViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatViewController.h"

#import "EMConversationHelper.h"

#import "EMGroupInfoViewController.h"

@interface EMChatViewController ()

@property (nonatomic, strong) EMConversationModel *conversationModel;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *titleDetailLabel;

@end

@implementation EMChatViewController

- (instancetype)initWithCoversation:(EMConversationModel *)aConversationModel
{
    self = [super init];
    if (self) {
        _conversationModel = aConversationModel;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupChatSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [EMConversationHelper markAllAsRead:self.conversationModel.emModel];
}

#pragma mark - Subviews

- (void)_setupChatSubviews
{
    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
    [self _setupNavigationBarTitle];
    [self _setupNavigationBarRightItem];
    
    self.view.backgroundColor = kColor_LightGray;
    self.tableView.backgroundColor = kColor_LightGray;
}

- (void)_setupNavigationBarTitle
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 06, 40)];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = self.conversationModel.name;
    [titleView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleView);
        make.left.equalTo(titleView).offset(5);
        make.right.equalTo(titleView).offset(-5);
    }];
    
    self.titleDetailLabel = [[UILabel alloc] init];
    self.titleDetailLabel.font = [UIFont systemFontOfSize:15];
    self.titleDetailLabel.textColor = [UIColor grayColor];
    self.titleDetailLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:self.titleDetailLabel];
    [self.titleDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel);
        make.bottom.equalTo(titleView);
    }];
    
    self.navigationItem.titleView = titleView;
    
    if (self.conversationModel.emModel.type != EMConversationTypeChat) {
        self.titleDetailLabel.text = self.conversationModel.emModel.conversationId;
    }
}

- (void)_setupNavigationBarRightItem
{
    if (self.conversationModel.emModel.type == EMConversationTypeChat) {
        UIImage *image = [[UIImage imageNamed:@"close_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllMessageAction)];
    } else {
        UIImage *image = [[UIImage imageNamed:@"search_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(groupOrChatroomInfoAction)];
    }
}

#pragma mark - Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteAllMessageAction
{
    EMError *error = nil;
    [self.conversationModel.emModel deleteAllMessages:&error];
    if (!error) {
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)groupOrChatroomInfoAction
{
    if (self.conversationModel.emModel.type == EMConversationTypeGroupChat) {
        EMGroupInfoViewController *controller = [[EMGroupInfoViewController alloc] initWithGroupId:self.conversationModel.emModel.conversationId];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (self.conversationModel.emModel.type == EMConversationTypeChatRoom) {
        
    }
}

@end
