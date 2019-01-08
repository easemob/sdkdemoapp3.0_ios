//
//  EMSDKOptionsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/17.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMSDKOptionsViewController.h"

#import "Masonry.h"

#import "EMDemoOptions.h"

@interface EMSDKOptionsViewController ()<UITextFieldDelegate>

@property (nonatomic, copy) void (^finishCompletion)(EMDemoOptions *aOptions);
@property (nonatomic) BOOL enableEdit;
@property (nonatomic, strong) EMDemoOptions *demoOptions;

@property (nonatomic, strong) NSArray *plistArray;
@property (nonatomic, strong) NSMutableArray *cellArray;

@end

@implementation EMSDKOptionsViewController

- (instancetype)initWithEnableEdit:(BOOL)aEnableEdit
                  finishCompletion:(void (^)(EMDemoOptions *aOptions))aFinishBlock
{
    self = [super initWithStyle:UITableViewStyleGrouped];
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
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.title = @"SDK配置";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back_gary"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    if (self.enableEdit) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveOptionsAction)];
    } else {
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:0.4] forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = self.enableEdit;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0];
    [self _setupCells];
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0];
    cell.textLabel.text = @"还原默认配置";
    [array addObject:cell];
    [self.cellArray addObject:array];
}

- (UITableViewCell *)_setupCellWithTitle:(NSString *)aTitle
                                   value:(NSString *)aValue
                                isSwitch:(BOOL)aIsSwitch
                                     tag:(NSInteger)aTag
{
    UITableViewCell *cell = nil;
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
    NSInteger count = [self.cellArray[section] count];
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    UITableViewCell *cell = [self.cellArray[indexPath.section] objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 && !self.enableEdit) {
        return 50;
    }
    
    return 20;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 &&  !self.enableEdit) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 20, 50)];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor lightGrayColor];
        label.text = @"demo已经绑定以下环境设置，如果需要修改配置请点击\"还原默认配置\"重新启动App";
        [view addSubview:label];
        return view;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == [self.cellArray count] - 1) {
        return 20;
    }
    
    return 1;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [self.cellArray count] - 1) {
        if (self.enableEdit) {
            EMDemoOptions *options = [EMDemoOptions sharedOptions];
            [options reInitServerOptions];
            [options archive];
            
            self.demoOptions = [options copy];
            [self _reloadCellValues];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"(づ｡◕‿‿◕｡)づ" message:@"当前appkey以及环境配置已生效，如果需要更改需要重启客户端" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                EMDemoOptions *options = [EMDemoOptions sharedOptions];
                [options reInitServerOptions];
                [options archive];
                
                exit(0);
            }];
            [alertController addAction:okAction];
            
            [alertController addAction: [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            
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

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)switchValueChanged:(UISwitch *)aSwitch
{
    [self _setOptionsValueWithTag:aSwitch.tag value:@(aSwitch.isOn)];
}

- (void)saveOptionsAction
{
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
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
