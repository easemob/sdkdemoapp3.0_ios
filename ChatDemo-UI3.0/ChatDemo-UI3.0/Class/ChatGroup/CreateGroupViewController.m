/************************************************************
  *  * Hyphenate CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2016 Hyphenate Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of Hyphenate Inc.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from Hyphenate Inc.
  */

#import "CreateGroupViewController.h"

#import "ContactSelectionViewController.h"
#import "EMTextView.h"

@interface CreateGroupViewController ()<UITextFieldDelegate, UITextViewDelegate, EMChooseViewDelegate>

@property (strong, nonatomic) UIView *switchView;
@property (strong, nonatomic) UIBarButtonItem *rightItem;
@property (strong, nonatomic) UITextField *groupNameTextField;
@property (strong, nonatomic) EMTextView *groupDescriptionTextView;

@property (nonatomic) BOOL isPublic;
@property (strong, nonatomic) UILabel *groupTypeLabel;

@property (nonatomic) BOOL isMemberOn;
@property (strong, nonatomic) UILabel *groupInvitePermissionLabel;
@property (strong, nonatomic) UISwitch *groupMemberSwitch;
@property (strong, nonatomic) UILabel *groupMemberLabel;

@end

@implementation CreateGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isPublic = NO;
        _isMemberOn = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    self.title = NSLocalizedString(@"title.createGroup", @"Create a group");
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    addButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [addButton setTitle:NSLocalizedString(@"group.create.addOccupant", @"Add member") forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(addContacts:) forControlEvents:UIControlEventTouchUpInside];
    _rightItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    [self.navigationItem setRightBarButtonItem:_rightItem];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    [self.view addSubview:self.groupNameTextField];
    [self.view addSubview:self.groupDescriptionTextView];
    [self.view addSubview:self.switchView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UITextField *)groupNameTextField
{
    if (_groupNameTextField == nil) {
        _groupNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 40)];
        _groupNameTextField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _groupNameTextField.layer.borderWidth = 0.5;
        _groupNameTextField.layer.cornerRadius = 3;
        _groupNameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
        _groupNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _groupNameTextField.leftViewMode = UITextFieldViewModeAlways;
        _groupNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _groupNameTextField.font = [UIFont systemFontOfSize:15.0];
        _groupNameTextField.backgroundColor = [UIColor whiteColor];
        _groupNameTextField.placeholder = NSLocalizedString(@"group.create.inputName", @"please enter the group name");
        _groupNameTextField.returnKeyType = UIReturnKeyDone;
        _groupNameTextField.delegate = self;
    }
    
    return _groupNameTextField;
}

- (EMTextView *)groupDescriptionTextView
{
    if (_groupDescriptionTextView == nil) {
        _groupDescriptionTextView = [[EMTextView alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 80)];
        _groupDescriptionTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _groupDescriptionTextView.layer.borderWidth = 0.5;
        _groupDescriptionTextView.layer.cornerRadius = 3;
        _groupDescriptionTextView.font = [UIFont systemFontOfSize:14.0];
        _groupDescriptionTextView.backgroundColor = [UIColor whiteColor];
        _groupDescriptionTextView.placeholder = NSLocalizedString(@"group.create.inputDescribe", @"please enter a group description");
        _groupDescriptionTextView.returnKeyType = UIReturnKeyDone;
        _groupDescriptionTextView.delegate = self;
    }
    
    return _groupDescriptionTextView;
}

- (UIView *)switchView
{
    if (_switchView == nil) {
        
        _switchView = [[UIView alloc] initWithFrame:CGRectMake(10, 160, 300, 90)];
        _switchView.backgroundColor = [UIColor clearColor];
        
        // Group Permission
        CGFloat yAlignment = 0;
        UILabel *groupTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yAlignment, 120, 35)];
        groupTypeLabel.backgroundColor = [UIColor clearColor];
        groupTypeLabel.font = [UIFont systemFontOfSize:14.0];
        groupTypeLabel.numberOfLines = 2;
        groupTypeLabel.text = NSLocalizedString(@"group.create.groupPermission", @"group permission");
        [_switchView addSubview:groupTypeLabel];
        
        UISwitch *groupTypeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(groupTypeLabel.frame.size.width + 10, yAlignment, 50, _switchView.frame.size.height)];
        [groupTypeSwitch addTarget:self action:@selector(groupTypeChange:) forControlEvents:UIControlEventValueChanged];
        [_switchView addSubview:groupTypeSwitch];
        
        _groupTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(groupTypeSwitch.frame.origin.x + groupTypeSwitch.frame.size.width + 10, yAlignment, 100, 35)];
        _groupTypeLabel.backgroundColor = [UIColor clearColor];
        _groupTypeLabel.font = [UIFont systemFontOfSize:12.0];
        _groupTypeLabel.textColor = [UIColor grayColor];
        _groupTypeLabel.text = NSLocalizedString(@"group.create.private", @"private group");
        _groupTypeLabel.numberOfLines = 2;
        [_switchView addSubview:_groupTypeLabel];
        
        // Group invite permission
        yAlignment += (35 + 20);
        self.groupInvitePermissionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yAlignment, 120, 35)];
        self.groupInvitePermissionLabel.font = [UIFont systemFontOfSize:14.0];
        self.groupInvitePermissionLabel.backgroundColor = [UIColor clearColor];
        self.groupInvitePermissionLabel.text = NSLocalizedString(@"group.create.occupantPermissions", @"members invite permissions");
        self.groupInvitePermissionLabel.numberOfLines = 2;
        [_switchView addSubview:_groupInvitePermissionLabel];
        
        _groupMemberSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.groupInvitePermissionLabel.frame.size.width + 10, yAlignment, 50, 35)];
        [_groupMemberSwitch addTarget:self action:@selector(groupMemberChange:) forControlEvents:UIControlEventValueChanged];
        [_switchView addSubview:_groupMemberSwitch];
        
        _groupMemberLabel = [[UILabel alloc] initWithFrame:CGRectMake(_groupMemberSwitch.frame.origin.x + _groupMemberSwitch.frame.size.width + 10, yAlignment, 150, 35)];
        _groupMemberLabel.backgroundColor = [UIColor clearColor];
        _groupMemberLabel.font = [UIFont systemFontOfSize:12.0];
        _groupMemberLabel.textColor = [UIColor grayColor];
        _groupMemberLabel.numberOfLines = 2;
        _groupMemberLabel.text = NSLocalizedString(@"group.create.unallowedOccupantInvite", @"don't allow group members to invite others");
        [_switchView addSubview:_groupMemberLabel];
    }
    
    return _switchView;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - EMChooseViewDelegate

- (BOOL)viewController:(EMChooseViewController *)viewController didFinishSelectedSources:(NSArray *)selectedSources
{
    NSInteger maxUsersCount = 200;
    if ([selectedSources count] > (maxUsersCount - 1)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.maxUserCount", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
        
        return NO;
    }
    
    [self showHudInView:self.view hint:NSLocalizedString(@"group.create.ongoing", @"create a group...")];
    
    NSMutableArray *source = [NSMutableArray array];
    for (NSString *username in selectedSources) {
        [source addObject:username];
    }
    
    EMGroupOptions *setting = [[EMGroupOptions alloc] init];
    setting.maxUsersCount = maxUsersCount;
    
    if (_isPublic) {
        if(_isMemberOn)
        {
            setting.style = EMGroupStylePublicOpenJoin;
        }
        else{
            setting.style = EMGroupStylePublicJoinNeedApproval;
        }
    }
    else{
        if(_isMemberOn)
        {
            setting.style = EMGroupStylePrivateMemberCanInvite;
        }
        else{
            setting.style = EMGroupStylePrivateOnlyOwnerInvite;
        }
    }
    
    __weak CreateGroupViewController *weakSelf = self;
    NSString *username = [[EMClient sharedClient] currentUsername];
    NSString *messageStr = [NSString stringWithFormat:NSLocalizedString(@"group.somebodyInvite", @"%@ invite you to join groups \'%@\'"), username, self.groupNameTextField.text];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        EMGroup *group = [[EMClient sharedClient].groupManager createGroupWithSubject:self.groupNameTextField.text description:self.groupDescriptionTextView.text invitees:source message:messageStr setting:setting error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
            if (group && !error) {
                [weakSelf showHint:NSLocalizedString(@"group.create.success", @"create group success")];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                [weakSelf showHint:NSLocalizedString(@"group.create.fail", @"Failed to create a group, please operate again")];
            }
        });
    });
    return YES;
}

#pragma mark - action

- (void)groupTypeChange:(UISwitch *)control
{
    _isPublic = control.isOn;
    
    [_groupMemberSwitch setOn:NO animated:NO];
    [self groupMemberChange:_groupMemberSwitch];
    
    if (control.isOn) {
        _groupTypeLabel.text = NSLocalizedString(@"group.create.public", @"public group");
    }
    else{
        _groupTypeLabel.text = NSLocalizedString(@"group.create.private", @"private group");
    }
}

- (void)groupMemberChange:(UISwitch *)control
{
    if (_isPublic) {
        self.groupInvitePermissionLabel.text = NSLocalizedString(@"group.create.occupantJoinPermissions", @"members join permissions");
        if(control.isOn)
        {
            _groupMemberLabel.text = NSLocalizedString(@"group.create.open", @"random join");
        }
        else{
            _groupMemberLabel.text = NSLocalizedString(@"group.create.needApply", @"you need administrator agreed to join the group");
        }
    }
    else{
        self.groupInvitePermissionLabel.text = NSLocalizedString(@"group.create.occupantPermissions", @"members invite permissions");
        if(control.isOn)
        {
            _groupMemberLabel.text = NSLocalizedString(@"group.create.allowedOccupantInvite", @"allows group members to invite others");
        }
        else{
            _groupMemberLabel.text = NSLocalizedString(@"group.create.unallowedOccupantInvite", @"don't allow group members to invite others");
        }
    }
    
    _isMemberOn = control.isOn;
}

- (void)addContacts:(id)sender
{
    if (self.groupNameTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"group.create.inputName", @"please enter the group name") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [self.view endEditing:YES];
    
    ContactSelectionViewController *selectionController = [[ContactSelectionViewController alloc] init];
    selectionController.delegate = self;
    [self.navigationController pushViewController:selectionController animated:YES];
}

@end
