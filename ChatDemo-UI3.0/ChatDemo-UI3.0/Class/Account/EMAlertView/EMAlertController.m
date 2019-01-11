//
//  EMAlertController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/24.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMAlertController.h"

@interface EMAlertController()

@property (nonatomic, strong) UIView *mainView;

@end

@implementation EMAlertController

- (instancetype)initWithStyle:(EMAlertViewStyle)aStyle
                      message:(NSString *)aMessage
{
    self = [super init];
    if (self) {
        [self _setupWithStyle:aStyle message:aMessage];
    }
    
    return self;
}

- (void)_setupWithStyle:(EMAlertViewStyle)aStyle
                message:(NSString *)aMessage
{
    self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.1];
    
    self.mainView = [[UIView alloc] init];
    self.mainView.backgroundColor = [UIColor whiteColor];
    self.mainView.layer.cornerRadius = 5.0;
    self.mainView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.mainView.layer.shadowOffset = CGSizeMake(2, 5);
    self.mainView.layer.shadowOpacity = 0.5;
    [self addSubview:self.mainView];
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(-60);
        make.centerX.equalTo(self);
        make.left.greaterThanOrEqualTo(self).offset(30);
    }];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.clipsToBounds = YES;
    bgView.layer.cornerRadius = 5.0;
    [self.mainView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.mainView);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [self _tagColorWithStyle:aStyle];
    [bgView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView);
        make.bottom.equalTo(bgView);
        make.left.equalTo(bgView);
        make.width.equalTo(@3);
    }];
    
    UIImageView *tagView = [[UIImageView alloc] init];
    tagView.image = [self _tagImageWithStyle:aStyle];
    [bgView addSubview:tagView];
    [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bgView);
        make.left.equalTo(bgView).offset(15);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 5;
    label.font = [UIFont systemFontOfSize:16];
    label.text = aMessage;
    [bgView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tagView.mas_right).offset(10);
        make.right.equalTo(bgView).offset(-15);
        make.top.equalTo(bgView).offset(12);
        make.bottom.equalTo(bgView).offset(-12);
    }];
}

- (UIColor *)_tagColorWithStyle:(EMAlertViewStyle)aStyle
{
    UIColor *color = kColor_Blue;
    switch (aStyle) {
        case EMAlertViewStyleError:
            color = [UIColor colorWithRed:204 / 255.0 green:58 / 255.0 blue:35 / 255.0 alpha:1.0];
            break;
        case EMAlertViewStyleInfo:
            color = [UIColor colorWithRed:232 / 255.0 green:192 / 255.0 blue:64 / 255.0 alpha:1.0];
            break;
        case EMAlertViewStyleSuccess:
            color = [UIColor colorWithRed:35 / 255.0 green:158 / 255.0 blue:85 / 255.0 alpha:1.0];
            break;
            
        default:
            break;
    }
    
    return color;
}

- (UIImage *)_tagImageWithStyle:(EMAlertViewStyle)aStyle
{
    NSString *imageName = @"alert_default";
    switch (aStyle) {
        case EMAlertViewStyleError:
            imageName = @"alert_error";
            break;
        case EMAlertViewStyleInfo:
            imageName = @"alert_info";
            break;
        case EMAlertViewStyleSuccess:
            imageName = @"alert_success";
            break;
            
        default:
            break;
    }
    
    return [UIImage imageNamed:imageName];
}

+ (void)showAlertWithStyle:(EMAlertViewStyle)aStyle
                   message:(NSString *)aMessage
{
    EMAlertController *view = [[EMAlertController alloc] initWithStyle:aStyle message:aMessage];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(keyWindow);
    }];
    
    [view layoutIfNeeded];
    [view setNeedsUpdateConstraints];
    [view.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(50);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        //
    }];
    
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [view layoutIfNeeded];
        [view setNeedsUpdateConstraints];
        [view.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(view).offset(-60);
        }];
        [UIView animateWithDuration:0.3 animations:^{
            [view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    });
}

+ (void)showErrorAlert:(NSString *)aMessage
{
    [EMAlertController showAlertWithStyle:EMAlertViewStyleError message:aMessage];
}

+ (void)showSuccessAlert:(NSString *)aMessage
{
    [EMAlertController showAlertWithStyle:EMAlertViewStyleSuccess message:aMessage];
}

+ (void)showInfoAlert:(NSString *)aMessage
{
    [EMAlertController showAlertWithStyle:EMAlertViewStyleInfo message:aMessage];
}

@end
