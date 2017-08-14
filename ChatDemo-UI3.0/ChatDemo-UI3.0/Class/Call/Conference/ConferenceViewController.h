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

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@interface ConferenceViewController : UIViewController

@property (nonatomic, readonly) EMCallType type;

- (instancetype)initWithConferenceId:(NSString *)aConfId
                             creater:(NSString *)aCreater
                                type:(EMCallType)aType;

- (instancetype)initWithType:(EMCallType)aType;

@end
