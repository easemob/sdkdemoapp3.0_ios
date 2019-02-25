/*!
 *  \~chinese
 *  @header EMCallRecorderPlugin.h
 *  @abstract 录制视频插件，与视频通话配合使用
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMCallRecorderPlugin.h
 *  @abstract Setting options of Apple Push Notification
 *  @author Hyphenate
 *  @version 3.00
 */
#import <Foundation/Foundation.h>

@class EMError;
@class EMCallSession;
@interface EMCallRecorderPlugin : NSObject

/*!
 *  \~chinese
 *  初始化全局设置, 必须在视频通话开始之前调用
 *
 *  \~english
 *  Init global config，it must be called before the video call begins.
 */
+ (void)initGlobalConfig;

/*!
 *  \~chinese
 *  获取插件实例
 *
 *  \~english
 *  Get plugin singleton instance
 */
+ (instancetype)sharedInstance;

/*!
 *  \~chinese
 *  设置是否录制成mov格式，视频通话双方都需要设置一致，默认YES
 *  如果只录制音频，需要置为NO
 *
 *  @param aEnabled    是否将视频录制成mov格式
 *
 *  Set whether to record in mov format, both sides of the video call need to be consistent, default YES
 *  If you only record audio, you need to set NO
 *
 *  @param aEnabled    Whether to record in mov format
 */
+ (void)setVideoMovFormatEnable:(BOOL)aEnabled;

/*!
 *  \~chinese
 *  获取视频快照，只支持JPEG格式
 *
 *  @param aPath  图片存储路径
 *
 *  \~english
 *  Get a snapshot of current video screen in jpeg and save it to the local database.
 *
 *  @param aPath  Saved path of picture
 */
- (void)screenCaptureToFilePath:(NSString *)aPath
                          error:(EMError**)pError;

/*!
 *  \~chinese
 *  开始录制视频
 *
 *  @param aPath            文件保存路径
 *  @param aError           错误
 *
 *  \~english
 *  Start recording video
 *
 *  @param aPath            File saved path
 *  @param aError           Error
 
 *
 */
- (void)startVideoRecordingToFilePath:(NSString *)aPath
                                error:(EMError**)aError;

/*!
 *  \~chinese
 *  停止录制视频
 *
 *  @param aError           错误
 *
 *  @result 视频存放路径（包含文件名）
 *
 *  \~english
 *  Stop recording video
 *
 *  @param aError           Error
 *
 *  @result Video storage path (including file name)
 */
- (NSString *)stopVideoRecording:(EMError**)aError;

/*!
 *  \~chinese
 *  开始录制音频，格式wav
 *
 *  @param aCompletionBlock    回调
 *
 *  \~english
 *  Start recording audio, Format wav
 *
 *  @param aCompletionBlock    The callback block
 *
 */
- (void)startAudioRecordWithCompletion:(void (^)(EMError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  停止录制音频
 *
 *  @param aCompletionBlock    回调，包含语音文件存储路径、错误信息
 *
 *  \~english
 *  Stop recording audio
 *
 *  @param aCompletionBlock    The callback block, contains voice file storage path， error
 *
 */
- (void)stopAudioRecordWithCompletion:(void (^)(NSString *aFilePath, EMError *aError))aCompletionBlock;

@end
