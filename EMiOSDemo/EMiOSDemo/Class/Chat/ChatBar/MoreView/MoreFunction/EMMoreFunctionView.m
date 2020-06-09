//
//  EMMoreFunctionView.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/10/23.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMMoreFunctionView.h"
#import "HorizontalLayout.h"

@interface EMMoreFunctionView()<UICollectionViewDataSource,SessionToolbarCellDelegate>
{
    NSArray *_toolbarImgArray;
    NSArray *_toolbarDescArray;
}

@property (nonatomic,strong) UICollectionView *collectionView;

@end

@implementation EMMoreFunctionView

- (instancetype)init
{
    self = [super init];
    if(self){
        _toolbarImgArray = @[@"video_conf",@"location",@"pin_readReceipt",@"file-unSelected",@"camera-unSelected",@"pic-unSelected"];
        _toolbarDescArray = @[@"视频通话",@"位置",@"群组回执",@"文件",@"相机",@"图片"];
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
    NSInteger row = indexPath.row;
    [cell personalizeToolbar:_toolbarImgArray[row] funcDesc:_toolbarDescArray[row] tag:row];
    cell.delegate = self;
    return cell;
}

#pragma mark - SessionToolbarCellDelegate

- (void)toolbarCellDidSelected:(NSInteger)tag
{
    if (tag == 0) {
        //视频通话
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionReadReceipt)]) {
            [self.delegate chatBarMoreFunctionDidCallAction];
        }
    } else if (tag == 1) {
        //位置
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionLocation)]) {
            [self.delegate chatBarMoreFunctionLocation];
        }
    } else if (tag == 2) {
        //群组回执
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionReadReceipt)]) {
            [self.delegate chatBarMoreFunctionReadReceipt];
        }
    } else if (tag == 3) {
        //文件
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionFileOption)]) {
            [self.delegate chatBarMoreFunctionFileOption];
        }
    } else if (tag == 4) {
        //相机
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionCameraAction)]) {
            [self.delegate chatBarMoreFunctionCameraAction];
        }
    } else if (tag == 5) {
        //图片
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionPictureOption)]) {
            [self.delegate chatBarMoreFunctionPictureOption];
        }
    }
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
