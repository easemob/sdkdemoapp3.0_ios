

#import <Foundation/Foundation.h>

@interface EMAVPluginRecorder : NSObject

/*!
 *
 *  初始化录制模块，请在APP启动的时候调用一次
 */
+ (void)initGlobal;


/*!
 *
 *  设置是否录制成mov格式，视频通话双方都需要设置一致
 *  @param enabled
 */
+ (void)setPreferMovFormatEnable:(BOOL) enabled;


/*!
 *  获取视频快照
 *
 *  @param aFullPath  图片存储路径
 */
+ (void)takeRemotePicture:(NSString *)aFullPath;

/*!
 *  开始录制视频
 *
 *  @param  aPath    文件保存路径
 */
+ (BOOL)startVideoRecord:(NSString*)aPath;

/*!
 *  停止录制视频
 *
 */
+ (NSString *)stopVideoRecord;

@end
