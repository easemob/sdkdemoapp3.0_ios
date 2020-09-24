//
//  EMMsgRecordCell.m
//  EaseIM
//
//  Created by 娜塔莎 on 2019/12/9.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMMsgRecordCell.h"
#import "EMMsgImageBubbleView.h"
#import "EMMsgVideoBubbleView.h"
#import "EMMessageModel.h"

@interface EMMsgRecordCell()

@property (nonatomic, strong) EMMsgImageBubbleView *imgViewLeft;
@property (nonatomic, strong) EMMsgImageBubbleView *imgViewLeft_mid;
@property (nonatomic, strong) EMMsgImageBubbleView *imgViewRight_mid;
@property (nonatomic, strong) EMMsgImageBubbleView *imgViewRight;

@property (nonatomic, strong) UIView *shadowView;

@property (nonatomic) CGFloat width;

@end

@implementation EMMsgRecordCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupSubviews];
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor whiteColor];
        self.selectedBackgroundView = view;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.shadowView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.shadowView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
}

- (void)_setupSubviews
{
    _width = ([UIScreen mainScreen].bounds.size.width - 6) / 4;
    _imgViewLeft = [[EMMsgImageBubbleView alloc] init];
    _imgViewLeft.contentMode = UIViewContentModeScaleToFill;
    _imgViewLeft.backgroundColor = [UIColor clearColor];
    _imgViewLeft.userInteractionEnabled = YES;
    _imgViewLeft.clipsToBounds = YES;
    [self.contentView addSubview:_imgViewLeft];
    [_imgViewLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.contentView);
        make.width.height.mas_equalTo(_width);
    }];
    
    _imgViewLeft_mid = [[EMMsgImageBubbleView alloc] init];
    _imgViewLeft_mid.contentMode = UIViewContentModeScaleToFill;
    _imgViewLeft_mid.backgroundColor = [UIColor clearColor];
    _imgViewLeft_mid.userInteractionEnabled = YES;
    _imgViewLeft_mid.clipsToBounds = YES;
    [self.contentView addSubview:_imgViewLeft_mid];
    [_imgViewLeft_mid mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgViewLeft.mas_right).equalTo(@2);
        make.top.bottom.equalTo(self.contentView);
        make.width.height.mas_equalTo(_width);
    }];
    
    _imgViewRight_mid = [[EMMsgImageBubbleView alloc] init];
    _imgViewRight_mid.contentMode = UIViewContentModeScaleToFill;
    _imgViewRight_mid.backgroundColor = [UIColor clearColor];
    _imgViewRight_mid.userInteractionEnabled = YES;
    _imgViewRight_mid.clipsToBounds = YES;
    [self.contentView addSubview:_imgViewRight_mid];
    [_imgViewRight_mid mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgViewLeft_mid.mas_right).equalTo(@2);
        make.top.bottom.equalTo(self.contentView);
        make.width.height.mas_equalTo(_width);
    }];
    
    _imgViewRight = [[EMMsgImageBubbleView alloc] init];
    _imgViewRight.contentMode = UIViewContentModeScaleToFill;
    _imgViewRight.backgroundColor = [UIColor clearColor];
    _imgViewRight.userInteractionEnabled = YES;
    _imgViewRight.clipsToBounds = YES;
    [self.contentView addSubview:_imgViewRight];
    [_imgViewRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self.contentView);
        make.width.height.mas_equalTo(_width);
    }];
    
}

#pragma mark - Setter

- (void)setModels:(NSArray *)models
{
    _models = models;
    EMMessageModel *model;
    for (int i = 0; i < [models count]; ++i) {
        model = models[i];
        [self setImageView:(self.imgViewLeft) model:model tag:i];
    }
}

- (void)setImageView:(EMMsgImageBubbleView *)imgView model:(EMMessageModel *)model tag:(NSInteger)tag
{
    imgView.model = model;
    if (model.type == EMMessageTypeImage) {
        EMImageMessageBody *body = (EMImageMessageBody *)model.emModel.body;
        NSString *imgPath = body.thumbnailLocalPath;
        if ([imgPath length] == 0) {
            imgPath = body.localPath;
        }
        [imgView setThumbnailImageWithLocalPath:imgPath remotePath:body.thumbnailRemotePath thumbImgSize:body.thumbnailSize imgSize:body.size];
        [imgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(_width);
        }];
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTouchAction:)];
        [imgView setTag:tag];
        [imgView addGestureRecognizer:imageTap];
    } else if (model.type == EMMessageTypeVideo) {
        EMVideoMessageBody *body = (EMVideoMessageBody *)model.emModel.body;
        NSString *imgPath = body.thumbnailLocalPath;
        if ([imgPath length] == 0) {
            imgPath = body.localPath;
        }
        [imgView setThumbnailImageWithLocalPath:imgPath remotePath:body.thumbnailRemotePath thumbImgSize:body.thumbnailSize imgSize:body.thumbnailSize];
        [imgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(_width);
        }];
        UITapGestureRecognizer *videoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoDidTouchAction:)];
        [imgView setTag:tag];
        [imgView addGestureRecognizer:videoTap];
        
        UIImageView *playImgView;
        self.shadowView = [[UIView alloc] init];
        self.shadowView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
        [imgView addSubview:self.shadowView];
        [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(imgView);
        }];
        
        playImgView = [[UIImageView alloc] init];
        playImgView.image = [UIImage imageNamed:@"msg_video_white"];
        playImgView.contentMode = UIViewContentModeScaleAspectFill;
        [imgView addSubview:playImgView];
        [playImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(imgView);
            make.width.height.equalTo(@50);
        }];
    }
}

#pragma mark - Action

- (void)imageDidTouchAction:(UIGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewDidTouch:)]) {
        [self.delegate imageViewDidTouch:[self getMsgModel:sender.view.tag]];
    }
}

- (void)videoDidTouchAction:(UIGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewDidTouch:)]) {
        [self.delegate videoViewDidTouch:[self getMsgModel:sender.view.tag]];
    }
}

- (EMMessageModel *)getMsgModel:(NSInteger)tag
{
    return self.models[tag];
}
@end
