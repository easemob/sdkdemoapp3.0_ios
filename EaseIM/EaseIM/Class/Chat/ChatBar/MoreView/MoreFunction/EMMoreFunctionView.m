//
//  EMMoreFunctionView.m
//  EaseIM
//
//  Created by 娜塔莎 on 2019/10/23.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMMoreFunctionView.h"
#import "HorizontalLayout.h"

@interface EMMoreFunctionView()<UICollectionViewDataSource,SessionToolbarCellDelegate>
{
    NSMutableArray *_toolbarImgArray;
    NSMutableArray *_toolbarDescArray;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) EMConversation *conversation;

@end

@implementation EMMoreFunctionView

- (instancetype)initWithConversation:(EMConversation *)conversation
{
    self = [super init];
    if(self){
        _conversation = conversation;
        //_toolbarImgArray = @[@"video_conf",@"location",@"pin_readReceipt",@"icloudFile",@"camera",@"photo-album"];
        //_toolbarDescArray = @[@"视频通话",@"位置",@"群组回执",@"文件",@"相机",@"相册"];
        _toolbarImgArray = [NSMutableArray arrayWithArray:@[@"photo-album",@"camera",@"video_conf",@"location",@"icloudFile"]];
        _toolbarDescArray = [NSMutableArray arrayWithArray:@[@"相册",@"相机",@"音视频",@"位置",@"文件"]];
        if (_conversation.type == EMConversationTypeGroupChat) {
            if ([[EMClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:_conversation.conversationId error:nil].owner isEqualToString:EMClient.sharedClient.currentUsername]) {
                [_toolbarImgArray addObject:@"pin_readReceipt"];
                [_toolbarDescArray addObject:@"群组回执"];
            }
        }
        if (_conversation.type == EMConversationTypeChatRoom) {
            [_toolbarImgArray removeObject:@"video_conf"];
            [_toolbarDescArray removeObject:@"音视频"];
        }
        self.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
        [self _setupUI];
    }
    
    return self;
}

- (void)_setupUI {
    NSInteger count = 17;
    CGFloat width = [UIScreen mainScreen].bounds.size.width / count;
    HorizontalLayout *layout = [[HorizontalLayout alloc] init];
    layout.itemSize = CGSizeMake(width * 3, 63.f);
    layout.rowCount = 4;
    layout.columCount = 2;
    layout.sectionInset = UIEdgeInsetsMake(8, 0, 0, 0);
    layout.minimumLineSpacing = width;
    layout.minimumInteritemSpacing = 8;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 150.f) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    [self addSubview:self.collectionView];
    
    [self.collectionView registerClass:[SessionToolbarCell class] forCellWithReuseIdentifier:@"cell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_toolbarImgArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SessionToolbarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSInteger row = indexPath.row;;
    [cell personalizeToolbar:(NSString *)[_toolbarImgArray objectAtIndex:row] funcDesc:[_toolbarDescArray objectAtIndex:row] tag:row];
    cell.delegate = self;
    return cell;
}

#pragma mark - SessionToolbarCellDelegate

- (void)toolbarCellDidSelected:(NSInteger)tag
{
    if (tag == 5) {
        //群组回执
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionReadReceipt)])
            [self.delegate chatBarMoreFunctionReadReceipt];
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionAction:)])
        [self.delegate chatBarMoreFunctionAction:tag];
}

@end


@interface SessionToolbarCell()
{
    NSInteger _tag;
}

@property (nonatomic, strong) UIButton *toolBtn;

@property (nonatomic, strong) UILabel *toolLabel;

@end

@implementation SessionToolbarCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setupToolbar];
        _tag = -1;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)_setupToolbar {
    NSInteger count = 17;
    CGFloat width = [UIScreen mainScreen].bounds.size.width / count;
    NSLog(@"\n    ===== width:    %f",width);
    self.toolBtn = [[UIButton alloc]init];
    self.toolBtn.layer.cornerRadius = 8;
    self.toolBtn.layer.masksToBounds = YES;
    self.toolBtn.imageEdgeInsets = UIEdgeInsetsMake(2, 10, 2, 10);
    [self.toolBtn addTarget:self action:@selector(cellTapAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.toolBtn];
    self.toolBtn.backgroundColor = [UIColor whiteColor];
    [self.toolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(width * 3);
        make.height.equalTo(@50);
        make.left.equalTo(self.contentView);
    }];
    
    self.toolLabel = [[UILabel alloc]init];
    self.toolLabel.textColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1.0];
    
    [self.toolLabel setFont:[UIFont systemFontOfSize:10.0]];
    self.toolLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.toolLabel];
    [self.toolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolBtn.mas_bottom).offset(3);
        make.width.mas_equalTo(width * 3);
        make.height.equalTo(@10);
        make.left.equalTo(self.contentView);
    }];
}

- (void)personalizeToolbar:(NSString *)imgName funcDesc:(NSString *)funcDesc tag:(NSInteger)tag
{
    [_toolBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [_toolLabel setText:funcDesc];
    _tag = tag;
}

#pragma mark - Action

- (void)cellTapAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarCellDidSelected:)]) {
        [self.delegate toolbarCellDidSelected:_tag];
    }
}

@end
