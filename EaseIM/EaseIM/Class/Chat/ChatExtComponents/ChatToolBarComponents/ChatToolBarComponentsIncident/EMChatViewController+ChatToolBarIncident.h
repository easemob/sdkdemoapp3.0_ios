//
//  EMChatViewController+ChatToolBarIncident.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/13.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EMChatToolBarComponentType) {
    EMChatToolBarPhotoAlbum = 0,
    EMChatToolBarCamera,
    EMChatToolBarSealRtc,
    EMChatToolBarLocation,
    EMChatToolBarFileOpen,
};

@interface EMChatViewController (ChatToolBarIncident)

- (void)chatToolBarComponentAction:(EMChatToolBarComponentType)toolBarComponentType;

@end


@interface EMChatViewController (ChatToolBarMeida) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;

- (void)chatToolBarComponentIncidentAction:(EMChatToolBarComponentType)componentType;
@end

@interface EMChatViewController (ChatToolBarSealRtc)

- (void)chatToolBarComponentSealRtcAction;
@end

@interface EMChatViewController (ChatToolBarLocation)

- (void)chatToolBarLocationAction;
@end

@interface EMChatViewController (ChatToolBarFileOpen) <UIDocumentPickerDelegate>

- (void)chatToolBarFileOpenAction;
@end

NS_ASSUME_NONNULL_END
