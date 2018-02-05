
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <deque>

#import "VideoCustomCamera.h"


#define rdbgi(...) do{  NSLog(@"<rtc>[I] " __VA_ARGS__);}while(0)
#define rdbge(...) do{  NSLog(@"<rtc>[E] " __VA_ARGS__);}while(0)


static NSString* const kDefaultPreset = AVCaptureSessionPreset640x480;
static NSString *  kRtcCameraErrorDomain = @"com.em.easycamera.error";
static const int64_t kMaxDistance = ~(static_cast<int64_t>(1) << 63);

@interface IOSCameraVideoFormat()

- (instancetype)initWithPreset:(NSString * const)preset
                          width:(int)width
                         height:(int)height;

@end


@implementation IOSCameraVideoFormat

- (instancetype) initWithPreset:(NSString * const) preset
                          width:(int) width
                         height:(int) height{
    if(self=[super init]){
        _preset = preset;
        _width = width;
        _height = height;
    }
    return self;
}

@end


@interface VideoCustomCamera() <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    dispatch_queue_t _workQueue;
    AVCaptureDeviceInput* _frontDeviceInput;
    AVCaptureDeviceInput* _backDeviceInput;
    AVCaptureDeviceInput* _currentDeviceInput;
    AVCaptureVideoDataOutput* _videoOutput;
    AVCaptureSession* _captureSession;
    BOOL _isRunning;
    BOOL _useBackCamera;
    BOOL _orientationHasChanged;
    BOOL _stopReq;
    id<AVCaptureVideoDataOutputSampleBufferDelegate> _dataDelegate;
    IOSCameraVideoFormat * _currentFormat;
    AVCaptureVideoPreviewLayer * _previewLayer;
    AVCaptureStillImageOutput * _stillImageOutput;
}

@end

@implementation VideoCustomCamera

- (instancetype)initWithQueue:(dispatch_queue_t)aQueue
{
    if (self = [super init]) {
        _workQueue = aQueue;
        if(!_workQueue){
            _workQueue = dispatch_get_main_queue();
        }
        
        _frontDeviceInput = nil;
        _backDeviceInput = nil;
        _currentDeviceInput = nil;
        _videoOutput = nil;
        _captureSession = nil;
        _isRunning = NO;
        _useBackCamera = NO;
        _orientationHasChanged = NO;
        _stopReq = NO;
        _dataDelegate = nil;
        _currentFormat = nil;
        _previewLayer = nil;
        
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(onDeviceOrientationDidChange:)
                       name:UIDeviceOrientationDidChangeNotification
                     object:nil];
        [center addObserverForName:AVCaptureSessionRuntimeErrorNotification
                            object:nil
                             queue:nil
                        usingBlock:^(NSNotification* notification) {
                            rdbge(@"Capture session error: %@", notification.userInfo);
                        }];
    }
    return self;
}

- (void)dealloc {
    [self doStopCapture];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)syncSetDataDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)aDelegate
                     onDone:(RtcCameraIdBlockType)doneBlock
{
    _dataDelegate = aDelegate;
    [self invokeIdBlock:doneBlock obj:nil error:nil];
}

- (BOOL)syncOpenWithWidth:(int)width
                   height:(int)height
                   onDone:(RtcCameraIdBlockType)doneBlock
{
    if (_isRunning) {
        [self invokeIdBlock:doneBlock obj:nil error:[self makeError:-1 desc:@"already start" ]];
        return YES;
    }
    IOSCameraVideoFormat * format = [self getBestFormatForWidth:width heigth:height];
    BOOL ok = [self doStartCapture:format.preset];
    if(!ok){
        [self invokeIdBlock:doneBlock obj:nil error:[self makeError:-1 desc:@"fail to open camera" ]];
        return ok;
    }
    _currentFormat = format;
    _previewLayer = nil;
    if(_captureSession){
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc]init];
        [_previewLayer setSession: _captureSession];
        
    }
    [self invokeIdBlock:doneBlock obj:_captureSession error:nil];
    return ok;
}

- (void)syncClose:(RtcCameraIdBlockType)doneBlock
{
    if (!_isRunning) {
        [self invokeIdBlock:doneBlock obj:nil error:[self makeError:-1 desc:@"NOT start yet" ]];
        return;
    }
    [self doStopCapture];
    
    [self invokeIdBlock:doneBlock obj:nil error:nil];
}

- (void)swapCameraWithPosition:(AVCaptureDevicePosition)aPosition
{
    [self doCheckInput:(aPosition == AVCaptureDevicePositionFront ? NO : YES)];
}

#pragma mark - NSNotificationCenter event

- (void)onDeviceOrientationDidChange:(NSNotification*)notification
{
    // TODO: check is execute in work queue
    __weak typeof(self) weakself = self;
    dispatch_async(_workQueue, ^{
        if(!_isRunning) return;
        _orientationHasChanged = YES;
        [weakself doUpdateOrientation];
    });
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput*)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection*)connection
{
    // TODO: check is execute in work queuue
    
    NSParameterAssert(captureOutput == _videoOutput);
    if (!_isRunning || _stopReq) {
        return;
    }
    
    if(_dataDelegate){
        if([_dataDelegate respondsToSelector:@selector(captureOutput:didOutputSampleBuffer:fromConnection:)] == YES ){
            [_dataDelegate captureOutput: captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
        }
    }
}

- (void)captureOutput:(AVCaptureOutput*)captureOutput
  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection*)connection
{
    rdbge(@"Dropped sample buffer.");
    if(_dataDelegate){
        if([_dataDelegate respondsToSelector:@selector(captureOutput:didDropSampleBuffer:fromConnection:)] == YES ){
            [_dataDelegate captureOutput: captureOutput didDropSampleBuffer:sampleBuffer fromConnection:connection];
        }
    }
}


#pragma mark - Private

- (void)invokeIdBlock:(RtcCameraIdBlockType)block
                  obj:(id)obj
                error:(NSError*)error
{
    if(block){
        block(obj, error);
    }
}

- (NSError*)makeError:(int)code
                 desc:(NSString*)desc
{
    return [NSError errorWithDomain:kRtcCameraErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:desc}];
}

- (int64_t)calcDistanceWithWidth:(int)desired_width
                          height:(int)desired_height
                        stdWidth:(int)stdWidth
                       stdHeight:(int)stdHeight
{
    int64_t delta_w = stdWidth - desired_width;
    // Check height of stdHeight compared to height we would like it to be.
    int64_t aspect_h = desired_width ? stdWidth * desired_height / desired_width : desired_height;
    int64_t delta_h = stdHeight - aspect_h;
    
    
    static const int kDownPenalty = -3;
    int64_t distance = 0;
    
    if (delta_w < 0) {
        delta_w = delta_w * kDownPenalty;
    }
    if (delta_h < 0) {
        delta_h = delta_h * kDownPenalty;
    }
    
    // 12 bits for width and height and 8 bits for fps and fourcc.
    distance |= (delta_w << 28) | (delta_h << 16);
    return distance;
}


-(NSDictionary *)doGetSupportedFormats
{
    NSDictionary * dict = @{
                            AVCaptureSessionPreset352x288: [[IOSCameraVideoFormat alloc] initWithPreset:AVCaptureSessionPreset352x288 width:352 height:288],
                            AVCaptureSessionPreset640x480: [[IOSCameraVideoFormat alloc] initWithPreset:AVCaptureSessionPreset640x480 width:640 height:480],
                            AVCaptureSessionPreset1280x720: [[IOSCameraVideoFormat alloc] initWithPreset:AVCaptureSessionPreset1280x720 width:1280 height:720],
                            AVCaptureSessionPreset1920x1080: [[IOSCameraVideoFormat alloc] initWithPreset:AVCaptureSessionPreset1920x1080 width:1920 height:1080],
                            };
    return dict;
}


- (IOSCameraVideoFormat *)getBestFormatForWidth:(int)w
                                         heigth:(int)h
{
    NSDictionary * dictFormats = [self doGetSupportedFormats];
    int64_t min_distance = kMaxDistance;
    
    IOSCameraVideoFormat * preferFormat = [dictFormats objectForKey:kDefaultPreset];
    if(w <= 0) {
        return preferFormat;
    }
    
    if(preferFormat){
        min_distance = [self calcDistanceWithWidth:w height:h stdWidth:preferFormat.width stdHeight:preferFormat.height];
    }
    
    for (NSString *key in dictFormats) {
        IOSCameraVideoFormat * format = dictFormats[key];
        int64_t distance = [self calcDistanceWithWidth:w height:h stdWidth:format.width stdHeight:format.height];
        if(distance < min_distance){
            min_distance = distance;
            preferFormat = format;
        }
    }
    
    return preferFormat;
}

- (BOOL)doStartCapture:(NSString *)preset
{
    if(_isRunning) return YES;
    rdbgi("RtcCamera: doStartCapture ==>");
    _orientationHasChanged = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    BOOL ok = [self setupCaptureSession:preset];
    if(!ok){
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }else{
        _isRunning = YES;
        [_captureSession startRunning];
        rdbgi("RtcCamera: startRunning");
        [self doPostStartRunning];
    }
    rdbgi("RtcCamera: doStartCapture <==, ok=%d", ok);
    return ok;
}

- (void)doPostStartRunning
{
    //#if defined(__IPHONE_7_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    //    NSString* version = [[UIDevice currentDevice] systemVersion];
    //    if ([version integerValue] >= 7) {
    //        _captureSession.usesApplicationAudioSession = NO;
    //    }
    //#endif
}

- (void)doStopCapture
{
    if(!_isRunning) return;
    
    [_videoOutput setSampleBufferDelegate:nil queue:nullptr];
    if(_stillImageOutput){
        _stillImageOutput = nil;
    }
    
    AVCaptureSession* session = _captureSession;
    rdbgi(@"stopCaptureAsync:stop session ...");
    _stopReq = YES;
    [session stopRunning];
    _stopReq = NO;
    rdbgi(@"stopCaptureAsync:stop session done");
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    _isRunning = NO;
}

- (BOOL)setupCaptureSession:(NSString *)preset
{
    _captureSession = [[AVCaptureSession alloc] init];
#if defined(__IPHONE_7_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    NSString* version = [[UIDevice currentDevice] systemVersion];
    if ([version integerValue] >= 7) {
        _captureSession.usesApplicationAudioSession = NO;
    }
#endif
    if (![_captureSession canSetSessionPreset:preset]) {
        rdbge(@"Default video capture preset unsupported.");
        return NO;
    }
    _captureSession.sessionPreset = preset;
    
    // Make the capturer output NV12. Ideally we want I420 but that's not
    // currently supported on iPhone / iPad.
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    _videoOutput.videoSettings = @{
                                   (NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
                                   //    , (NSString*) kCVPixelBufferBytesPerRowAlignmentKey : @(1)
                                   };
    _videoOutput.alwaysDiscardsLateVideoFrames = NO;
    [_videoOutput setSampleBufferDelegate:self
                                    queue:_workQueue // dispatch_get_main_queue() // _workQueue
     ];
    if (![_captureSession canAddOutput:_videoOutput]) {
        rdbge(@"Default video capture output unsupported.");
        return NO;
    }
    [_captureSession addOutput:_videoOutput];
    
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ( [_captureSession canAddOutput:stillImageOutput] ) {
        stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
        [_captureSession addOutput:stillImageOutput];
        _stillImageOutput = stillImageOutput;
    }
    else {
        rdbge( @"Could not add still image output to the session" );
    }
    
    
    // Find the capture devices.
    AVCaptureDevice* frontCaptureDevice = nil;
    AVCaptureDevice* backCaptureDevice = nil;
    for (AVCaptureDevice* captureDevice in
         [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (captureDevice.position == AVCaptureDevicePositionBack) {
            backCaptureDevice = captureDevice;
        }
        if (captureDevice.position == AVCaptureDevicePositionFront) {
            frontCaptureDevice = captureDevice;
        }
    }
    if (!frontCaptureDevice || !backCaptureDevice) {
        rdbge(@"Failed to get capture devices.");
        return NO;
    }
    
    
    NSError* error = nil;
    _frontDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCaptureDevice error:&error];
    if (!_frontDeviceInput) {
        rdbge(@"Failed to get capture device input: %@", error.localizedDescription);
    }else{
        if(![_captureSession canAddInput:_frontDeviceInput] ){
            rdbge(@"can't add frontInput");
            _frontDeviceInput = nil;
        }else{
            rdbgi(@"can add frontInput");
        }
    }
    
    _backDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCaptureDevice error:&error];
    if (!_backDeviceInput) {
        rdbge(@"Failed to get capture device input: %@", error.localizedDescription);
    }else{
        if(![_captureSession canAddInput:_backDeviceInput]){
            rdbge(@"can't add backInput");
            _backDeviceInput = nil;
        }else{
            rdbgi(@"can add backInput");
        }
    }
    
    if(!_frontDeviceInput && !_backDeviceInput){
        rdbge(@"both frontInput and backInput fail");
        return NO;
    }
    
    [self doCheckInput: _useBackCamera];
    
    return YES;
}

- (void)doUpdateOrientation
{
    AVCaptureConnection* connection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection.supportsVideoOrientation) {
        // TODO(tkchin): set rotation bit on frames.
        return;
    }
    //    if(connection) return; // simon
    
    AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
            if (!_orientationHasChanged) {
                connection.videoOrientation = orientation;
            }
            return;
    }
    connection.videoOrientation = orientation;
}


- (AVCaptureDeviceInput *)getDeviceInput:(BOOL)userBack
{
    if(userBack) {
        return _backDeviceInput;
    } else {
        return _frontDeviceInput;
    }
}


- (void)doCheckInput:(BOOL)userBack
{
    if(!_captureSession) return;
    
    [_captureSession beginConfiguration];
    AVCaptureDeviceInput* newInput = [self getDeviceInput: userBack];
    if(!newInput){
        newInput = [self getDeviceInput: !userBack];
    }
    
    if(newInput){
        if(newInput != _currentDeviceInput){
            if(_currentDeviceInput){
                [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:_currentDeviceInput.device];
            }
            
            [_captureSession removeInput:_currentDeviceInput];
            
        }
        
        // TODO: [_captureSession canAddInput:newInput];
        
        [_captureSession addInput:newInput];
        _currentDeviceInput = newInput;
    }
    [self doUpdateOrientation];
    
    [_captureSession commitConfiguration];
}

@end



