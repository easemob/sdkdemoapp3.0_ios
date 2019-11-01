//
//  EMChatBarEmoticonView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/30.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatBarEmoticonView.h"

#import "EMEmojiHelper.h"

@interface EMChatBarEmoticonView()<EMEmoticonViewDelegate>

@property (nonatomic) CGFloat bottomHeight;

@property (nonatomic, strong) NSMutableArray<EMEmoticonGroup *> *groups;
@property (nonatomic, strong) NSMutableArray<EMEmoticonView *> *emotionViews;
@property (nonatomic, strong) NSMutableArray<UIButton *> *emotionButtons;
@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, strong) UIView *emotionBgView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIScrollView *bottomScrollView;
@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation EMChatBarEmoticonView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initDataSource];
        [self _setupSubviews];
        [self segmentedButtonAction:self.emotionButtons[0]];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self _setupBottomView];
    [self _setupEmotionViews];
}

- (void)_setupBottomView
{
    CGFloat itemWidth = 60;
    NSInteger count = [self.groups count];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = kColor_LightGray;
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(self.bottomHeight);
    }];
    
    self.sendButton = [[UIButton alloc] init];
    self.sendButton.backgroundColor = kColor_Blue;
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.bottomScrollView = [[UIScrollView alloc] init];
    self.bottomScrollView.scrollEnabled = NO;
    self.bottomScrollView.backgroundColor = kColor_LightGray;
    self.bottomScrollView.contentSize = CGSizeMake(itemWidth * count, self.bottomHeight);
    [self addSubview:self.bottomScrollView];
    [self.bottomScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    for (int i = 0; i < count; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = i;
        [button addTarget:self action:@selector(segmentedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomScrollView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bottomView);
            make.left.equalTo(self.bottomView).offset(i * itemWidth);
            make.width.mas_equalTo(itemWidth);
            make.height.mas_equalTo(self.bottomHeight);
        }];
        
        id icon = [self.groups[i] icon];
        if ([icon isKindOfClass:[UIImage class]]) {
            button.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
            button.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [button setImage:(UIImage *)icon forState:UIControlStateNormal];
        } else if ([icon isKindOfClass:[NSString class]]) {
            button.titleLabel.font = [UIFont fontWithName:@"AppleColorEmoji" size:18.0];
            [button setTitle:(NSString *)icon forState:UIControlStateNormal];
        }
        [self.emotionButtons addObject:button];
    }
}

- (void)_setupEmotionViews
{
    self.emotionBgView = [[UIView alloc] init];
    self.emotionBgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.emotionBgView];
    [self.emotionBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    
    NSInteger count = [self.groups count];
    for (int i = 0; i < count; i++) {
        EMEmoticonView *view = [[EMEmoticonView alloc] initWithEmotionGroup:self.groups[i]];
        view.delegate = self;
        view.viewHeight = self.viewHeight - self.bottomHeight;
        [self.emotionViews addObject:view];
    }
}

#pragma mark - Data

- (void)_initDataSource
{
    _viewHeight = 200;
    _bottomHeight = 40;
    self.groups = [[NSMutableArray alloc] init];
    self.emotionViews = [[NSMutableArray alloc] init];
    self.emotionButtons = [[NSMutableArray alloc] init];
    
    NSArray *emojis = [EMEmojiHelper getAllEmojis];
    NSMutableArray *models1 = [[NSMutableArray alloc] init];
    for (NSString *emoji in emojis) {
        EMEmoticonModel *model = [[EMEmoticonModel alloc] initWithType:EMEmotionTypeEmoji];
        model.eId = emoji;
        model.name = emoji;
        model.original = emoji;
        [models1 addObject:model];
    }
    NSString *tagImgName = [models1[0] name];
    EMEmoticonGroup *group1 = [[EMEmoticonGroup alloc] initWithType:EMEmotionTypeEmoji dataArray:models1 icon:tagImgName rowCount:3 colCount:7];
    [self.groups addObject:group1];
    
    [self.groups addObject:[EMEmoticonGroup getGifGroup]];
}

#pragma mark - EMEmoticonViewDelegate

- (void)emoticonViewDidSelectedModel:(EMEmoticonModel *)aModel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedEmoticonModel:)]) {
        [self.delegate didSelectedEmoticonModel:aModel];
    }
}

#pragma mark - Action

- (void)segmentedButtonAction:(UIButton *)aButton
{
    NSInteger tag = aButton.tag;
    if (self.selectedButton && self.selectedButton.tag == tag) {
        return;
    }
    
    if (self.selectedButton) {
        EMEmoticonView *oldView = self.emotionViews[self.selectedButton.tag];
        [oldView removeFromSuperview];
        
        self.selectedButton.selected = NO;
        self.selectedButton.backgroundColor = kColor_LightGray;
        self.selectedButton = nil;
    }
    
    aButton.selected = YES;
    aButton.backgroundColor = [UIColor whiteColor];
    self.selectedButton = aButton;
    
    if (tag == 0) {
        [self.bottomView addSubview:self.sendButton];
        [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bottomView);
            make.right.equalTo(self.bottomView);
            make.height.mas_equalTo(self.bottomHeight);
            make.width.equalTo(@75);
        }];
        [self.bottomScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self.sendButton.mas_left);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(self.bottomHeight);
        }];
    } else {
        [self.sendButton removeFromSuperview];
        [self.bottomScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    //TODO:code
    EMEmoticonView *view = self.emotionViews[tag];
    [self.emotionBgView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.emotionBgView);
    }];
}

- (void)sendAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChatBarEmoticonViewSendAction)]) {
        [self.delegate didChatBarEmoticonViewSendAction];
    }
}

@end
