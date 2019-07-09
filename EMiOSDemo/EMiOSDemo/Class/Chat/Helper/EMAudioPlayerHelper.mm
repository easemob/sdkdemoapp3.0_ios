//
//  EMAudioPlayerHelper.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/29.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "EMAudioPlayerHelper.h"

#import "amrFileCodec.h"

static EMAudioPlayerHelper *playerHelper = nil;
@interface EMAudioPlayerHelper()<AVAudioPlayerDelegate>

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

#pragma mark - Private

+ (int)isMP3File:(NSString *)aFilePath
{
    const char *filePath = [aFilePath cStringUsingEncoding:NSASCIIStringEncoding];
    return isMP3File(filePath);
}

+ (int)amrToWav:(NSString*)aAmrPath wavSavePath:(NSString*)aWavPath
{
    
    if (EM_DecodeAMRFileToWAVEFile([aAmrPath cStringUsingEncoding:NSASCIIStringEncoding], [aWavPath cStringUsingEncoding:NSASCIIStringEncoding]))
        return 0; // success
    
    return 1;   // failed
}

- (NSString *)_convertAudioFile:(NSString *)aPath
{
    if ([[aPath pathExtension] isEqualToString:@"mp3"]) {
        return aPath;
    }
    
    NSString *retPath = [[aPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
    do {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:retPath]) {
            break;
        }
        
        if ([EMAudioPlayerHelper isMP3File:retPath]) {
            retPath = aPath;
            break;
        }
        
        [EMAudioPlayerHelper amrToWav:aPath wavSavePath:retPath];
        if (![fileManager fileExistsAtPath:retPath]) {
            retPath = nil;
        }
        
    } while (0);
    
    return retPath;
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
        
        if (self.player && self.player.isPlaying && [self.playingPath isEqualToString:aPath]) {
            break;
        } else {
            [self stopPlayer];
        }
        
        aPath = [self _convertAudioFile:aPath];
        if ([aPath length] == 0) {
            error = [NSError errorWithDomain:@"转换音频格式失败" code:-1 userInfo:nil];
            break;
        }
        
        self.model = aModel;
        
        NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:aPath];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:wavUrl error:&error];
        if (error || !self.player) {
            self.player = nil;
            error = [NSError errorWithDomain:@"初始化AVAudioPlayer失败" code:-1 userInfo:nil];
            break;
        }
        
        self.playingPath = aPath;
        [self setPlayerFinished:aCompleton];
        
        self.player.delegate = self;
        BOOL ret = [self.player prepareToPlay];
        if (ret) {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
            if (error) {
                break;
            }
        }
        
        ret = [self.player play];
        if (!ret) {
            [self stopPlayer];
            error = [NSError errorWithDomain:@"AVAudioPlayer播放失败" code:-1 userInfo:nil];
        }
        
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
