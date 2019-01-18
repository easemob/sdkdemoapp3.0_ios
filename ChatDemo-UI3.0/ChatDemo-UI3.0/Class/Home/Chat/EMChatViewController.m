//
//  EMChatViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatViewController.h"

@interface EMChatViewController ()

@property (nonatomic, strong) EMConversation *conversation;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *titleDetailLabel;

@end

@implementation EMChatViewController

- (instancetype)initWithCoversation:(EMConversation *)aConversation
{
    self = [super init];
    if (self) {
        _conversation = aConversation;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupChatSubviews];
}

#pragma mark - Subviews

- (void)_setupChatSubviews
{
    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
    [self _setupNavigationBarTitle];
    [self _setupNavigationBarRightItem];
}

- (void)_setupNavigationBarTitle
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 06, 40)];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:17];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.text = self.conversation.conversationId;
    [titleView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleView);
        make.left.equalTo(titleView).offset(5);
        make.right.equalTo(titleView).offset(-5);
    }];
    
    self.titleDetailLabel = [[UILabel alloc] init];
    self.titleDetailLabel.font = [UIFont systemFontOfSize:15];
    self.titleDetailLabel.textColor = [UIColor grayColor];
    self.titleDetailLabel.text = self.conversation.conversationId;
    [titleView addSubview:self.titleDetailLabel];
    [self.titleDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel);
        make.bottom.equalTo(titleView);
    }];
    
    self.navigationItem.titleView = titleView;
}

- (void)_setupNavigationBarRightItem
{
    if (self.conversation.type == EMConversationTypeChat) {
        UIImage *image = [[UIImage imageNamed:@"clear_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllMessageAction)];
    } else {
        
    }
}

#pragma mark - Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteAllMessageAction
{
    
}

@end
