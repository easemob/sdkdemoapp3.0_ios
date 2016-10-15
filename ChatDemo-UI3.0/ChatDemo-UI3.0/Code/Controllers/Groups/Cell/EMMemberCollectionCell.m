//
//  EMMemberCollectionCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/6.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMMemberCollectionCell.h"
#import "EMUserModel.h"

@interface EMMemberCollectionCell()

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIImageView *deleteImageView;
@property (strong, nonatomic) IBOutlet UILabel *nicknamLabel;

@end

@implementation EMMemberCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if ([self.reuseIdentifier isEqualToString:@"EMMemberCollection_Edit_Cell"]) {
        _deleteImageView.hidden = YES;
    }
}

- (void)setModel:(EMUserModel *)model {
    if (_deleteImageView && [self.reuseIdentifier isEqualToString:@"EMMemberCollection_Edit_Cell"]) {
        _deleteImageView.hidden = NO;
    }
    _model = model;
    if (!_model) {
        _nicknamLabel.text = @"";
        _avatarImageView.image = [UIImage imageNamed:@"Button_Add Member.png"];
        return;
    }
    _nicknamLabel.text = _model.nickname;
    _avatarImageView.image = _model.defaultAvatarImage;
    if (_model.avatarURLPath.length > 0) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:weakSelf.model.avatarURLPath]];
            if (data.length > 0) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    weakSelf.avatarImageView.image = [UIImage imageWithData:data];
                });
            }
        });
    }
}

@end
