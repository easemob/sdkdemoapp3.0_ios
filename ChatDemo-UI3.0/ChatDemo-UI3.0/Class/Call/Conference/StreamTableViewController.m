//
//  StreamTableViewController.m
//  IosDemo
//
//  Created by XieYajie on 5/30/16.
//  Copyright © 2016 dxstudio.com. All rights reserved.
//

#import "StreamTableViewController.h"

@interface StreamTableViewController ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation StreamTableViewController

- (instancetype)initWithDataSource:(NSArray *)aDataSource
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.dataArray = aDataSource;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    EMCallStream *stream = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = stream.fullName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EMCallStream *stream = [self.dataArray objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(streamController:didSelectedStream:)]) {
        [self.delegate streamController:self didSelectedStream:stream];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
