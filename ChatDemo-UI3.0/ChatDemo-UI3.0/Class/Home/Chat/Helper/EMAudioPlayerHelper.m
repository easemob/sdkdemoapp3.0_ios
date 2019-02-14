//
//  EMAudioPlayerHelper.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/29.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "EMAudioPlayerHelper.h"

static EMAudioPlayerHelper *playerHelper = nil;
@interface EMAudioPlayerHelper()<AVAudioPlayerDelegate>

@property (nonatomic) BOOL isPlaying;
@property (nonatomic, strong) NSString *playingPath;

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, copy) void (^playerFinished)(NSError *error);

@end

@implementation EMAudioPlayerHelper

+ (instancetype)sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerHelper = [[EMAudioPlayerHelper alloc] init];
    });
    
    return playerHelper;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isPlaying = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [self stopPlayer];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag
{
    if (self.playerFinished) {
        self.playerFinished(nil);
    }
    
    self.playerFinished = nil;
    if (_player) {
        _player.delegate = nil;
        _player = nil;
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error
{
    if (self.playerFinished) {
        NSError *error = [NSError errorWithDomain:@"播放失败!" code:-1 userInfo:nil];
        self.playerFinished(error);
    }
    
    self.playerFinished = nil;
    if (_player) {
        _player.delegate = nil;
        _player = nil;
    }
}

#pragma mark - Public

- (void)startPlayerWithPath:(NSString *)aPath
                      model:(id)aModel
                 completion:(void(^)(NSError *error))aCompleton
{
    NSError *error = nil;
    do {
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:aPath]) {
            error = [NSError errorWithDomain:@"文件路径不存在" code:-1 userInfo:nil];
            break;
        }
        
        if (self.isPlaying && [self.playingPath isEqualToString:aPath]) {
            break;
        } else {
            [self stopPlayer];
        }
        
        self.model = aModel;
        
        NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:aPath];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:wavUrl error:&error];
        if (error || !self.player) {
            self.player = nil;
            error = [NSError errorWithDomain:@"初始化AVAudioPlayer失败" code:-1 userInfo:nil];
            break;
        }
        
        self.isPlaying = YES;
        self.playingPath = aPath;
        [self setPlayerFinished:aCompleton];
        
        self.player.delegate = self;
        [self.player prepareToPlay];
        [self.player play];
        
    } while (0);
    
    if (error) {
        if (aCompleton) {
            aCompleton(error);
        }
    }
}

- (void)stopPlayer
{
    if(_player) {
        _player.delegate = nil;
        [_player stop];
        _player = nil;
    }
    
    self.playingPath = nil;
    self.playerFinished = nil;
}

@end
