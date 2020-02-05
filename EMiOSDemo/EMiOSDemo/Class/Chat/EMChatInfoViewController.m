//
//  EMChatInfoViewController.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2020/2/4.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatInfoViewController.h"
#import "EMPersonalDataViewController.h"
#import "EMChatViewController.h"

@interface EMChatInfoViewController ()

@property (nonatomic, strong) UITableViewCell *clearChatRecordCell;
@property (nonatomic, strong) EMConversationModel *conversationModel;

@end

@implementation EMChatInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupSubviews];
    
    self.showRefreshHeader = YES;
}

- (instancetype)initWithCoversation:(EMConversationModel *)aConversationModel
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

    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.clearChatRecordCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellStyleDefaultBlueFont"];
    UIButton *clearBtn = [[UIButton alloc]init];
    clearBtn.layer.cornerRadius = 10;
    [clearBtn setBackgroundColor:[UIColor blueColor]];
    [clearBtn setTitle:@"清除聊天记录" forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(_clearChatRecordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.clearChatRecordCell.contentView addSubview:clearBtn];
    [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.clearChatRecordCell.contentView).offset(2);
        make.bottom.equalTo(self.clearChatRecordCell.contentView).offset(-2);
        make.left.equalTo(self.clearChatRecordCell).offset(30);
        make.right.equalTo(self.clearChatRecordCell).offset(-30);
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 1;
    if (section == 2) {
        count = 2;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = @"UITableViewCellValue1";
    if (section == 0) {
        cellIdentifier = @"UITableViewCellStyleSubtitle";
    }
    
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
    } else if (isSwitchCell) {
        switchControl = [cell.contentView viewWithTag:[self _tagWithIndexPath:indexPath]];
    }
    
    if (section == 3) {
        return self.clearChatRecordCell;
    }
    
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (section == 0) {
        if (row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"group_avatar"];
            cell.textLabel.font = [UIFont systemFontOfSize:18.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
            cell.textLabel.text = self.conversationModel.emModel.conversationId;
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"查找聊天记录";
            cell.detailTextLabel.text = @"";
        }
    } else if (section == 2) {
        if (row == 0) {
            cell.textLabel.text = @"消息免打扰";
            [switchControl setOn:NO animated:NO];
        } else if (row == 1) {
            cell.textLabel.text = @"会话置顶";
            [switchControl setOn:([self.conversationModel.emModel.ext objectForKey:CONVERSATION_STICK] && ![(NSNumber *)[self.conversationModel.emModel.ext objectForKey:CONVERSATION_STICK] isEqualToNumber:[NSNumber numberWithLong:0]]) animated:NO];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2) {
        return 50;
    }
    
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section == 0) {
        return 0.001;
    }
    
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 4) {
        return 40;
    }
    
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            //好友资料
            EMPersonalDataViewController *controller = [[EMPersonalDataViewController alloc]initWithNickName:self.conversationModel.emModel.conversationId];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (section == 1) {
        if (row == 0) {
            //查找聊天记录
            EMChatViewController *controller = [[EMChatViewController alloc]initWithConversationId:self.conversationModel.emModel.conversationId type:EMConversationTypeChat createIfNotExist:NO isChatRecord:YES];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

//cell开关
- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    NSIndexPath *indexPath = [self _indexPathWithTag:aSwitch.tag];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 2) {
        if (row == 0) {
            //免打扰
        } else if (row == 1) {
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

//清除聊天记录
- (void)_clearChatRecordAction
{
    EMError *error = nil;
    [self.conversationModel.emModel deleteAllMessages:&error];
    [self showAlertWithMessage:@"已删除 !"];
    self.clearRecordCompletion(self.conversationModel);
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

//string To dictonary
- (NSMutableDictionary *)changeStringToDictionary:(NSString *)string{

    if (string) {
        NSMutableDictionary *returnDic = [[NSMutableDictionary  alloc]  init];
        returnDic = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        return returnDic;
    }
    return nil;
}

@end
