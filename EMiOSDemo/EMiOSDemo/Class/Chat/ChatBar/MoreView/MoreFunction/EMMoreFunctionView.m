//
//  EMMoreFunctionView.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/10/23.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMMoreFunctionView.h"

@interface EMMoreFunctionView()

@property (nonatomic, strong) UIButton *readReceiptBtn;
@property (nonatomic, strong) UILabel *readReceiptLable;

@end

@implementation EMMoreFunctionView

- (instancetype)init
{
    self = [super init];
    if(self){
        [self _setupSubviews];
    }
    
    return self;
}

- (void)_setupSubviews
{
    NSInteger count = 16;
    CGFloat width = [UIScreen mainScreen].bounds.size.width / count;
    NSLog(@"\n    ===== width:    %f",width);
    self.readReceiptBtn = [[UIButton alloc]init];
    self.readReceiptBtn.layer.cornerRadius = width;
    self.readReceiptBtn.layer.masksToBounds = YES;
    self.readReceiptBtn.imageEdgeInsets = UIEdgeInsetsMake(2, 10, 2, 10);
    [self.readReceiptBtn setImage:[UIImage imageNamed:@"pin-white"] forState:UIControlStateNormal];
    [self.readReceiptBtn addTarget:self action:@selector(readReceipt) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.readReceiptBtn];
    self.readReceiptBtn.backgroundColor = kColor_Blue;
    [self.readReceiptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(5);
        make.width.mas_equalTo(width * 3);
        make.height.equalTo(@50);
        make.left.equalTo(self).offset(width);
    }];
    
    self.readReceiptLable = [[UILabel alloc]init];
    self.readReceiptLable.backgroundColor = [UIColor whiteColor];
    self.readReceiptLable.textColor = [UIColor blackColor];
    [self.readReceiptLable setText:@"阅读回执"];
    [self.readReceiptLable setFont:[UIFont systemFontOfSize:14.0]];
    self.readReceiptLable.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.readReceiptLable];
    [self.readReceiptLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.readReceiptBtn.mas_bottom).offset(5);
        make.width.mas_equalTo(width * 3);
        make.height.equalTo(@25);
        make.left.equalTo(self.readReceiptBtn);
    }];
    
}

- (void)readReceipt
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionReadReceipt)]) {
        [self.delegate chatBarMoreFunctionReadReceipt];
    }
}
@end
