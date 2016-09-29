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
#import "EMColorUtils.h"
#import "EMContactInfoCell.h"

#define NAME                NSLocalizedString(@"contact.name", @"Name")
#define HYPHENATE_ID        NSLocalizedString(@"contact.hyphenateId", @"Hyphenate ID")
#define APNS_NICKNAME       NSLocalizedString(@"contact.apnsnickname", @"iOS APNS")
#define BLOCK_CONTACT       NSLocalizedString(@"contact.block", @"Block Contact")
#define DELETE_CONTACT      NSLocalizedString(@"contact.delete", @"Delete Contact")



@interface EMContactInfoViewController ()<UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIView *headerView;
//头像
@property (strong, nonatomic) IBOutlet UIImageView *avatarImage;
//昵称
@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (strong, nonatomic) EMUserModel *model;

@end

@implementation EMContactInfoViewController
{
    //用于保存nav一些属性
    UIImage *_navShadowImage;
    UIImage *_navBarBgImage;
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
    [self.navigationController.navigationBar setHidden:YES];
    _nicknameLabel.text = _model.nickname;
    _avatarImage.image = _model.defaultAvatarImage;
    if (_model.avatarURLPath.length > 0) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:_model.avatarURLPath]];
        _avatarImage.image = [UIImage imageWithData:data];
    }
    
    [self loadContactInfo];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
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
    
    _contactFunc = @[@{BLOCK_CONTACT:[UIColor colorWithRed:12.0/255.0 green:18.0/255.0 blue:24.0/255.0 alpha:1.0]},@{DELETE_CONTACT:[UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0]}];
    
}

- (void)makeCallWithContact:(NSString *)contact callTyfpe:(EMCallType)callType {
    if (contact.length == 0) {
        return;
    }
    if (callType == EMCallTypeVoice) {
        [[EMClient sharedClient].callManager startVoiceCall:contact completion:^(EMCallSession *aCallSession, EMError *aError) {
            //页面跳转
        }];
    }
    else {
        [[EMClient sharedClient].callManager startVideoCall:contact completion:^(EMCallSession *aCallSession, EMError *aError) {
            //页面跳转
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

//返回
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


//点击开始聊天
- (IBAction)chatAction:(id)sender {
    
}

//点击开始实时语音
- (IBAction)callVoiceAction:(id)sender {
    [self makeCallWithContact:@"" callTyfpe:EMCallTypeVoice];
}

//点击开始实时视频
- (IBAction)callVideoAction:(id)sender {
    [self makeCallWithContact:@"" callTyfpe:EMCallTypeVideo];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //table滑到顶端，不能再下拉
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.infoDic = _contactInfo[indexPath.row];
    }
    else {
        NSString *cellIdentify = @"EMContact_Info_func_Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"EMContactInfo_funcCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.hyphenateId = _model.hyphenateId;
        cell.infoDic = _contactFunc[indexPath.row];
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 1) {
        //删除联系人
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
        EMError *error = [[EMClient sharedClient].contactManager deleteContact:_model.hyphenateId];
        if (!error) {
            [[EMClient sharedClient].chatManager deleteConversation:_model.hyphenateId isDeleteMessages:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            //删除联系人失败
        }
    }
}

@end


