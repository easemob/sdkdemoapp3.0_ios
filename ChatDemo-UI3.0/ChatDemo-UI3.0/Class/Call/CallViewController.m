/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "CallViewController.h"

#define kAlertViewTag_Close 100

@interface CallViewController (){
    NSString * _audioCategory;
    
    UIView *_propertyView;
    UILabel *_sizeLabel;
    UILabel *_timedelayLabel;
    UILabel *_framerateLabel;
    UILabel *_lostcntLabel;
    UILabel *_remoteBitrateLabel;
    UILabel *_localBitrateLabel;
    NSTimer *_propertyTimer;
}

@end

@implementation CallViewController

- (instancetype)initWithSession:(EMCallSession *)session
                     isIncoming:(BOOL)isIncoming
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _callSession = session;
        _isIncoming = isIncoming;
        _timeLabel.text = @"";
        _timeLength = 0;
        _chatter = session.sessionChatter;
        
        [[EaseMob sharedInstance].callManager removeDelegate:self];
        [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
        
        g_callCenter = [[CTCallCenter alloc] init];
        g_callCenter.callEventHandler=^(CTCall* call)
        {
            if(call.callState == CTCallStateIncoming)
            {
                NSLog(@"Call is incoming");
                [_timeTimer invalidate];
                [self _stopRing];
                
                [[EaseMob sharedInstance].callManager asyncEndCall:_callSession.sessionId reason:eCallReasonHangup];
                [self _close];
            }
        };

    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _setupSubviews];
    
    _nameLabel.text = _chatter;
    if (_callSession.type == eCallSessionTypeVideo) {
        [self _initializeCamera];
        [_session startRunning];
        [self.view addGestureRecognizer:self.tapRecognizer];
        [self.view bringSubviewToFront:_topView];
        [self.view bringSubviewToFront:_actionView];
        
#warning 要提前设置视频通话对方图像的显示区域
        _callSession.displayView = _openGLView;
    }
    
    if (_isIncoming) {
        _statusLabel.text = NSLocalizedString(@"call.waiting", @"Waiting to answer...");
        [_actionView addSubview:_answerButton];
        [_actionView addSubview:_rejectButton];
    }
    else{
        _statusLabel.text = NSLocalizedString(@"call.connecting", @"Connecting...");
        [_actionView addSubview:_hangupButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (_session) {
        [_session stopRunning];
        [_session removeInput:_captureInput];
        [_session removeOutput:_captureOutput];
        _session = nil;
    }
    
    if (_ringPlayer) {
        [_ringPlayer stop];
        _ringPlayer = nil;
    }
    
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    
    if (_propertyTimer) {
        [_propertyTimer invalidate];
        _propertyTimer = nil;
    }
    
    if (_smallView) {
        [_smallCaptureLayer removeFromSuperlayer];
        _smallCaptureLayer = nil;
        _smallView = nil;
    }
    
    if (_propertyView) {
        _propertyView = nil;
    }
    
    if (_openGLView) {
        _openGLView = nil;
    }
    
    if (_imageDataBuffer) {
        free(_imageDataBuffer);
        _imageDataBuffer = nil;
    }
    
    [[EaseMob sharedInstance].callManager removeDelegate:self];
}

#pragma mark - getter

- (BOOL)isShowCallInfo
{
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:@"showCallInfo"];
    return [object boolValue];
}

#pragma makr - property

- (UITapGestureRecognizer *)tapRecognizer
{
    if (_tapRecognizer == nil) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapAction:)];
    }
    
    return _tapRecognizer;
}

#pragma mark - subviews

- (void)_setupSubviews
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    bgImageView.contentMode = UIViewContentModeScaleToFill;
    bgImageView.image = [UIImage imageNamed:@"callBg.png"];
    [self.view addSubview:bgImageView];
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    _topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_topView];
    
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, _topView.frame.size.width - 20, 20)];
    _statusLabel.font = [UIFont systemFontOfSize:15.0];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [_topView addSubview:self.statusLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_statusLabel.frame), _topView.frame.size.width, 15)];
    _timeLabel.font = [UIFont systemFontOfSize:12.0];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [_topView addSubview:_timeLabel];
    
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((_topView.frame.size.width - 50) / 2, CGRectGetMaxY(_statusLabel.frame) + 20, 50, 50)];
    _headerImageView.image = [UIImage imageNamed:@"chatListCellHead"];
    [_topView addSubview:_headerImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerImageView.frame) + 5, _topView.frame.size.width, 20)];
    _nameLabel.font = [UIFont systemFontOfSize:14.0];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.text = _chatter;
    [_topView addSubview:_nameLabel];
    
    _actionView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 180, self.view.frame.size.width, 180)];
    _actionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_actionView];

    CGFloat tmpWidth = _actionView.frame.size.width / 2;
    _silenceButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth - 40) / 2, 20, 40, 40)];
    [_silenceButton setImage:[UIImage imageNamed:@"call_silence"] forState:UIControlStateNormal];
    [_silenceButton setImage:[UIImage imageNamed:@"call_silence_h"] forState:UIControlStateSelected];
    [_silenceButton addTarget:self action:@selector(silenceAction) forControlEvents:UIControlEventTouchUpInside];
    
    _silenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(_silenceButton.frame) + 5, tmpWidth - 60, 20)];
    _silenceLabel.backgroundColor = [UIColor clearColor];
    _silenceLabel.textColor = [UIColor whiteColor];
    _silenceLabel.font = [UIFont systemFontOfSize:13.0];
    _silenceLabel.textAlignment = NSTextAlignmentCenter;
    _silenceLabel.text = NSLocalizedString(@"call.silence", @"Silence");
    
    _speakerOutButton = [[UIButton alloc] initWithFrame:CGRectMake(tmpWidth + (tmpWidth - 40) / 2, _silenceButton.frame.origin.y, 40, 40)];
    [_speakerOutButton setImage:[UIImage imageNamed:@"call_out"] forState:UIControlStateNormal];
    [_speakerOutButton setImage:[UIImage imageNamed:@"call_out_h"] forState:UIControlStateSelected];
    [_speakerOutButton addTarget:self action:@selector(speakerOutAction) forControlEvents:UIControlEventTouchUpInside];
    
    _speakerOutLabel = [[UILabel alloc] initWithFrame:CGRectMake(tmpWidth + 30, CGRectGetMaxY(_speakerOutButton.frame) + 5, tmpWidth - 60, 20)];
    _speakerOutLabel.backgroundColor = [UIColor clearColor];
    _speakerOutLabel.textColor = [UIColor whiteColor];
    _speakerOutLabel.font = [UIFont systemFontOfSize:13.0];
    _speakerOutLabel.textAlignment = NSTextAlignmentCenter;
    _speakerOutLabel.text = NSLocalizedString(@"call.speaker", @"Speaker");
    
    _rejectButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth - 100) / 2, CGRectGetMaxY(_speakerOutLabel.frame) + 30, 100, 40)];
    [_rejectButton setTitle:NSLocalizedString(@"call.reject", @"Reject") forState:UIControlStateNormal];
    [_rejectButton setBackgroundColor:[UIColor colorWithRed:191 / 255.0 green:48 / 255.0 blue:49 / 255.0 alpha:1.0]];;
    [_rejectButton addTarget:self action:@selector(rejectAction) forControlEvents:UIControlEventTouchUpInside];
    
    _answerButton = [[UIButton alloc] initWithFrame:CGRectMake(tmpWidth + (tmpWidth - 100) / 2, _rejectButton.frame.origin.y, 100, 40)];
    [_answerButton setTitle:NSLocalizedString(@"call.answer", @"Answer") forState:UIControlStateNormal];
    [_answerButton setBackgroundColor:[UIColor colorWithRed:191 / 255.0 green:48 / 255.0 blue:49 / 255.0 alpha:1.0]];;
    [_answerButton addTarget:self action:@selector(answerAction) forControlEvents:UIControlEventTouchUpInside];
    
    _hangupButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200) / 2, _rejectButton.frame.origin.y, 200, 40)];
    [_hangupButton setTitle:NSLocalizedString(@"call.hangup", @"Hangup") forState:UIControlStateNormal];
    [_hangupButton setBackgroundColor:[UIColor colorWithRed:191 / 255.0 green:48 / 255.0 blue:49 / 255.0 alpha:1.0]];;
    [_hangupButton addTarget:self action:@selector(hangupAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)_initializeCamera
{
    //1.大窗口显示层
    _openGLView = [[OpenGLView20 alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _openGLView.backgroundColor = [UIColor clearColor];
    _openGLView.sessionPreset = AVCaptureSessionPreset352x288;
    [self.view addSubview:_openGLView];
    
    //2.小窗口视图
    CGFloat width = 80;
    CGFloat height = _openGLView.frame.size.height / _openGLView.frame.size.width * width;
    _smallView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 90, CGRectGetMaxY(_statusLabel.frame), width, height)];
    _smallView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_smallView];
    
    //3.创建会话层
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:_openGLView.sessionPreset];
    
    //4.创建、配置输入设备
    AVCaptureDevice *device;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *tmp in devices)
    {
        if (tmp.position == AVCaptureDevicePositionFront)
        {
            device = tmp;
            break;
        }
    }
    
    NSError *error = nil;
    _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [_session beginConfiguration];
    if(!error){
        [_session addInput:_captureInput];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error") message:error.localizedFailureReason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    //5.创建、配置输出
    _captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    _captureOutput.videoSettings = _openGLView.outputSettings;
//    [[_captureOutput connectionWithMediaType:AVMediaTypeVideo] setVideoMinFrameDuration:CMTimeMake(1, 15)];
    _captureOutput.minFrameDuration = CMTimeMake(1, 15);
//    _captureOutput.minFrameDuration = _openGLView.videoMinFrameDuration;
    _captureOutput.alwaysDiscardsLateVideoFrames = YES;
    dispatch_queue_t outQueue = dispatch_queue_create("com.gh.cecall", NULL);
    [_captureOutput setSampleBufferDelegate:self queue:outQueue];
    [_session addOutput:_captureOutput];
    [_session commitConfiguration];
    
    //6.小窗口显示层
    _smallCaptureLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _smallCaptureLayer.frame = CGRectMake(0, 0, width, height);
    _smallCaptureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_smallView.layer addSublayer:_smallCaptureLayer];
    
    //7、属性显示层
    _propertyView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMinY(_actionView.frame) - 90, self.view.frame.size.width - 20, 90)];
    _propertyView.backgroundColor = [UIColor clearColor];
    _propertyView.hidden = ![self isShowCallInfo];
    [self.view addSubview:_propertyView];
    
    width = (CGRectGetWidth(_propertyView.frame) - 20) / 2;
    height = CGRectGetHeight(_propertyView.frame) / 3;
    _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _sizeLabel.backgroundColor = [UIColor clearColor];
    _sizeLabel.textColor = [UIColor redColor];
    [_propertyView addSubview:_sizeLabel];
    
    _timedelayLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, 0, width, height)];
    _timedelayLabel.backgroundColor = [UIColor clearColor];
    _timedelayLabel.textColor = [UIColor redColor];
    [_propertyView addSubview:_timedelayLabel];
    
    _framerateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, height, width, height)];
    _framerateLabel.backgroundColor = [UIColor clearColor];
    _framerateLabel.textColor = [UIColor redColor];
    [_propertyView addSubview:_framerateLabel];
    
    _lostcntLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, height, width, height)];
    _lostcntLabel.backgroundColor = [UIColor clearColor];
    _lostcntLabel.textColor = [UIColor redColor];
    [_propertyView addSubview:_lostcntLabel];
    
    _localBitrateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, height * 2, width, height)];
    _localBitrateLabel.backgroundColor = [UIColor clearColor];
    _localBitrateLabel.textColor = [UIColor redColor];
    [_propertyView addSubview:_localBitrateLabel];
    
    _remoteBitrateLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, height * 2, width, height)];
    _remoteBitrateLabel.backgroundColor = [UIColor clearColor];
    _remoteBitrateLabel.textColor = [UIColor redColor];
    [_propertyView addSubview:_remoteBitrateLabel];
}

#pragma mark - ring

- (void)_beginRing
{
    [_ringPlayer stop];

    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"callRing" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:musicPath];

    _ringPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_ringPlayer setVolume:1];
    _ringPlayer.numberOfLoops = -1; //设置音乐播放次数  -1为一直循环
    if([_ringPlayer prepareToPlay])
    {
        [_ringPlayer play]; //播放
    }
}

- (void)_stopRing
{
    [_ringPlayer stop];
}

- (void)timeTimerAction:(id)sender
{
    _timeLength += 1;
    int hour = _timeLength / 3600;
    int m = (_timeLength - hour * 3600) / 60;
    int s = _timeLength - hour * 3600 - m * 60;
    
    if (hour > 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i:%i", hour, m, s];
    }
    else if(m > 0){
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i", m, s];
    }
    else{
        _timeLabel.text = [NSString stringWithFormat:@"00:%i", s];
    }
}

#pragma mark - private

- (void)_reloadPropertyData
{
    id<ICallManager> callManager = [EaseMob sharedInstance].callManager;
    _sizeLabel.text = [NSString stringWithFormat:@"%@%i/%i", NSLocalizedString(@"call.videoSize", @"Width/Height: "), [callManager getVideoWidth], [callManager getVideoHeight]];
    _timedelayLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoTimedelay", @"Timedelay: "), [callManager getVideoTimedelay]];
    _framerateLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoFramerate", @"Framerate: "), [callManager getVideoFramerate]];
    _lostcntLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoLostcnt", @"Lostcnt: "), [callManager getVideoLostcnt]];
    _localBitrateLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoLocalBitrate", @"Local Bitrate: "), [callManager getVideoLocalBitrate]];
    _remoteBitrateLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoRemoteBitrate", @"Remote Bitrate: "), [callManager getVideoRemoteBitrate]];
}

- (void)_insertMessageWithStr:(NSString *)str
{
    EMChatText *chatText = [[EMChatText alloc] initWithText:str];
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];
    EMMessage *message = [[EMMessage alloc] initWithReceiver:_callSession.sessionChatter bodies:@[textBody]];
    message.isRead = YES;
    message.deliveryState = eMessageDeliveryState_Delivered;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"insertCallMessage" object:message];
}

- (void)_close
{
    _callSession = nil;
    _openGLView.hidden = YES;
    _propertyView = nil;
    [self hideHud];
    
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    
    if (_propertyTimer) {
        [_propertyTimer invalidate];
        _propertyTimer = nil;
    }
    
    if (_session) {
        [_session stopRunning];
        [_session removeInput:_captureInput];
        [_session removeOutput:_captureOutput];
        _session = nil;
    }
    
    if (_smallCaptureLayer) {
        [_smallCaptureLayer removeFromSuperlayer];
        _smallCaptureLayer = nil;
        _smallView = nil;
    }
    
    if (_openGLView) {
        [_openGLView removeFromSuperview];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [[EaseMob sharedInstance].callManager removeDelegate:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"callControllerClose" object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertViewTag_Close)
    {
        [[EaseMob sharedInstance].callManager asyncEndCall:_callSession.sessionId reason:eCallReasonNull];
        _callSession = nil;
        [self _close];
    }
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

void YUV420spRotate90(UInt8 *  dst, UInt8* src, size_t srcWidth, size_t srcHeight)
{
    size_t wh = srcWidth * srcHeight;
    size_t uvHeight = srcHeight >> 1;//uvHeight = height / 2
    size_t uvWidth = srcWidth>>1;
    size_t uvwh = wh>>2;
    //旋转Y
    int k = 0;
    for(int i = 0; i < srcWidth; i++) {
        int nPos = wh-srcWidth;
        for(int j = 0; j < srcHeight; j++) {
            dst[k] = src[nPos + i];
            k++;
            nPos -= srcWidth;
        }
    }
    for(int i = 0; i < uvWidth; i++) {
        int nPos = wh+uvwh-uvWidth;
        for(int j = 0; j < uvHeight; j++) {
            dst[k] = src[nPos + i];
            dst[k+uvwh] = src[nPos + i+uvwh];
            k++;
            nPos -= uvWidth;
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    if (_callSession.status != eCallSessionStatusAccepted) {
        return;
    }
    
#warning 捕捉数据输出，根据自己需求可随意更改
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if(CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess)
    {
//        UInt8 *bufferbasePtr = (UInt8 *)CVPixelBufferGetBaseAddress(imageBuffer);
        UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        UInt8 *bufferPtr1 = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
//        printf("addr diff1:%d,diff2:%d\n",bufferPtr-bufferbasePtr,bufferPtr1-bufferPtr);
        
//        size_t buffeSize = CVPixelBufferGetDataSize(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
//        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t bytesrow0 = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
        size_t bytesrow1  = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
//        size_t bytesrow2 = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 2);
//        printf("buffeSize:%d,width:%d,height:%d,bytesPerRow:%d,bytesrow0 :%d,bytesrow1 :%d,bytesrow2 :%d\n",buffeSize,width,height,bytesPerRow,bytesrow0,bytesrow1,bytesrow2);

        if (_imageDataBuffer == nil) {
            _imageDataBuffer = (UInt8 *)malloc(width * height * 3 / 2);
        }
        UInt8 *pY = bufferPtr;
        UInt8 *pUV = bufferPtr1;
        UInt8 *pU = _imageDataBuffer + width * height;
        UInt8 *pV = pU + width * height / 4;
        for(int i =0; i < height; i++)
        {
            memcpy(_imageDataBuffer + i * width, pY + i * bytesrow0, width);
        }
        
        for(int j = 0; j < height / 2; j++)
        {
            for(int i = 0; i < width / 2; i++)
            {
                *(pU++) = pUV[i<<1];
                *(pV++) = pUV[(i<<1) + 1];
            }
            pUV += bytesrow1;
        }
        
        YUV420spRotate90(bufferPtr, _imageDataBuffer, width, height);
        [[EaseMob sharedInstance].callManager processPreviewData:(char *)bufferPtr width:width height:height];
        
        /*We unlock the buffer*/
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
}


#pragma mark - ICallManagerDelegate

- (void)callSessionStatusChanged:(EMCallSession *)callSession
                    changeReason:(EMCallStatusChangedReason)reason
                           error:(EMError *)error
{
    if(![_callSession.sessionId isEqualToString:callSession.sessionId]){
        return;
    }
    
    [self hideHud];
    [self _stopRing];
    if(error){
        _statusLabel.text = NSLocalizedString(@"call.connectFailed", @"Connect failed");
        [self _insertMessageWithStr:NSLocalizedString(@"call.failed", @"Call failed")];
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error") message:error.description delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        errorAlert.tag = kAlertViewTag_Close;
        [errorAlert show];
        
        return;
    }
    
    if (callSession.status == eCallSessionStatusDisconnected) {
        _statusLabel.text = NSLocalizedString(@"call.suspended", @"Call has been suspended");
        NSString *str = NSLocalizedString(@"call.over", @"Call end");
        if(_timeLength == 0)
        {
            if (reason == eCallReasonHangup) {
                str = NSLocalizedString(@"call.cancel", @"Cancel the call");
            }
            else if (reason == eCallReasonReject){
                str = NSLocalizedString(@"call.rejected", @"Reject the call");
            }
            else if (reason == eCallReasonBusy){
                str = NSLocalizedString(@"call.in", @"In the call...");
            }
        }
        [self _insertMessageWithStr:str];
        [self _close];
    }
    else if (callSession.status == eCallSessionStatusAccepted)
    {
        if (callSession.connectType == eCallConnectTypeRelay) {
            _statusLabel.text = NSLocalizedString(@"call.speak.relay", @"Can speak...Relay");
        }
        else if (callSession.connectType == eCallConnectTypeDirect){
            _statusLabel.text = NSLocalizedString(@"call.speak.direct", @"Can speak...Direct");
        }
        else{
            _statusLabel.text = NSLocalizedString(@"call.speak", @"Can speak...");
        }
        _timeLength = 0;
        _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];

        if(_isIncoming)
        {
            [_answerButton removeFromSuperview];
            [_rejectButton removeFromSuperview];
            [_actionView addSubview:_hangupButton];
        }
        [_actionView addSubview:_silenceButton];
        [_actionView addSubview:_silenceLabel];
        [_actionView addSubview:_speakerOutButton];
        [_actionView addSubview:_speakerOutLabel];
        
        if ([self isShowCallInfo]) {
            [self _reloadPropertyData];
            _propertyTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(_reloadPropertyData) userInfo:nil repeats:YES];
        }
    }
}

#pragma mark - UITapGestureRecognizer

- (void)viewTapAction:(UITapGestureRecognizer *)tap
{
    _topView.hidden = !_topView.hidden;
    _actionView.hidden = !_actionView.hidden;
    
    CGRect frame = _propertyView.frame;
    if (_actionView.hidden) {
        frame.origin.y = self.view.frame.size.height - 90;
    }
    else{
        frame.origin.y = CGRectGetMinY(_actionView.frame) - 90;
    }
    _propertyView.frame = frame;
}

#pragma mark - action

- (void)silenceAction
{
    _silenceButton.selected = !_silenceButton.selected;
    [[EaseMob sharedInstance].callManager markCallSession:_callSession.sessionId asSilence:_silenceButton.selected];
}

- (void)speakerOutAction
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (_speakerOutButton.selected) {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }else {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    [audioSession setActive:YES error:nil];
    _speakerOutButton.selected = !_speakerOutButton.selected;
}

- (void)rejectAction
{
    [_timeTimer invalidate];
    [self _stopRing];
    [self showHint:NSLocalizedString(@"call.rejected", @"Reject the call")];
    
    EMError *error = [[EaseMob sharedInstance].callManager asyncEndCall:_callSession.sessionId reason:eCallReasonReject];
    if (error) {
        [self _close];
    }
}

- (void)answerAction
{
    [self showHint:NSLocalizedString(@"call.init", @"Is init the call...")];
    [self _stopRing];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    _audioCategory = audioSession.category;
    if(![_audioCategory isEqualToString:AVAudioSessionCategoryPlayAndRecord]){
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
    }
    
    [[EaseMob sharedInstance].callManager asyncAnswerCall:_callSession.sessionId];
}

- (void)hangupAction
{
    _openGLView.hidden = YES;
    [_timeTimer invalidate];
    [_propertyTimer invalidate];
    [self _stopRing];
    [self showHint:NSLocalizedString(@"call.dealloc", @"Is hanging up the call...")];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:_audioCategory error:nil];
    [audioSession setActive:YES error:nil];
    
    EMError *error = [[EaseMob sharedInstance].callManager asyncEndCall:_callSession.sessionId reason:eCallReasonHangup];
    if (error) {
        [self _close];
    }
}

+ (BOOL)canVideo
{
    if([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending){
        if(!([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized)){\
            UIAlertView * alt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"setting.cameraNoAuthority", @"No camera permissions") message:NSLocalizedString(@"setting.cameraAuthority", @"Please open in \"Setting\"-\"Privacy\"-\"Camera\".") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
            [alt show];
            return NO;
        }
    }
    
    return YES;
}

@end
