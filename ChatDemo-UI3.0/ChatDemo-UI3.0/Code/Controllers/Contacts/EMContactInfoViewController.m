//
//  EMContactInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/28.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMContactInfoViewController.h"
#import "UIImage+ImageEffect.h"
#import "EMUserModel.h"
#import "EMContactInfoCell.h"
#import "EMChatDemoHelper.h"
#import "EMChatViewController.h"

#define NAME                NSLocalizedString(@"contact.name", @"Name")
#define HYPHENATE_ID        NSLocalizedString(@"contact.hyphenateId", @"Hyphenate ID")
#define APNS_NICKNAME       NSLocalizedString(@"contact.apnsnickname", @"iOS APNS")
#define DELETE_CONTACT      NSLocalizedString(@"contact.delete", @"Delete Contact")



@interface EMContactInfoViewController ()<UIActionSheetDelegate, EMContactsUIProtocol>

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImage;
@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (strong, nonatomic) EMUserModel *model;

@end

@implementation EMContactInfoViewController
{
    NSArray *_contactInfo;
    NSArray *_contactFunc;
}

- (instancetype)initWithUserModel:(EMUserModel *)model {
    self = [super initWithNibName:@"EMContactInfoViewController" bundle:nil];
    if (self) {
        _model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableHeaderView = _headerView;
    self.tableView.tableFooterView = [UIView new];
    _nicknameLabel.text = _model.nickname;
    _avatarImage.image = _model.defaultAvatarImage;
    if (_model.avatarURLPath.length > 0) {
        NSURL *avatarUrl = [NSURL URLWithString:_model.avatarURLPath];
        [_avatarImage sd_setImageWithURL:avatarUrl placeholderImage:_model.defaultAvatarImage];
    }
    
    [self loadContactInfo];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)loadContactInfo {
    NSMutableArray *info = [NSMutableArray array];
    [info addObjectsFromArray:@[@{NAME:_model.nickname}, @{HYPHENATE_ID:_model.hyphenateId}]];
    if ([_model.hyphenateId isEqualToString:[EMClient sharedClient].currentUsername]) {
        NSString *displayName = [EMClient sharedClient].pushOptions.displayName;
        if (displayName.length > 0) {
            [info addObject:@{APNS_NICKNAME:displayName}];
        }
    }
    _contactInfo = [NSArray arrayWithArray:info];
    _contactFunc = @[@{DELETE_CONTACT:RGBACOLOR(255.0, 59.0, 48.0, 1.0)}];
}

- (void)makeCallWithContact:(NSString *)contact callTyfpe:(EMCallType)callType {
    if (contact.length == 0) {
        return;
    }
    if (callType == EMCallTypeVoice) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":contact, @"type":[NSNumber numberWithInt:0]}];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":contact, @"type":[NSNumber numberWithInt:1]}];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)chatAction:(id)sender {
    EMChatViewController *chatViewController = [[EMChatViewController alloc] initWithConversationId:_model.hyphenateId conversationType:EMConversationTypeChat];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (IBAction)callVoiceAction:(id)sender {
    [self makeCallWithContact:_model.hyphenateId callTyfpe:EMCallTypeVoice];
}

- (IBAction)callVideoAction:(id)sender {
    [self makeCallWithContact:_model.hyphenateId callTyfpe:EMCallTypeVideo];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y = 0;
        [scrollView setContentOffset:contentOffset];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _contactInfo.count;
    }
    return _contactFunc.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMContactInfoCell *cell = nil;
    if (indexPath.section == 0) {
        NSString *cellIdentify = @"EMContact_Info_Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"EMContactInfoCell" owner:self options:nil] lastObject];
        }
        cell.infoDic = _contactInfo[indexPath.row];
    }
    else {
        NSString *cellIdentify = @"EMContact_Info_func_Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"EMContactInfo_funcCell" owner:self options:nil] lastObject];
        }
        cell.hyphenateId = _model.hyphenateId;
        cell.infoDic = _contactFunc[indexPath.row];
        cell.delegate = self;
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"common.cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"common.delete", @"Delete") otherButtonTitles:nil, nil];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    UIView *sectionHeader = [[UIView alloc] init];
    sectionHeader.backgroundColor = tableView.backgroundColor;
    return sectionHeader;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        WEAK_SELF
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[EMClient sharedClient].contactManager deleteContact:_model.hyphenateId completion:^(NSString *aUsername, EMError *aError) {
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            if (!aError) {
                [[EMChatDemoHelper shareHelper].contactsVC reloadContacts];
                [[EMClient sharedClient].chatManager deleteConversation:_model.hyphenateId isDeleteMessages:YES completion:nil];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                [weakSelf showAlertWithMessage:NSLocalizedString(@"contact.deleteFailure", @"Delete contacts failed")];
            }
        }];
    }
}

#pragma mark - EMContactsUIProtocol
- (void)needRefreshContactsFromServer:(BOOL)isNeedRefresh {
    if (isNeedRefresh) {
        [[EMChatDemoHelper shareHelper].contactsVC loadContactsFromServer];
    }
    else {
        [[EMChatDemoHelper shareHelper].contactsVC reloadContacts];
    }
}

@end


