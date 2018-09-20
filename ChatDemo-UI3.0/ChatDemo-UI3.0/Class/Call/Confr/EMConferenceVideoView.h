//
//  EMConferenceVideoView.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    StreamStatusNormal = 0,
    StreamStatusConnecting,
    StreamStatusConnected,
    StreamStatusTalking,
    StreamStatusAudioMuted,
} StreamStatus;

@interface EMConferenceVideoView : UIView

@property (nonatomic, strong) UIImageView *bgView;

@property (nonatomic, strong) UIView *displayView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic) StreamStatus status;

@property (nonatomic) BOOL enableVideo;

@end


@interface EMConferenceVideoItem : NSObject

@property (nonatomic, strong) EMCallStream *stream;

@property (nonatomic, strong) EMConferenceVideoView *videoView;

@end
