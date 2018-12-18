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
        self.demoOptions = [EMDemoOptions sharedOptions];
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
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 60;
    self.tableView.sectionHeaderHeight = 15;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0];
    [self _setupCells];
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
            
            UITableViewCell *cell = [self _setupCellWithTitle:title value:value isSwitch:isBool tag:(i * 100 + j)];
            [array addObject:cell];
        }
        
        [self.cellArray addObject:array];
    }
}

- (UITableViewCell *)_setupCellWithTitle:(NSString *)aTitle
                                   value:(NSString *)aValue
                                isSwitch:(BOOL)aIsSwitch
                                     tag:(NSInteger)aTag
{
    UITableViewCell *cell = nil;
    if (self.enableEdit) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
        if (!aIsSwitch) {
            UITextField *textField = [[UITextField alloc] init];
            textField.delegate = self;
            textField.tag = aTag;
            textField.borderStyle = UITextBorderStyleNone;
            textField.textAlignment = NSTextAlignmentRight;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:textField];
            [textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(cell.contentView).offset(-8);
                make.top.equalTo(cell.contentView);
                make.bottom.equalTo(cell.contentView);
                make.left.equalTo(cell.textLabel.mas_right).offset(8);
            }];
            
            textField.text = aValue;
//            textField.backgroundColor = [UIColor redColor];
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

#pragma mark - Plist

- (void)_setOptionsValueWithTag:(NSInteger)aTag
                          value:(id)aValue
{
    NSInteger section = aTag / 100;
    NSInteger row = aTag % 100;
    
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
    return [self.plistArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [self.plistArray[section] count];
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    UITableViewCell *cell = [self.cellArray[indexPath.section] objectAtIndex:indexPath.row];
    
    return cell;
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
    if (self.finishCompletion) {
        [self.demoOptions archive];
        self.finishCompletion(self.demoOptions);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)switchValueChanged:(UISwitch *)aSwitch
{
    [self _setOptionsValueWithTag:aSwitch.tag value:@(aSwitch.isOn)];
}

@end
