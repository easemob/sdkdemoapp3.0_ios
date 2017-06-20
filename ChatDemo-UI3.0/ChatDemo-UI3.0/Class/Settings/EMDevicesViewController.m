//
//  EMDevicesViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 20/06/2017.
//  Copyright © 2017 XieYajie. All rights reserved.
//

#import "EMDevicesViewController.h"

@interface EMDevicesViewController ()

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation EMDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"setting.deviceResources", @"List of logged devices");
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"setting.kickAllDevices", @"KickAll") style:UIBarButtonItemStylePlain target:self action:@selector(kickAllDevices)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self setupRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    
    return _dataSource;
}

- (void)setupRefresh
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchDataFromServer) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl beginRefreshing];
    [self fetchDataFromServer];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    }
    
    EMDeviceConfig *options = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = options.deviceName;
    if ([options.deviceName length] == 0) {
        cell.textLabel.text = options.osVersion;
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [self showHudInView:self.view hint:NSLocalizedString(@"wait", @"Waiting...")];
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EMDeviceConfig *option = [weakself.dataSource objectAtIndex:indexPath.row];
            EMError *error = [[EMClient sharedClient] kickDevice:option];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself hideHud];
                if (!error) {
                    [weakself.dataSource removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                } else {
                    [weakself showHint:error.errorDescription];
                }
            });
        });
    }   
}

#pragma mark - Action

- (void)kickAllDevices
{
    [self showHudInView:self.view hint:NSLocalizedString(@"wait", @"Waiting...")];
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] kickAllDevices];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself hideHud];
            if (!error) {
                [weakself.dataSource removeAllObjects];
                [weakself.tableView reloadData];
            } else {
                [weakself showHint:error.errorDescription];
            }
        });
    });
}

#pragma mark - Data

- (void)fetchDataFromServer
{
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        NSArray *array = [[EMClient sharedClient] getLoggedInDevicesFromServerWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself hideHud];
            [weakself.refreshControl endRefreshing];
            if (!error) {
                [weakself.dataSource removeAllObjects];
                [weakself.dataSource addObjectsFromArray:array];
                [weakself.tableView reloadData];
            } else {
                [weakself showHint:error.errorDescription];
            }
        });
    });
}

@end
