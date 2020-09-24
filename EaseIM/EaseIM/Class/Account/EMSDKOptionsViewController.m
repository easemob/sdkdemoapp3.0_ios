//
//  EMSDKOptionsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/17.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMSDKOptionsViewController.h"

#import "EMDemoOptions.h"

@interface EMSDKOptionsViewController ()<UITextFieldDelegate>

@property (nonatomic, copy) void (^finishCompletion)(EMDemoOptions *aOptions);
@property (nonatomic) BOOL enableEdit;
@property (nonatomic, strong) EMDemoOptions *demoOptions;

@property (nonatomic, strong) NSArray *plistArray;
@property (nonatomic, strong) NSMutableArray *cellArray;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UISwitch *sw;

@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIView *viewArrow;
@property (nonatomic, strong) CAGradientLayer *gl;
@property (nonatomic, strong) CAGradientLayer *backGl;
@property (nonatomic, strong) UILabel *loginLabel;

@end

@implementation EMSDKOptionsViewController

- (instancetype)initWithEnableEdit:(BOOL)aEnableEdit
                  finishCompletion:(void (^)(EMDemoOptions *aOptions))aFinishBlock
{
    self = [super init];
    if (self) {
        self.demoOptions = [[EMDemoOptions sharedOptions] copy];
        self.enableEdit = aEnableEdit;
        self.finishCompletion = aFinishBlock;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.plistArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EMSDKOptions" ofType:@"plist"]];

    [self _setupSubviews];
    [self.tableView reloadData];
    self.tableView.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
     //监听键盘弹出事件
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
     //监听键盘隐藏事件
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

//注销通知
-(void)viewDidDisAppear:(BOOL)animated{

     [super viewDidDisappear:animated];

     [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];

     [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    //[self addPopBackLeftItem];
    self.title = @"SDK配置";

    if (self.enableEdit) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveOptionsAction)];
    } else {
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:0.4] forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    //self.navigationItem.rightBarButtonItem.enabled = self.enableEdit;
    
    //self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    imageView.image=[UIImage imageNamed:@"BootPage"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:imageView atIndex:0];
    
    self.backButton = [[UIButton alloc]init];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"back_left"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backBackion) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44 + EMVIEWTOPMARGIN);
        make.left.equalTo(self.view).offset(24);
        make.height.equalTo(@24);
        make.width.equalTo(@24);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.text = @"使用自定义服务器？";
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    //titleLabel.textColor = [UIColor blueColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(24);
        make.width.equalTo(@170);
        make.height.equalTo(@25);
    }];
    
    self.sw = [[UISwitch alloc] init];
    [self.sw addTarget:self action:@selector(switchServerChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.sw];
    [self.sw mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-8);
        make.centerY.equalTo(titleLabel);
    }];
    
    [self.sw setOn:false];
    self.sw.enabled = true;//启用控件
    
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    //self.tableView.layer.cornerRadius = 25;
    self.tableView.layer.masksToBounds = YES;
    //self.tableView.layer.shouldRasterize = YES;
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundView:[[UIView alloc] init]];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(8);
        make.right.equalTo(self.view).offset(-8);
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.bottom.equalTo(self.view.mas_bottom).offset(-8);
    }];
    [self _setupCells];
}


//是否使用自定义服务器
- (void)switchServerChanged:(UISwitch *)sw
{
    if(sw.on) {
        self.tableView.hidden = NO;
        [self gl];
        _gl.frame = CGRectMake(0,0,_loginButton.frame.size.width,_loginButton.frame.size.height);
        [self.loginButton.layer addSublayer:self.gl];
    }else{
        self.tableView.hidden = YES;
    }
}

- (void)backBackion
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (NSInteger)_tagWithSection:(NSInteger)aSection
                         row:(NSInteger)aRow
{
    return ((aSection + 1) * 100 + aRow);
}

- (void)_getSection:(NSInteger *)aSection
                row:(NSInteger *)aRow
            fromTag:(NSInteger)aTag
{
    *aSection = aTag / 100 - 1;
    *aRow = aTag % 100;
}

- (void)_setupCells
{
    self.cellArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.plistArray count]; i++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        NSArray *tmpPlist = self.plistArray[i];
        for (int j = 0; j < [tmpPlist count]; j++) {
            NSDictionary *dic = tmpPlist[j];
            NSString *title = [dic objectForKey:@"title"];
            NSString *getMethod = [dic objectForKey:@"getMethod"];
            NSString *value = @"";
            BOOL isBool = NO;
            if ([getMethod length] > 0) {
                SEL sel = NSSelectorFromString(getMethod);
                IMP imp = [self.demoOptions methodForSelector:sel];
                NSString *resultType = [dic objectForKey:@"getResultType"];
                if ([resultType length] > 0) {
                    if ([resultType isEqualToString:@"int"]) {
                        int (*func)(id, SEL) = (void *)imp;
                        value = @(func(self.demoOptions, sel)).stringValue;
                    } else if ([resultType isEqualToString:@"bool"]) {
                        isBool = YES;
                        bool (*func)(id, SEL) = (void *)imp;
                        value = @(func(self.demoOptions, sel)).stringValue;
                    }
                    
                } else {
                    id (*func)(id, SEL) = (void *)imp;
                    value = func(self.demoOptions, sel);
                }
            }
            
            UITableViewCell *cell = [self _setupCellWithTitle:title value:value isSwitch:isBool tag:[self _tagWithSection:i row:j]];
            [array addObject:cell];
        }
        
        [self.cellArray addObject:array];
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"confirmCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _loginButton.layer.cornerRadius = 25;
    _loginButton.backgroundColor = [UIColor clearColor];
    //[_loginButton.layer insertSublayer:self.gl atIndex:0];
    
    [_loginButton addTarget:self action:@selector(saveOptionsAction) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:_loginButton];
    [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(cell.contentView);
        make.top.equalTo(cell.contentView.mas_top).offset(5);
        make.bottom.equalTo(cell.contentView.mas_bottom).offset(-5);
    }];
    
    self.loginLabel = [[UILabel alloc] init];
    _loginLabel.numberOfLines = 0;
    _loginLabel.font = [UIFont systemFontOfSize:16];
    _loginLabel.text = @"保存配置";
    [_loginLabel setTextColor:[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0]];
    _loginLabel.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:_loginLabel];
    [_loginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.loginButton);
        make.centerX.equalTo(self.loginButton);
        make.width.equalTo(@120);
        make.height.equalTo(@23);
    }];
    
    _loginButton.alpha = 1;
    _loginLabel.alpha = 1;
    
    self.viewArrow = [[UIView alloc] init];
    _viewArrow.layer.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
    _viewArrow.layer.cornerRadius = 20;
    [cell.contentView addSubview:_viewArrow];
    [_viewArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@43);
        make.right.equalTo(self.loginButton.mas_right).offset(-6);
        make.top.equalTo(self.loginButton.mas_top).offset(6);
        make.height.equalTo(self.loginButton.mas_height).offset(-12);
    }];
    _viewArrow.layer.backgroundColor = ([UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor);;
    
    //cell.textLabel.textColor = kColor_Blue;
    //cell.textLabel.text = @"还原默认配置";
    cell.layer.cornerRadius = 20;
    cell.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [array addObject:cell];
    [self.cellArray addObject:array];
}

- (UITableViewCell *)_setupCellWithTitle:(NSString *)aTitle
                                   value:(NSString *)aValue
                                isSwitch:(BOOL)aIsSwitch
                                     tag:(NSInteger)aTag
{
    UITableViewCell *cell = nil;
    if ([aValue isEqual:DEF_APPKEY])
        aValue = @"Appkey";
    if (self.enableEdit) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellValue1"];
        if (!aIsSwitch) {
            UITextField *textField = [[UITextField alloc] init];
            textField.delegate = self;
            textField.tag = aTag;
            textField.borderStyle = UITextBorderStyleNone;
            textField.textAlignment = NSTextAlignmentRight;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.adjustsFontSizeToFitWidth = YES;
            textField.returnKeyType = UIReturnKeyDone;
            [cell.contentView addSubview:textField];
            [textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(cell.contentView).offset(-8);
                make.top.equalTo(cell.contentView);
                make.bottom.equalTo(cell.contentView);
                make.left.equalTo(cell.textLabel.mas_right).offset(8);
            }];
            
            textField.text = aValue;
        }
        
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
        if (!aIsSwitch) {
            cell.detailTextLabel.text = aValue;
        }
    }
    
    if (aIsSwitch) {
        UISwitch *sw = [[UISwitch alloc] init];
        sw.tag = aTag;
        [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:sw];
        [sw mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.contentView).offset(-15);
            make.centerY.equalTo(cell.contentView);
        }];
        
        [sw setOn:[aValue boolValue]];
        sw.enabled = self.enableEdit;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = aTitle;
    
    cell.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    cell.layer.cornerRadius = 20;
    
    return cell;
}

- (void)_reloadCellValues
{
    if (!self.enableEdit) {
        return;
    }
    
    for (int i = 0; i < [self.plistArray count]; i++) {
        NSArray *tmpPlist = self.plistArray[i];
        for (int j = 0; j < [tmpPlist count]; j++) {
            UITableViewCell *cell = self.cellArray[i][j];
            NSDictionary *dic = tmpPlist[j];
            NSString *getMethod = [dic objectForKey:@"getMethod"];
            NSString *value = @"";
            BOOL isBool = NO;
            if ([getMethod length] > 0) {
                SEL sel = NSSelectorFromString(getMethod);
                IMP imp = [self.demoOptions methodForSelector:sel];
                NSString *resultType = [dic objectForKey:@"getResultType"];
                if ([resultType length] > 0) {
                    if ([resultType isEqualToString:@"int"]) {
                        int (*func)(id, SEL) = (void *)imp;
                        value = @(func(self.demoOptions, sel)).stringValue;
                    } else if ([resultType isEqualToString:@"bool"]) {
                        isBool = YES;
                        bool (*func)(id, SEL) = (void *)imp;
                        value = @(func(self.demoOptions, sel)).stringValue;
                    }
                    
                } else {
                    id (*func)(id, SEL) = (void *)imp;
                    value = func(self.demoOptions, sel);
                }
            }
            
            if (isBool) {
                UISwitch *sw = [cell.contentView viewWithTag:[self _tagWithSection:i row:j]];
                [sw setOn:[value boolValue]];
            } else {
                UITextField *textField = [cell.contentView viewWithTag:[self _tagWithSection:i row:j]];
                textField.text = value;
            }
        }
    }
}

#pragma mark - Plist

- (void)_setOptionsValueWithTag:(NSInteger)aTag
                          value:(id)aValue
{
    NSInteger section = 0;
    NSInteger row = 0;
    [self _getSection:&section row:&row fromTag:aTag];
    
    NSDictionary *dic = self.plistArray[section][row];
    NSString *setMethod = [dic objectForKey:@"setMethod"];
    if ([setMethod length] > 0) {
        SEL sel = NSSelectorFromString(setMethod);
        IMP imp = [self.demoOptions methodForSelector:sel];
        NSString *resultType = [dic objectForKey:@"getResultType"];
        if ([resultType length] > 0) {
            if ([resultType isEqualToString:@"int"]) {
                void (*func)(id, SEL, int) = (void *)imp;
                func(self.demoOptions, sel, [aValue intValue]);
            } else if ([resultType isEqualToString:@"bool"]) {
                void (*func)(id, SEL, bool) = (void *)imp;
                func(self.demoOptions, sel, [aValue boolValue]);
            }
            
        } else {
            void (*func)(id, SEL, id) = (void *)imp;
            func(self.demoOptions, sel, aValue);
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.cellArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [((NSArray *)self.cellArray[section]) count];
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    UITableViewCell *cell = [self.cellArray[indexPath.section] objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    UIView *backView = [[UIView alloc]init];
    backView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    backView.layer.cornerRadius = 20;
    [cell.contentView insertSubview:backView atIndex:0];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cell.contentView.mas_top).offset(5);
        make.bottom.equalTo(cell.contentView.mas_bottom).offset(-5);
        make.left.right.equalTo(cell.contentView);
    }];
    if(indexPath.section == 3) {
        backView.backgroundColor = [UIColor clearColor];
        [self gl];
        _gl.frame = CGRectMake(0,0,backView.frame.size.width,backView.frame.size.height);
        [backView.layer addSublayer:self.gl];
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    /*
    if (section == 0 && !self.enableEdit) {
        return 50;
    }*/
    if (section == 0 &&  !self.enableEdit) {
        [self.loginButton removeTarget:self action:@selector(saveOptionsAction) forControlEvents:UIControlEventAllEvents];
        self.loginLabel.text = @"还原默认配置";
        return 50;
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 &&  !self.enableEdit) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 20, 50)];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor lightGrayColor];
        label.text = @"demo已经绑定以下环境设置，如果需要修改配置请双击\"还原默认配置\"重新启动App";
        [view addSubview:label];
        view.layer.cornerRadius = 25;
        view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        return view;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    /*
    if (section == [self.cellArray count] - 1) {
        return 20;
    }*/
    
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [self.cellArray count] - 1) {
        if (self.enableEdit) {
            [EMDemoOptions reInitAndSaveServerOptions];
            
            self.demoOptions = [[EMDemoOptions sharedOptions] copy];
            [self _reloadCellValues];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"(づ｡◕‿‿◕｡)づ" message:@"当前appkey以及环境配置已生效，如果需要更改需要重启客户端" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [EMDemoOptions reInitAndSaveServerOptions];
                
                exit(0);
            }];
            [alertController addAction:okAction];
            
            [alertController addAction: [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            alertController.modalPresentationStyle = 0;
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger tag = textField.tag;
    NSString *value = textField.text;
    [self _setOptionsValueWithTag:tag value:value];

    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - Action

- (void)switchValueChanged:(UISwitch *)aSwitch
{
    [self _setOptionsValueWithTag:aSwitch.tag value:@(aSwitch.isOn)];
}

- (void)saveOptionsAction
{
    [self.view endEditing:YES];
    
    EMDemoOptions *demoOptions = [EMDemoOptions sharedOptions];
    demoOptions.appkey = self.demoOptions.appkey;
    demoOptions.apnsCertName = self.demoOptions.apnsCertName;
    demoOptions.specifyServer = self.demoOptions.specifyServer;
    demoOptions.chatPort = self.demoOptions.chatPort;
    demoOptions.chatServer = self.demoOptions.chatServer;
    demoOptions.restServer = self.demoOptions.restServer;
    demoOptions.usingHttpsOnly = self.demoOptions.usingHttpsOnly;
    [demoOptions archive];
    
    if (self.finishCompletion) {
        [self.demoOptions archive];
        self.finishCompletion(demoOptions);
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (CAGradientLayer *)gl{
    if(_gl == nil){
        _gl = [CAGradientLayer layer];
        _gl.startPoint = CGPointMake(0.15, 0.5);
        _gl.endPoint = CGPointMake(1, 0.5);
        _gl.colors = @[(__bridge id)[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:90/255.0 green:93/255.0 blue:208/255.0 alpha:1.0].CGColor];
        _gl.locations = @[@(0), @(1.0f)];
        _gl.cornerRadius = 25;
    }
    
    return _gl;
}

#pragma mark - 键盘即将弹出事件处理
- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘信息
    NSDictionary *keyBoardInfo = [notification userInfo];
    
    //获取键盘的frame信息
    NSValue *value = [keyBoardInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardHeight = [value CGRectValue].size.height;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    UIView *cellView = [[firstResponder superview] superview];
    CGFloat keyboardPosition = [UIScreen mainScreen].bounds.size.height - keyboardHeight - 60;
    if ((cellView.frame.origin.y + 60) > keyboardPosition)
    {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, ((cellView.frame.origin.y + 60) - keyboardPosition), 0);
        CGPoint scrollPoint = CGPointMake(0.0, keyboardPosition-firstResponder.frame.origin.y - 60);
        [_tableView setContentOffset:scrollPoint animated:YES];
    }
}

#pragma mark - 键盘即将隐藏事件
- (void)keyboardWillHide:(NSNotification *)notification
{
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}
@end
