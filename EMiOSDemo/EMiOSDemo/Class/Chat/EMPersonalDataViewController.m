//
//  EMFriendProfileViewController.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/12/10.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMPersonalDataViewController.h"
#import "EMAvatarNameCell.h"
#import "EMChatViewController.h"

@interface EMPersonalDataViewController ()

@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSArray *contacts;

@property (nonatomic, strong) NSString *hint;
@property (nonatomic, strong) UIView *blackListView;
@property (nonatomic, strong) EMChatViewController *chatController;
@property (nonatomic) BOOL isChatting;
@end


@implementation EMPersonalDataViewController

- (instancetype)initWithNickName:(NSString *)aNickName
{
    self = [super init];
    if (self) {
        _nickName = aNickName;
        _contacts = [[EMClient sharedClient].contactManager getContacts];
        _hint = @"添加联系人";
    }
    return self;
}

- (instancetype)initWithNickName:(NSString *)aNickName isChatting:(BOOL)isChatting;
{
    self = [super init];
    if (self) {
        _nickName = aNickName;
        _contacts = [[EMClient sharedClient].contactManager getContacts];
        _isChatting = isChatting;
        _hint = @"添加联系人";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showRefreshHeader = NO;
    [self _setupSubviews];
    // Do any additional setup after loading the view.
}

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"个人资料";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    if ([self.contacts containsObject:self.nickName]) {
        [self _setupNavigationBarRightItem];
    }

    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        if ([self.contacts containsObject:self.nickName]) {
            make.height.equalTo(@340);
        } else {
            make.height.equalTo(@130);
        }
    }];
    
    self.blackListView = [[UIView alloc]init];
    self.blackListView.backgroundColor = [UIColor blackColor];
    self.blackListView.alpha = 0.6;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelView:)];
    [self.blackListView addGestureRecognizer:tap];
    [self.view addSubview:self.blackListView];
    [self.blackListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self.view);
    }];
    UIButton *blackListBtn = [[UIButton alloc]init];
    blackListBtn.alpha = 1.0;
    [blackListBtn addTarget:self action:@selector(addContactToBlackList) forControlEvents:UIControlEventTouchUpInside];
    [blackListBtn setTitle:@"加入黑名单" forState:UIControlStateNormal];
    blackListBtn.layer.cornerRadius = 8;
    [blackListBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [blackListBtn setBackgroundColor:[UIColor whiteColor]];
    [blackListBtn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [self.blackListView addSubview:blackListBtn];
    [blackListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(2);
        make.right.equalTo(self.view).offset(-16);
        make.width.equalTo(@120);
        make.height.equalTo(@50);
    }];
    [self.view addSubview:self.blackListView];
    self.blackListView.hidden = YES;
}

- (void)_setupNavigationBarRightItem
{
    UIImage *image = [[UIImage imageNamed:@"icon-setting"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(addBlackListView)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.contacts containsObject:self.nickName]) {
        return 6;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = @"UITableViewCellValue1";

    if (section == 0 && row == 0) {
        EMAvatarNameCell *cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMAvatarNameCell"];
        cell.avatarView.image = [UIImage imageNamed:@"user_avatar_blue"];
        cell.nameLabel.text = self.nickName;
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (section == 1 && row == 0) {
        if ([self.contacts containsObject:self.nickName]) {
            cell.textLabel.text = @"";
        } else {
            cell.textLabel.text = self.hint;
        }
    } else if (section == 2 && row == 0) {
        cell.textLabel.text = @"发起聊天";
    } else if (section == 3 && row == 0) {
        cell.textLabel.text = @"语音通话";
    } else if (section == 4 && row == 0) {
        cell.textLabel.text = @"视频通话";
    } else if (section == 5 && row == 0) {
        cell.textLabel.text = @"删除聊天记录";
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:18.0];
    cell.textLabel.textColor = [UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0];

    [cell.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(cell.contentView);
        make.centerY.equalTo(cell.contentView);
    }];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    }
    if (indexPath.section == 1 && [self.contacts containsObject:self.nickName]) {
        return 0;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || (section == 1 && [self.contacts containsObject:self.nickName])) {
        return 0.001;
    }
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    self.chatController = [[EMChatViewController alloc]initWithConversationId:self.nickName type:EMConversationTypeChat createIfNotExist:YES isChatRecord:NO];
    if (section == 1) {
        //添加联系人
        [self addContact];
    } else if (section == 2) {
        //聊天
        if (self.isChatting) {
            [self.navigationController popViewControllerAnimated:NO];
        } else {
            [self.navigationController pushViewController:self.chatController animated:NO];
        }
    } else if (section == 3) {
        //语音通话
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:self.nickName, CALL_TYPE:@(EMCallTypeVoice)}];
        if (!self.isChatting) {
            [[NSNotificationCenter defaultCenter] addObserver:self.chatController selector:@selector(sendCallEndMsg:) name:EMCOMMMUNICATE object:nil];
        }
    } else if (section == 4) {
        //视频通话
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:self.nickName, CALL_TYPE:@(EMCallTypeVideo)}];
        if (!self.isChatting) {
            [[NSNotificationCenter defaultCenter] addObserver:self.chatController selector:@selector(sendCallEndMsg:) name:EMCOMMMUNICATE object:nil];
        }
    } else if (section == 5) {
        //清除聊天记录
        //[self deleteChatRecord];
    }
}

//黑名单view
- (void)addBlackListView
{
    self.blackListView.hidden = NO;
}
#pragma mark - Action
- (void)cancelView:(UITapGestureRecognizer *)aTap
{
    self.blackListView.hidden = YES;
}
//添加黑名单
- (void)addContactToBlackList
{
    [self showHudInView:self.view hint:@"拉黑用户..."];
        __weak typeof(self) weakself = self;
        [[EMClient sharedClient].contactManager addUserToBlackList:weakself.nickName completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"拉黑用户失败"];
        } else {
            [EMAlertController showSuccessAlert:@"拉黑用户成功"];
        }
        self.blackListView.hidden = YES;
    }];
}

//添加联系人
- (void)addContact
{
    [self showHudInView:self.view hint:@"发送好友请求..."];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager addContact:self.nickName message:nil completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"添加失败"];
        } else {
            self.hint = @"已申请";
            [self.tableView reloadData];
            [EMAlertController showSuccessAlert:@"已发出好友申请"];
        }
    }];
}

//清除聊天记录
- (void)deleteChatRecord
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.nickName type:EMChatTypeChat createIfNotExist:NO];
    EMError *error = nil;
    [conversation deleteAllMessages:&error];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.chatController];
}

@end
