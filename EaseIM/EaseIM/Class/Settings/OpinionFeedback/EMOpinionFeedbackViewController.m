//
//  EMOpinionFeedbackViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/6/10.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMOpinionFeedbackViewController.h"
#import "EMTextView.h"
#import "EMFeedBackType.h"

@interface EMOpinionFeedbackViewController ()<UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) EMTextView *opinionDescTextView;
@property (nonatomic, strong) UILabel *feedBackTypeLabel;
@property (nonatomic, strong) UITextField *mailTextFiled;
@property (nonatomic, strong) UITextField *imTextFiled;

@property (nonatomic, strong) UIButton *commitBtn;

@end

@implementation EMOpinionFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showRefreshHeader = NO;
    self.view.layer.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0].CGColor;
    [self _setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"意见反馈";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(commitAction)];
    
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.textLabel.text = @"选择问题类型";
        [cell.contentView addSubview:self.feedBackTypeLabel];
        [self.feedBackTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView).offset(-16);
            make.left.equalTo(cell.textLabel.mas_right).offset(16);
        }];
    }
    if (indexPath.section == 1 && row == 0) {
        cell.textLabel.text = @"您的邮箱";
        [cell.contentView addSubview:self.mailTextFiled];
        [self.mailTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView).offset(-16);
            make.left.equalTo(cell.textLabel.mas_right).offset(16);
        }];
    }
    if (indexPath.section == 1 && row == 1) {
        cell.textLabel.text = @"您的QQ";
        [cell.contentView addSubview:self.imTextFiled];
        [self.imTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView).offset(-16);
            make.left.equalTo(cell.textLabel.mas_right).offset(16);
        }];
    }
    cell.accessoryType = indexPath.section == 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return cell;
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 182)];
        footerView.backgroundColor = [UIColor clearColor];
        UIView *perchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 16)];
        perchView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
        [footerView addSubview:perchView];
        UIView *descView = [[UIView alloc]initWithFrame:CGRectMake(0, 16, [UIScreen mainScreen].bounds.size.width, 166)];
        descView.backgroundColor = [UIColor whiteColor];
        [footerView addSubview:descView];
        self.opinionDescTextView = [[EMTextView alloc] init];
        self.opinionDescTextView.delegate = self;
        self.opinionDescTextView.placeholder = @"问题描述";
        self.opinionDescTextView.font = [UIFont systemFontOfSize:14];
        self.opinionDescTextView.textAlignment = NSTextAlignmentLeft;
        self.opinionDescTextView.returnKeyType = UIReturnKeyDone;
        [descView addSubview:self.opinionDescTextView];
        [self.opinionDescTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(descView.mas_top).offset(8);
            make.bottom.equalTo(descView.mas_bottom).offset(-8);
            make.left.equalTo(descView.mas_left).offset(20);
            make.right.equalTo(descView.mas_right).offset(-20);
        }];
        return footerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) return 16;
    return 0.001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) return 182;
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        EMFeedBackType *feedBackTypeView = [[EMFeedBackType alloc]init];
        [self.view addSubview:feedBackTypeView];
        [feedBackTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(self.view);
        }];
        [feedBackTypeView setDoneCompletion:^(NSString * _Nonnull aConfirm) {
            self.feedBackTypeLabel.text = aConfirm;
        }];
    }
}

#pragma mark -UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

# pragma mark - Action

//提交
- (void)commitAction
{
    
}

#pragma mark - Getter & Setter

- (UILabel *)feedBackTypeLabel
{
    if (_feedBackTypeLabel == nil) {
        _feedBackTypeLabel = [[UILabel alloc]init];
        _feedBackTypeLabel.text = @"BUG反馈";
        _feedBackTypeLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        _feedBackTypeLabel.font = [UIFont systemFontOfSize:14.0];
        _feedBackTypeLabel.textAlignment = NSTextAlignmentRight;
        _feedBackTypeLabel.userInteractionEnabled = NO;
    }
    return _feedBackTypeLabel;
}

- (UITextField *)mailTextFiled
{
    if (_mailTextFiled == nil) {
        _mailTextFiled = [[UITextField alloc]init];
        _mailTextFiled.font = [UIFont systemFontOfSize:14.0];
        _mailTextFiled.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        _mailTextFiled.textAlignment = NSTextAlignmentRight;
        _mailTextFiled.returnKeyType = UIReturnKeyDone;
        _mailTextFiled.delegate = self;
        _mailTextFiled.placeholder = @"请输入邮箱地址";
    }
    return _mailTextFiled;
}

- (UITextField *)imTextFiled
{
    if (_imTextFiled == nil) {
        _imTextFiled = [[UITextField alloc]init];
        _imTextFiled.font = [UIFont systemFontOfSize:14.0];
        _imTextFiled.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        _imTextFiled.textAlignment = NSTextAlignmentRight;
        _imTextFiled.returnKeyType = UIReturnKeyDone;
        _imTextFiled.delegate = self;
        _imTextFiled.placeholder = @"请输入QQ号";
    }
    return _imTextFiled;
}

#pragma mark - KeyBoard

- (void)keyBoardWillShow:(NSNotification *)note
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;

    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    UIView *cellView = [[firstResponder superview] superview];
    CGFloat keyboardPosition = [UIScreen mainScreen].bounds.size.height - keyBoardHeight - 60;
    if ((cellView.frame.origin.y + 60) > keyboardPosition)
    {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, ((cellView.frame.origin.y + 60) - keyboardPosition), 0);
        CGPoint scrollPoint = CGPointMake(0.0, keyboardPosition-firstResponder.frame.origin.y - 60);
        [self.tableView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyBoardWillHide:(NSNotification *)note
{
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
