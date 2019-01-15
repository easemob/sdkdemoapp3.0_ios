//
//  EMEmojiEmoticons.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/8.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EASEUI_EMOTION_DEFAULT_EXT @"em_emotion"

#define MESSAGE_ATTR_IS_BIG_EXPRESSION @"em_is_big_expression"
#define MESSAGE_ATTR_EXPRESSION_ID @"em_expression_id"

typedef NS_ENUM(NSUInteger, EMEmotionType) {
    EMEmotionDefault = 0,
    EMEmotionPng,
    EMEmotionGif
};

@interface EaseEmotionManager : NSObject

@property (nonatomic, strong) NSArray *emotions;

/*!
 @property
 @brief number of lines of emotion
 */
@property (nonatomic, assign) NSInteger emotionRow;

/*!
 @property
 @brief number of columns of emotion
 */
@property (nonatomic, assign) NSInteger emotionCol;

/*!
 @property
 @brief emotion type
 */
@property (nonatomic, assign) EMEmotionType emotionType;

@property (nonatomic, strong) UIImage *tagImage;

- (id)initWithType:(EMEmotionType)Type
        emotionRow:(NSInteger)emotionRow
        emotionCol:(NSInteger)emotionCol
          emotions:(NSArray*)emotions;

- (id)initWithType:(EMEmotionType)Type
        emotionRow:(NSInteger)emotionRow
        emotionCol:(NSInteger)emotionCol
          emotions:(NSArray*)emotions
          tagImage:(UIImage*)tagImage;

@end

@interface EaseEmotion : NSObject

@property (nonatomic, assign) EMEmotionType emotionType;

@property (nonatomic, copy) NSString *emotionTitle;

@property (nonatomic, copy) NSString *emotionId;

@property (nonatomic, copy) NSString *emotionThumbnail;

@property (nonatomic, copy) NSString *emotionOriginal;

@property (nonatomic, copy) NSString *emotionOriginalURL;

- (id)initWithName:(NSString*)emotionTitle
         emotionId:(NSString*)emotionId
  emotionThumbnail:(NSString*)emotionThumbnail
   emotionOriginal:(NSString*)emotionOriginal
emotionOriginalURL:(NSString*)emotionOriginalURL
       emotionType:(EMEmotionType)emotionType;

@end
