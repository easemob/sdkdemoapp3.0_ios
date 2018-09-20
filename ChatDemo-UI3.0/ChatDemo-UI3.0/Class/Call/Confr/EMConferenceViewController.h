//
//  EMConferenceViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMCallViewController.h"

@interface EMConferenceViewController : EMCallViewController

@property (nonatomic, strong, readonly) __block EMCallConference *conference;
@property (nonatomic, readonly) EMConferenceType type;

@property (nonatomic, strong) EMButton *switchCameraButton;
@property (nonatomic, strong) UIScrollView *scrollView;

- (instancetype)initWithType:(EMConferenceType)aType
                 inviteUsers:(NSArray *)aInviteUsers;

@end
