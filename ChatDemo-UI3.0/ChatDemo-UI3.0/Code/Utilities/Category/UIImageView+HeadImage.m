//
//  UIImageView+HeadImage.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 2016/11/4.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "UIImageView+HeadImage.h"
#import "EMUserProfileManager.h"

@implementation UIImageView (HeadImage)

- (void)imageWithUsername:(NSString *)username placeholderImage:(UIImage*)placeholderImage
{
    if (placeholderImage == nil) {
        placeholderImage = [UIImage imageNamed:@"default_avatar"];
    }
    UserProfileEntity *profileEntity = [[EMUserProfileManager sharedInstance] getUserProfileByUsername:username];
    if (profileEntity) {
        [self sd_setImageWithURL:[NSURL URLWithString:profileEntity.imageUrl] placeholderImage:placeholderImage];
    } else {
        [self sd_setImageWithURL:nil placeholderImage:placeholderImage];
    }
}
@end
