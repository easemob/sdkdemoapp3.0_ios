
#import <AVFoundation/AVFoundation.h>

typedef enum {
    VIDEO_INPUT_MODE_NONE = 0,
    VIDEO_INPUT_MODE_SAMPLE_BUFFER,
    VIDEO_INPUT_MODE_PIXEL_BUFFER,
    VIDEO_INPUT_MODE_DATA,
}VideoInputModeType;

typedef void (^RtcCameraIdBlockType)(id obj, NSError * error);

@interface IOSCameraVideoFormat : NSObject

@property (nonatomic, readonly) NSString * preset;
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

@end

@interface VideoCustomCamera : NSObject

- (instancetype)initWithQueue:(dispatch_queue_t)aQueue;

- (void)syncSetDataDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)aDelegate
                     onDone:(RtcCameraIdBlockType)doneBlock;

- (BOOL)syncOpenWithWidth:(int)width
                   height:(int)height
                   onDone:(RtcCameraIdBlockType)doneBlock;

- (void)syncClose:(RtcCameraIdBlockType)doneBlock;

- (void)swapCameraWithPosition:(AVCaptureDevicePosition)aPosition;

@end


