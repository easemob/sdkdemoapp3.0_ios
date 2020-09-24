//
//  EMPickFileViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/1/3.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMPickFileViewController.h"

@interface EMPickFileViewController ()

@property (nonatomic, strong) UIButton *recentBtn;//最近
@property (nonatomic, strong) UIButton *localBtn;//本机

@property (nonatomic, strong) UIView *localMediaView;//本机媒体

@property (nonatomic, strong) UIButton *avBtn;//影音
@property (nonatomic, strong) UIButton *picBtn;//图片

@end

@implementation EMPickFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupSubviews];
}

- (void)_setupSubviews
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backleft"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    [self _setupNavigationBarTitle];
    [self _setupItemBar];
    self.showRefreshHeader = YES;
    
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 130;
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.picBtn.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)_setupNavigationBarTitle
{
    self.localMediaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    CGFloat location = self.view.frame.size.width / 2;
    
    self.recentBtn = [[UIButton alloc]init];
    [self.recentBtn setTitle:@"最近" forState:UIControlStateNormal];
    self.recentBtn.backgroundColor = [UIColor lightGrayColor];
    self.recentBtn.titleLabel.textColor = [UIColor blackColor];
    [self.localMediaView addSubview:self.recentBtn];
    [self.recentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@50);
        make.height.equalTo(@38);
        make.top.equalTo(self.localMediaView).offset(1);
        make.bottom.equalTo(self.localMediaView).offset(-1);
        make.right.equalTo(self.localMediaView).offset(-location);
    }];
    
    self.localBtn = [[UIButton alloc]init];
    [self.localBtn setTitle:@"本机" forState:UIControlStateNormal];
    self.localBtn.backgroundColor = [UIColor lightGrayColor];
    self.localBtn.titleLabel.textColor = [UIColor blackColor];
    [self.localMediaView addSubview:self.localBtn];
    [self.localBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@50);
        make.height.equalTo(@38);
        make.top.equalTo(self.localMediaView).offset(1);
        make.bottom.equalTo(self.localMediaView).offset(-1);
        make.left.equalTo(self.recentBtn.mas_right).offset(1);
    }];
    
    self.navigationItem.titleView = self.localMediaView;
}

- (void)_setupItemBar
{
    CGFloat width = (self.view.frame.size.width)/2;
    
    self.avBtn = [[UIButton alloc]init];
    [_avBtn setTitle:@"影音" forState:UIControlStateNormal];
    [_avBtn setTitleColor:[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0] forState:UIControlStateNormal];
    _avBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _avBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _avBtn.tag = 1;
    [_avBtn addTarget:self action:@selector(cutFileType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_avBtn];
    [_avBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.mas_equalTo(width);
        make.height.equalTo(@40);
    }];

    self.picBtn = [[UIButton alloc]init];
    [_picBtn setTitle:@"图片" forState:UIControlStateNormal];
    _picBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _picBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_picBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
    _picBtn.tag = 2;
    [_picBtn addTarget:self action:@selector(cutFileType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.picBtn];
    [_picBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.right.equalTo(self.view);
        make.width.mas_equalTo(width);
        make.height.equalTo(@40);
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.picBtn.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - cutGroupType
- (void)cutFileType:(UIButton *)btn
{
    if (btn.tag == 1) {
        [self.localBtn setTitleColor:[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        [self.picBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
    } else if (btn.tag == 2) {
        [self.localBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        [self.picBtn setTitleColor:[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    
    [self.tableView reloadData];
}
    
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
