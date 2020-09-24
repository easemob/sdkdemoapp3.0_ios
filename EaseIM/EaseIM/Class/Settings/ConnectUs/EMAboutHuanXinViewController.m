//
//  EMAboutHuanXinViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/6/9.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EMAboutHuanXinViewController.h"
#import "Masonry.h"

@interface EMAboutHuanXinViewController ()

@property (nonatomic, strong) UIView *logoView;

@property (nonatomic, strong) UIButton *productIntroduceBtn;

@property (nonatomic, strong) UIButton *companyIntroduceBtn;

@end

@implementation EMAboutHuanXinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showRefreshHeader = NO;
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    [self _setupSubviews];
}

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"关于环信";
    [self.view addSubview:self.logoView];
    [_logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@150);
        make.top.left.equalTo(self.view);
    }];
    
    [self.view addSubview:self.productIntroduceBtn];
    [_productIntroduceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.view);
        make.height.equalTo(@60);
        make.top.equalTo(self.logoView.mas_bottom).offset(12);
    }];
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.equalTo(@2);
        make.bottom.equalTo(self.productIntroduceBtn.mas_bottom).offset(1);
    }];
    
    [self.view addSubview:self.companyIntroduceBtn];
    [_companyIntroduceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.view);
        make.height.equalTo(@60);
        make.top.equalTo(self.productIntroduceBtn.mas_bottom);
    }];
}

- (UIView*)logoView
{
    if (_logoView == nil) {
        _logoView = [[UIView alloc]init];
        _logoView.backgroundColor = [UIColor whiteColor];
        UIImageView *logoImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon"]];
        [_logoView addSubview:logoImg];
        [logoImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@82);
            make.height.equalTo(@82);
            make.centerX.equalTo(_logoView);
            make.top.equalTo(_logoView.mas_top).offset(20);
        }];
        UILabel *productName = [[UILabel alloc]init];
        productName.text = [NSString stringWithFormat:@"环信IM %@",[EMClient sharedClient].version];
        productName.textAlignment = NSTextAlignmentCenter;
        productName.textColor = [UIColor colorWithRed:86/255.0 green:86/255.0 blue:86/255.0 alpha:1.0];
        productName.font = [UIFont systemFontOfSize:14.f];
        [_logoView addSubview:productName];
        [productName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@120);
            make.height.equalTo(@20);
            make.centerX.equalTo(logoImg);
            make.top.equalTo(logoImg.mas_bottom).offset(12);
        }];
    }
    return _logoView;
}

- (UIButton*)productIntroduceBtn
{
    if (_productIntroduceBtn == nil) {
        _productIntroduceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _productIntroduceBtn.backgroundColor = [UIColor whiteColor];
        _productIntroduceBtn.tag = 0;
        UILabel *regard = [[UILabel alloc]initWithFrame:CGRectMake(16, 20, 100, 20)];
        regard.text = @"产品介绍";
        regard.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        regard.font = [UIFont systemFontOfSize:14.0];
        [_productIntroduceBtn addSubview:regard];
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 36, 20, 20, 20)];
        arrow.image = [UIImage imageNamed:@"icon-enter"];
        [_productIntroduceBtn addSubview:arrow];
        [_productIntroduceBtn addTarget:self action:@selector(reagrdHuanXin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _productIntroduceBtn;
}

- (UIButton*)companyIntroduceBtn
{
    if (_companyIntroduceBtn == nil) {
        _companyIntroduceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _companyIntroduceBtn.backgroundColor = [UIColor whiteColor];
        _companyIntroduceBtn.tag = 1;
        UILabel *regard = [[UILabel alloc]initWithFrame:CGRectMake(16, 20, 100, 20)];
        regard.text = @"公司介绍";
        regard.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        regard.font = [UIFont systemFontOfSize:14.0];
        [_companyIntroduceBtn addSubview:regard];
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 36, 20, 20, 20)];
        arrow.image = [UIImage imageNamed:@"icon-enter"];
        [_companyIntroduceBtn addSubview:arrow];
        [_companyIntroduceBtn addTarget:self action:@selector(reagrdHuanXin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _companyIntroduceBtn;
}

//关于环信
- (void)reagrdHuanXin:(UIButton *)btn
{
    if (btn.tag == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.easemob.com/product/im"] options:[[NSDictionary alloc]init] completionHandler:nil];
    } else if (btn.tag == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.easemob.com/about"] options:[[NSDictionary alloc]init] completionHandler:nil];
    }
}

@end

