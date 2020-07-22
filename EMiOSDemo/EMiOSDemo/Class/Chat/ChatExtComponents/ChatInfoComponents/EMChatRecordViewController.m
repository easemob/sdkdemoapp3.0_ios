//
//  EMChatRecordViewController.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2020/7/15.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatRecordViewController.h"

@interface EMChatRecordViewController ()

@property (nonatomic, strong) EMConversationModel *conversationModel;

@end

@implementation EMChatRecordViewController

- (instancetype)initWithCoversationModel:(EMConversationModel *)aConversationModel
{
    if (self = [super init]) {
        _conversationModel = aConversationModel;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupChatSubviews];
}

#pragma mark - Subviews

- (void)_setupChatSubviews
{
    [self addPopBackLeftItem];
    self.title = @"聊天记录";
    self.view.backgroundColor = [UIColor whiteColor];
    self.showRefreshHeader = NO;
    self.searchBar.delegate = self;
    self.searchBar.layer.cornerRadius = 20;
    
    [self.searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.equalTo(@36);
    }];
    
    self.searchResultTableView.backgroundColor = kColor_LightGray;
    self.searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchResultTableView.rowHeight = UITableViewAutomaticDimension;
    self.searchResultTableView.estimatedRowHeight = 130;
}

@end
