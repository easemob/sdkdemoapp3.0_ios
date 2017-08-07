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
- (void)tapUserView:(NSString *)aUserName;

@end

@interface EMConfUserView : UIView

@property (weak, nonatomic) id<EMConfUserViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@interface ConferenceViewController : UIViewController

@property (nonatomic, readonly) EMCallType type;

- (instancetype)initWithCallId:(NSString *)aCallId
                       creater:(NSString *)aCreater
                    otherUsers:(NSArray *)aOthers
                          type:(EMCallType)aType
conversationId:(NSString *)aConversationId;

- (instancetype)initWithUsers:(NSArray *)aUserNams
                         type:(EMCallType)aType
               conversationId:(NSString *)aConversationId;

@end
