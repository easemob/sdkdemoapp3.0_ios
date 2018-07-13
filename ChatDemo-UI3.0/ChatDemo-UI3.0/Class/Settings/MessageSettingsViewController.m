//
//  MessageSettingsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/7/13.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "MessageSettingsViewController.h"

@interface MessageSettingsViewController ()

@property (strong, nonatomic) UISwitch *typingSwitch;

@end

@implementation MessageSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.title = NSLocalizedString(@"setting.message", nil);
    
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UISwitch *)typingSwitch
{
    if (_typingSwitch == nil) {
        _typingSwitch = [[UISwitch alloc] init];
        [_typingSwitch addTarget:self action:@selector(typingSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
        
        NSUserDefaults *uDefaults = [NSUserDefaults standardUserDefaults];
        _typingSwitch.on = [uDefaults boolForKey:@"MessageShowTyping"];
    }
    
    return _typingSwitch;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"setting.message.showTyping", nil);
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.typingSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.typingSwitch.frame.size.width + 10), (tableView.rowHeight - self.typingSwitch.frame.size.height) / 2, self.typingSwitch.frame.size.width, self.typingSwitch.frame.size.height);
        [cell.contentView addSubview:self.typingSwitch];
    }
    
    return cell;
}

#pragma mark - Action

- (void)typingSwitchValueChanged
{
    NSUserDefaults *udefaults = [NSUserDefaults standardUserDefaults];
    [udefaults setBool:self.typingSwitch.isOn forKey:@"MessageShowTyping"];
}

@end
