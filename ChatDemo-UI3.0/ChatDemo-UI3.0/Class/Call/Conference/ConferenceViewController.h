//
//  ConferenceViewController.h
//  IosDemo
//
//  Created by XieYajie on 4/26/16.
//  Copyright © 2016 dxstudio.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EMConfUserViewDelegate <NSObject>

@optional
- (void)tapUserViewWithStreamId:(NSString *)aStreamId;

@end

@interface EMConfUserView : UIView

@property (weak, nonatomic) id<EMConfUserViewDelegate> delegate;
@property (strong, nonatomic) NSString *viewId;

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@interface ConferenceViewController : UIViewController

- (instancetype)initWithConferenceId:(NSString *)aConfId
                             creater:(NSString *)aCreater;

- (instancetype)initVideoCallWithIsCustomData:(BOOL)aIsCustom;

@end
