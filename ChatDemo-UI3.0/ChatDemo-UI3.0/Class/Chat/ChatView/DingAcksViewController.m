//
//  DingAcksViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 12/01/2018.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "DingAcksViewController.h"

#import "EMDingMessageHelper.h"

@interface DingAcksViewController ()

@property (nonatomic, strong) EMMessage *message;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation DingAcksViewController

- (instancetype)initWithMessage:(EMMessage *)aMessage
{
    self = [super init];
    if (self) {
        _message = aMessage;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.title = NSLocalizedString(@"title.readList", @"Read Users");
    
    self.dataArray = [[NSMutableArray alloc] init];
    NSArray *array = [[EMDingMessageHelper sharedHelper] usersHasReadMessage:self.message];
    [self.dataArray addObjectsFromArray:array];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = 50;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    return cell;
}

@end
