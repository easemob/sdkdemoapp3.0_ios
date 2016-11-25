//
//  ConferenceViewController.h
//  IosDemo
//
//  Created by XieYajie on 4/26/16.
//  Copyright © 2016 dxstudio.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMConfUserVoiceView : UIView

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@interface ConferenceViewController : UIViewController

@property (nonatomic, readonly) EMCallType type;

- (instancetype)initWithCallId:(NSString *)aCallId
                       creater:(NSString *)aCreater
                          type:(EMCallType)aType;

- (instancetype)initWithUsers:(NSArray *)aUserNams
                         type:(EMCallType)aType;

@end
