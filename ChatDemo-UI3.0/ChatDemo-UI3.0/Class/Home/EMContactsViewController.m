//
//  EMContactsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/9.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMContactsViewController.h"

#import "Masonry.h"

@interface EMContactsViewController ()

@property (strong, nonatomic) NSMutableArray *sectionTitles;

@end

@implementation EMContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sectionTitles = [[NSMutableArray alloc] init];
    
    [self _setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"联系人";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:28];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(self.view).offset(20);
        make.height.equalTo(@60);
    }];
    
    UIButton *searchButton = [[UIButton alloc] init];
    searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    searchButton.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0];
    searchButton.titleLabel.font = [UIFont systemFontOfSize:15];
    searchButton.layer.cornerRadius = 8;
    searchButton.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    searchButton.titleEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    [searchButton setTitle:@"搜索" forState:UIControlStateNormal];
    [searchButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"search_gray"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchButton];
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@35);
    }];
    
    self.tableView.rowHeight = 50;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchButton.mas_bottom).offset(15);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.dataArray count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 5;
    }
    
    return [[self.dataArray objectAtIndex:(section - 2)] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        NSString *CellIdentifier = @"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if (row == 0) {
            cell.imageView.image = [UIImage imageNamed:@""];
            cell.textLabel.text = @"添加好友";
        } else if (row == 1) {
            cell.imageView.image = [UIImage imageNamed:@""];
            cell.textLabel.text = @"申请通知";
        } else if (row == 2) {
            cell.imageView.image = [UIImage imageNamed:@""];
            cell.textLabel.text = @"群组";
        } else if (row == 3) {
            cell.imageView.image = [UIImage imageNamed:@""];
            cell.textLabel.text = @"聊天室";
        } else if (row == 4) {
            cell.imageView.image = [UIImage imageNamed:@""];
            cell.textLabel.text = @"多人视频";
        }
        
        return cell;
    }
//    if (indexPath.section == 0) {
//        if (indexPath.row == 0) {
//            NSString *CellIdentifier = @"addFriend";
//            EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            if (cell == nil) {
//                cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//            }
//            cell.avatarView.image = [UIImage imageNamed:@"newFriends"];
//            cell.titleLabel.text = NSLocalizedString(@"title.apply", @"Application and notification");
//            cell.avatarView.badge = self.unapplyCount;
//            return cell;
//        }
//
//        NSString *CellIdentifier = @"commonCell";
//        EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
//
//        if (indexPath.row == 1) {
//            cell.avatarView.image = [UIImage imageNamed:@"EaseUIResource.bundle/group"];
//            cell.titleLabel.text = NSLocalizedString(@"title.group", @"Group");
//        }
//        else if (indexPath.row == 2) {
//            cell.avatarView.image = [UIImage imageNamed:@"EaseUIResource.bundle/group"];
//            cell.titleLabel.text = NSLocalizedString(@"title.chatroom",@"chatroom");
//        }
//        else if (indexPath.row == 3) {
//            cell.avatarView.image = [UIImage imageNamed:@"EaseUIResource.bundle/chatBar_colorMore_videoCall"];
//            cell.titleLabel.text = NSLocalizedString(@"title.conference",@"Mutil Conference");
//        }
//        else if (indexPath.row == 4) {
//            cell.avatarView.image = [UIImage imageNamed:@"EaseUIResource.bundle/chatBar_colorMore_videoCall"];
//            cell.titleLabel.text = NSLocalizedString(@"title.customConference",@"Custom Video Conference");
//        }
//
//        return cell;
//    } else if (indexPath.section == 1) {
//        NSString *CellIdentifier = @"OtherPlatformIdCell";
//        EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//
//        // Configure the cell...
//        if (cell == nil) {
//            cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
//        cell.titleLabel.text = [self.otherPlatformIds objectAtIndex:indexPath.row];
//
//        return cell;
//
//    } else {
//        NSString *CellIdentifier = [EaseUserCell cellIdentifierWithModel:nil];
//        EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//
//        // Configure the cell...
//        if (cell == nil) {
//            cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
//
//        NSArray *userSection = [self.dataArray objectAtIndex:(indexPath.section - 2)];
//        EaseUserModel *model = [userSection objectAtIndex:indexPath.row];
//        UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:model.buddy];
//        if (profileEntity) {
//            model.avatarURLPath = profileEntity.imageUrl;
//            model.nickname = profileEntity.nickname == nil ? profileEntity.username : profileEntity.nickname;
//        }
//        cell.indexPath = indexPath;
//        cell.delegate = self;
//        cell.model = model;
//
//        return cell;
//    }
    
    return nil;
}

#pragma mark - Table view delegate

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionTitles;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else {
        return 20;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    
    UIView *contentView = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    label.backgroundColor = [UIColor clearColor];
    [label setText:[self.sectionTitles objectAtIndex:(section - 2)]];
    [contentView addSubview:label];
    
    return contentView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
//    if (section == 0) {
//        if (row == 0) {
//            [self.navigationController pushViewController:[ApplyViewController shareController] animated:YES];
//        }
//        else if (row == 1)
//        {
//            GroupListViewController *groupController = [[GroupListViewController alloc] initWithStyle:UITableViewStylePlain];
//            [self.navigationController pushViewController:groupController animated:YES];
//        }
//        else if (row == 2)
//        {
//            ChatroomListViewController *controller = [[ChatroomListViewController alloc] initWithStyle:UITableViewStylePlain];
//            [self.navigationController pushViewController:controller animated:YES];
//        }
//
//#if DEMO_CALL == 1
//        else if (row == 3) {
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"会议类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//
//            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"普通会议" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [[DemoConfManager sharedManager] inviteMemberWithConfType:EMConferenceTypeCommunication inviteType:ConfInviteTypeUser conversationId:nil chatType:EMChatTypeChat];
//            }];
//            [alertController addAction:defaultAction];
//
//            UIAlertAction *mixAction = [UIAlertAction actionWithTitle:@"混音会议" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [[DemoConfManager sharedManager] inviteMemberWithConfType:EMConferenceTypeLargeCommunication inviteType:ConfInviteTypeUser conversationId:nil chatType:EMChatTypeChat];
//            }];
//            [alertController addAction:mixAction];
//
//            [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];
//
//            [self presentViewController:alertController animated:YES completion:nil];
//        }
//        else if (row == 4) {
//            //TODO: custom call
//        }
//#endif
//    } else if (section == 1) {
//        ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:[self.otherPlatformIds objectAtIndex:indexPath.row] conversationType:EMConversationTypeChat];
//        [self.navigationController pushViewController:chatController animated:YES];
//    }
//    else{
//        EaseUserModel *model = [[self.dataArray objectAtIndex:(section - 2)] objectAtIndex:row];
//        UIViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:model.buddy conversationType:EMConversationTypeChat];
//        chatController.title = model.nickname.length > 0 ? model.nickname : model.buddy;
//        [self.navigationController pushViewController:chatController animated:YES];
//    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //在iOS8.0上，必须加上这个方法才能出发左划操作
}

//- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [self setupCellEditActions:indexPath];
//}
//
//- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [self setupCellEditActions:indexPath];
//}


#pragma mark - Action

- (void)searchButtonAction
{
    
}

@end
