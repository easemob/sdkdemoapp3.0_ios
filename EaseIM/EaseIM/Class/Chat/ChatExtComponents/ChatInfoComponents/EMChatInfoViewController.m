//
//  EMChatInfoViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/2/4.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatInfoViewController.h"
#import "EMPersonalDataViewController.h"
#import "EMChatRecordViewController.h"

@interface EMChatInfoViewController ()

@property (nonatomic, strong) UITableViewCell *clearChatRecordCell;
@property (nonatomic, strong) EMConversationModel *conversationModel;

@end

@implementation EMChatInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupSubviews];
    
    self.showRefreshHeader = NO;
}

- (instancetype)initWithCoversationModel:(EMConversationModel *)aConversationModel
{
    self = [super init];
    if (self) {
        _conversationModel = aConversationModel;
    }
    
    return self;
}

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"聊天详情";

    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSString *cellIdentifier = @"UITableViewCellValue1";
    if (section == 0)
        cellIdentifier = @"UITableViewCellStyleSubtitle";
    
    UISwitch *switchControl = nil;
    BOOL isSwitchCell = NO;
    if (section == 2) {
        isSwitchCell = YES;
        cellIdentifier = @"UITableViewCellSwitch";
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        if (section == 0) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (isSwitchCell) {
            switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
            switchControl.tag = [self _tagWithIndexPath:indexPath];
            [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchControl];
        }
    }
    
    if (isSwitchCell)
        switchControl = [cell.contentView viewWithTag:[self _tagWithIndexPath:indexPath]];
    
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (section == 0) {
        cell.imageView.image = [UIImage imageNamed:self.conversationModel.emModel.type == EMConversationTypeChat ? @"defaultAvatar" : @"groupConversation"];
        cell.textLabel.font = [UIFont systemFontOfSize:18.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.textLabel.text = self.conversationModel.emModel.conversationId;
    }
    if (section == 1)
        cell.textLabel.text = @"查找聊天记录";
    if (section == 2) {
        cell.textLabel.text = @"会话置顶";
        [switchControl setOn:([self.conversationModel.emModel.ext objectForKey:CONVERSATION_STICK] && ![(NSNumber *)[self.conversationModel.emModel.ext objectForKey:CONVERSATION_STICK] isEqualToNumber:[NSNumber numberWithLong:0]]) animated:NO];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (section == 3)
        cell.textLabel.text = @"清空聊天记录";
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2)
        return 60;
    
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0.001;
    
    return 24.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 4)
        return 40;
    
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        //好友资料
        EMPersonalDataViewController *controller = [[EMPersonalDataViewController alloc]initWithNickName:self.conversationModel.emModel.conversationId];
        [self.navigationController pushViewController:controller animated:NO];
        return;
    }
    if (section == 1) {
        //查找聊天记录
        EMChatRecordViewController *chatRrcordController = [[EMChatRecordViewController alloc]initWithCoversationModel:self.conversationModel];
        //EMChatViewController *controller = [[EMChatViewController alloc]initWithConversationId:self.conversationModel.emModel.conversationId type:EMConversationTypeChat createIfNotExist:NO isChatRecord:YES];
        [self.navigationController pushViewController:chatRrcordController animated:NO];
        return;
    }
    if (section == 3) {
        //清空聊天记录
        [self deleteChatRecord];
        return;
    }
}

//清除聊天记录
- (void)deleteChatRecord
{
    __weak typeof(self) weakself = self;
    //UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"确定删除和%@的聊天记录吗？",self.conversationModel.emModel.conversationId] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"您确认要清空所有聊天记录吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:@"清空" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.conversationModel.emModel.conversationId type:EMConversationTypeChat createIfNotExist:NO];
        EMError *error = nil;
        [conversation deleteAllMessages:&error];
        if (weakself.clearRecordCompletion) {
            if (!error) {
                [EMAlertController showSuccessAlert:@"聊天记录已清空！"];
                weakself.clearRecordCompletion(YES);
            } else {
                [EMAlertController showErrorAlert:@"清空聊天记录失败！"];
                weakself.clearRecordCompletion(NO);
            }
        }
    }];
    [clearAction setValue:[UIColor colorWithRed:245/255.0 green:52/255.0 blue:41/255.0 alpha:1.0] forKey:@"_titleTextColor"];
    [alertController addAction:clearAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [cancelAction  setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    [alertController addAction:cancelAction];
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}

//cell开关
- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    NSIndexPath *indexPath = [self _indexPathWithTag:aSwitch.tag];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 2) {
        if (row == 0) {
            //置顶
            NSMutableDictionary *ext = [[NSMutableDictionary alloc]initWithDictionary:self.conversationModel.emModel.ext];
            NSDate *date = [NSDate date];
            NSDateFormatter *format=[[NSDateFormatter alloc]init];
            [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *time = [format dateFromString:[format stringFromDate:date]];
            NSTimeInterval stickTimeInterval = [time timeIntervalSince1970];
            NSNumber *stickTime = [NSNumber numberWithLong:stickTimeInterval];
            if (aSwitch.isOn) {
                [ext setObject:stickTime forKey:CONVERSATION_STICK];
            } else {
                [ext setObject:[NSNumber numberWithLong:0] forKey:CONVERSATION_STICK];
            }
            [self.conversationModel.emModel setExt:ext];
        }
    }
}

#pragma mark - Private

- (NSInteger)_tagWithIndexPath:(NSIndexPath *)aIndexPath
{
    NSInteger tag = aIndexPath.section * 10 + aIndexPath.row;
    return tag;
}

- (NSIndexPath *)_indexPathWithTag:(NSInteger)aTag
{
    NSInteger section = aTag / 10;
    NSInteger row = aTag % 10;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return indexPath;
}

@end
