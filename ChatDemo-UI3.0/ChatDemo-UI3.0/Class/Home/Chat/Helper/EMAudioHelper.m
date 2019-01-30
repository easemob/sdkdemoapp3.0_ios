//
//  EMAudioHelper.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/29.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "EMAudioHelper.h"

static EMAudioRecordHelper *recordHelper = nil;
@interface EMAudioRecordHelper()<AVAudioRecorderDelegate>

@property (nonatomic) BOOL isRecording;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSDictionary *recordSetting;

@property (nonatomic, copy) void (^recordFinished)(NSString *aPath);

@end

@implementation EMAudioRecordHelper

+ (instancetype)sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recordHelper = [[EMAudioRecordHelper alloc] init];
    });
    
    return recordHelper;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isRecording = NO;
        
        _recordSetting = @{AVSampleRateKey:@(8000.0), AVFormatIDKey:@(kAudioFormatLinearPCM), AVLinearPCMBitDepthKey:@(16), AVNumberOfChannelsKey:@(1)};
        
    }
    
    return self;
}

- (void)dealloc
{
    [self _stopRecord];
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag
{
    NSString *recordPath = [[self.recorder url] path];
    if (self.recordFinished) {
        if (!flag) {
            recordPath = nil;
        }
        self.recordFinished(recordPath);
    }
    self.recorder = nil;
    self.recordFinished = nil;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                   error:(NSError *)error{
    NSLog(@"audioRecorderEncodeErrorDidOccur");
}

#pragma mark - Private

- (void)_stopRecord
{
    _recorder.delegate = nil;
    if (_recorder.recording) {
        [_recorder stop];
    }
    _recorder = nil;
    self.isRecording = NO;
    self.recordFinished = nil;
}

#pragma mark - Public

- (void)startRecordWithPath:(NSString *)aPath
                 completion:(void(^)(NSError *error))aCompletion
{
    NSError *error = nil;
    do {
        if (self.isRecording) {
            error = [NSError errorWithDomain:@"正在进行录制" code:-1 userInfo:nil];
            break;
        }
        
        NSString *wavPath = [[aPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
        NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:wavPath];
        self.recorder = [[AVAudioRecorder alloc] initWithURL:wavUrl settings:self.recordSetting error:&error];
        if(error || !self.recorder) {
            self.recorder = nil;
            error = [NSError errorWithDomain:@"文件格式转换失败" code:-1 userInfo:nil];
            break;
        }
        
        self.isRecording = YES;
        self.startDate = [NSDate date];
        self.recorder.meteringEnabled = YES;
        self.recorder.delegate = self;
        [self.recorder record];
        
    } while (0);
    
    if (aCompletion) {
        aCompletion(error);
    }
}

-(void)stopRecordWithCompletion:(void(^)(NSString *aPath))aCompletion
{
    self.recordFinished = aCompletion;
    [self.recorder stop];
}

-(void)cancelRecord
{
    [self _stopRecord];
    self.startDate = nil;
    self.endDate = nil;
}

@end


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
