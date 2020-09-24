//
//  EMCreateChatroomViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMCreateChatroomViewController : UITableViewController

@property (nonatomic, copy) void (^successCompletion)(EMChatroom *aChatroom);

@end

NS_ASSUME_NONNULL_END
