//
//  EMChatRecordViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/15.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatRecordViewController.h"
#import "EMAvatarNameCell.h"
#import "EMDateHelper.h"
#import "EMAvatarNameModel.h"
#import "EMChatControllerFactory.h"

@interface EMChatRecordViewController ()<EMSearchBarDelegate, EMAvatarNameCellDelegate>

@property (nonatomic, strong) EMConversationModel *conversationModel;
@property (nonatomic, strong) dispatch_queue_t msgQueue;
//消息格式化
@property (nonatomic) NSTimeInterval msgTimelTag;
@property (nonatomic, strong) NSString *keyWord;

@end

@implementation EMChatRecordViewController

- (instancetype)initWithCoversationModel:(EMConversationModel *)aConversationModel
{
    if (self = [super init]) {
        _conversationModel = aConversationModel;
        _msgQueue = dispatch_queue_create("emmessagerecord.com", NULL);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.msgTimelTag = -1;
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
        make.left.equalTo(self.view).offset(8);
        make.right.equalTo(self.view).offset(-8);
        make.height.equalTo(@36);
    }];
    [self.searchBar.textField becomeFirstResponder];
    
    self.searchResultTableView.backgroundColor = kColor_LightGray;
    self.searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchResultTableView.rowHeight = UITableViewAutomaticDimension;
    self.searchResultTableView.estimatedRowHeight = 130;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self.searchResults objectAtIndex:indexPath.row];
    EMAvatarNameModel *model = (EMAvatarNameModel *)obj;

    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"chatRecord"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatRecord"];
    }
    cell.indexPath = indexPath;
    cell.model = model;
    cell.delegate = self;
    return cell;
}

#pragma mark - EMAvatarNameCellDelegate

- (void)cellAccessoryButtonAction:(EMAvatarNameCell *)aCell
{
    EMChatViewController *chatController = [EMChatControllerFactory getChatControllerInstance:self.conversationModel.emModel.conversationId conversationType:self.conversationModel.emModel.type];
    chatController.modalPresentationStyle = 0;
    [self.navigationController pushViewController:chatController animated:NO];
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarSearchButtonClicked:(NSString *)aString
{
    _keyWord = aString;
    [self.view endEditing:YES];
    if (!self.isSearching) return;
    NSDate *currentDate = [NSDate date];
    NSTimeInterval interval = [currentDate timeIntervalSince1970];
    long long currentTimestamp = [[NSNumber numberWithDouble:interval] longLongValue];
    
    [self.conversationModel.emModel loadMessagesWithKeyword:aString timestamp:0 count:50 fromUser:nil searchDirection:EMMessageSearchDirectionDown completion:^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count] > 0) {
            __weak typeof(self) weakself = self;
            dispatch_async(self.msgQueue, ^{
                NSMutableArray *msgArray = [[NSMutableArray alloc] init];
                for (int i = 0; i < [aMessages count]; i++) {
                    EMMessage *msg = aMessages[i];
                    [msgArray addObject:msg];
                }
                NSArray *formated = [weakself _formatMessages:msgArray];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.searchResults removeAllObjects];
                    [weakself.searchResults addObjectsFromArray:formated];
                    [weakself.searchResultTableView reloadData];
                });
            });
        }
    }];
}

#pragma mark - Data

- (NSArray *)_formatMessages:(NSArray<EMMessage *> *)aMessages
{
    NSMutableArray *formated = [[NSMutableArray alloc] init];
    NSString *timeStr;
    for (int i = 0; i < [aMessages count]; i++) {
        EMMessage *msg = aMessages[i];
        CGFloat interval = (self.msgTimelTag - msg.timestamp) / 1000;
        if (self.msgTimelTag < 0 || interval > 60 || interval < -60) {
            timeStr = [EMDateHelper formattedTimeFromTimeInterval:msg.timestamp];
            self.msgTimelTag = msg.timestamp;
        }
        EMAvatarNameModel *model = [[EMAvatarNameModel alloc]initWithInfo:_keyWord img:[UIImage imageNamed:@"defaultAvatar"] msg:msg time:timeStr];
        [formated addObject:model];
    }
    
    return formated;
}

@end
