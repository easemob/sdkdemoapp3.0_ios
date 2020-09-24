//
//  EMUserAgreementView.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/2.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMUserAgreementView.h"

@interface EMUserAgreementView()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *linkProtocol;//协议内容链接

@end

@implementation EMUserAgreementView

- (instancetype)initUserAgreement
{
    self = [super init];
    if (self) {
        self.protocolTextHeight = 0.0;
        [self _setupUserAgreementBtn];
        [self _setupLinkProtocol];
        self.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark - PrivateSetUI
//同意按钮
- (void)_setupUserAgreementBtn
{
    [self addSubview:self.userAgreementBtn];
    [self.userAgreementBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@ComponentHeight);
        make.top.equalTo(self);
        make.left.equalTo(self);
    }];
}

//用户协议内容链接
- (void)_setupLinkProtocol
{
    NSString *linkStr = @"同意《环信服务条款》与《环信隐私协议》";
    UIFont *linkFont = [UIFont systemFontOfSize:12.0];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:linkStr];
    [attributedString addAttribute:NSLinkAttributeName value:@"serviceClause://" range:[[attributedString string] rangeOfString:@"《环信服务条款》"]];
    [attributedString addAttribute:NSLinkAttributeName value:@"privacyProtocol://" range:[[attributedString string] rangeOfString:@"《环信隐私协议》"]];
    NSDictionary *attriDict = @{NSFontAttributeName:linkFont};
    [attributedString addAttributes:attriDict range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [attributedString length])];
    
    self.linkProtocol.attributedText = attributedString;
    self.linkProtocol.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSUnderlineColorAttributeName: [UIColor whiteColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    self.protocolTextHeight = [self getAttributionHeightWithString:linkStr lineSpace:1.5 kern:1 font:linkFont width:[UIScreen mainScreen].bounds.size.width - self.userAgreementBtn.frame.origin.x - ComponentHeight].height;
    [self addSubview:self.linkProtocol];
    [self.linkProtocol mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.userAgreementBtn.mas_right).offset(5);
        make.centerY.equalTo(self.userAgreementBtn);
        make.height.equalTo(@(self.protocolTextHeight));
    }];
}

/* 获取富文本的高度
 *
 * @param string    文字
 * @param lineSpace 行间距
 * @param kern      字间距
 * @param font      字体大小
 * @param width     文本宽度
 *
 * @return size
 */
- (CGSize)getAttributionHeightWithString:(NSString *)string lineSpace:(CGFloat)lineSpace kern:(CGFloat)kern font:(UIFont *)font width:(CGFloat)width {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = lineSpace;
    NSDictionary *attriDict = @{
                                NSParagraphStyleAttributeName:paragraphStyle,
                                NSKernAttributeName:@(kern),
                                NSFontAttributeName:font};
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attriDict context:nil].size;
    return size;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"serviceClause"]) {
        //服务条款
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapUserProtocol:sign:)]) {
            [self.delegate didTapUserProtocol:@"http://www.easemob.com/agreement" sign:@"serviceClause"];
        }
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.easemob.com"] options:[[NSDictionary alloc]init] completionHandler:nil];
    }
        
    if ([[URL scheme] isEqualToString:@"privacyProtocol"]) {
        //隐私协议
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapUserProtocol:sign:)]) {
            [self.delegate didTapUserProtocol:@"http://www.easemob.com/protocol" sign:@"privacyProtocol"];
        }
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.easemob.com"] options:[[NSDictionary alloc]init] completionHandler:nil];
    }
        
    return NO;
}

#pragma mark - Action

//同意条款与协议
- (void)agreeProtocolAction:(UIButton *)btn
{
    self.userAgreementBtn.selected = !self.userAgreementBtn.selected;
}

#pragma mark - Getter

- (UIButton *)userAgreementBtn
{
    if (_userAgreementBtn == nil) {
        _userAgreementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userAgreementBtn addTarget:self action:@selector(agreeProtocolAction:) forControlEvents:UIControlEventTouchUpInside];
        [_userAgreementBtn setImage:[UIImage imageNamed:@"agreeProtocol"] forState:UIControlStateSelected];
        [_userAgreementBtn setImage:[UIImage imageNamed:@"unAgreeProtocol"] forState:UIControlStateNormal];
        _userAgreementBtn.layer.cornerRadius = 12;
        _userAgreementBtn.userInteractionEnabled = YES;
    }
    return _userAgreementBtn;
}

- (UITextView *)linkProtocol
{
    if (_linkProtocol == nil) {
        _linkProtocol = [[UITextView alloc]init];
        _linkProtocol.userInteractionEnabled = YES;
        _linkProtocol.font = [UIFont systemFontOfSize:12.0];
        _linkProtocol.editable = NO;//必须禁止输入，否则点击将弹出输入键盘
        _linkProtocol.scrollEnabled = NO;
        _linkProtocol.delegate = self;
        _linkProtocol.textContainerInset = UIEdgeInsetsMake(0,0, 0, 0);//文本距离边界值
        _linkProtocol.textAlignment = NSTextAlignmentLeft;
        _linkProtocol.backgroundColor = [UIColor clearColor];
    }
    return _linkProtocol;
}

@end
