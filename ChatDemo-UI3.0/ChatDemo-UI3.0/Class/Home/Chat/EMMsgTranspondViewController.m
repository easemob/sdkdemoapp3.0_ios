//
//  EMMsgTranspondViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/20.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMsgTranspondViewController.h"

#import "EMMessageModel.h"

#import "EMAvatarNameCell.h"

@interface EMMsgTranspondViewController ()

@property (nonatomic, strong) EMMessageModel *model;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation EMMsgTranspondViewController

- (instancetype)initWithModel:(EMMessageModel *)aModel
{
    self = [super init];
    if (self) {
        _model = aModel;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _setupSubviews];
    [self loadContactsFromDB];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"转发" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    self.title = @"转发消息";
    
    self.tableView.rowHeight = 60;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EMAvatarNameCell";
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIButton *checkButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 30)];
        checkButton.tag = 100;
        [checkButton setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        [checkButton setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
        checkButton.userInteractionEnabled = NO;
        cell.accessoryView = checkButton;
    }
    
    cell.avatarView.image = [UIImage imageNamed:@"user_avatar_blue"];
    cell.nameLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    UIButton *checkButton = (UIButton *)cell.accessoryView;
    checkButton.selected = (self.indexPath && self.indexPath.row == indexPath.row) ? YES : NO;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMAvatarNameCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *checkButton = (UIButton *)cell.accessoryView;
    if (indexPath.row == self.indexPath.row) {
        self.indexPath = nil;
        checkButton.selected = NO;
        return;
    }
    
    EMAvatarNameCell *oldCell = [tableView cellForRowAtIndexPath:self.indexPath];
    UIButton *oldButton = (UIButton *)oldCell.accessoryView;
    oldButton.selected = NO;
    
    self.indexPath = indexPath;
    checkButton.selected = YES;
}

#pragma mark - Data

- (void)loadContactsFromDB
{
    NSArray *contacts = [[EMClient sharedClient].contactManager getContacts];
    [self.dataArray addObjectsFromArray:contacts];
    [self.tableView reloadData];
}

#pragma mark - Action

- (void)doneAction
{
    NSString *username = [self.dataArray objectAtIndex:self.indexPath.row];
    if (self.doneCompletion) {
        self.doneCompletion(self.model, username);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
