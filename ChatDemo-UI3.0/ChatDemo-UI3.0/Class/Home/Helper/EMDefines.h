//
//  EMDefines.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/11.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#ifndef EMDefines_h
#define EMDefines_h

//账号状态
#define ACCOUNT_LOGIN_CHANGED @"loginStateChange"

//消息动图
#define MSG_EXT_GIF_ID @"em_expression_id"
#define MSG_EXT_GIF @"em_is_big_expression"

//消息撤回
#define MSG_EXT_RECALL @"em_recall"

//@
//群组消息ext的字段，用于存放被@的环信id数组
#define MSG_EXT_AT @"em_at_list"
//群组消息ext字典中，kGroupMessageAtList字段的值，用于@所有人
#define MSG_EXT_ATALL @"all"

#define kHaveUnreadAtMessage    @"kHaveAtMessage"
#define kAtYouMessage           1
#define kAtAllMessage           2


//实时音视频
#define CALL_CHATTER @"chatter"
#define CALL_TYPE @"type"
#define CALL_SHOW_VIEW @"EMWillShowCallView"
//实时音视频1v1呼叫
#define CALL_1V1 @"EMMake1v1Call"

//用户黑名单
#define CONTACT_BLACKLIST_UPDATE @"EMContactBlacklistUpdate"
#define CONTACT_BLACKLIST_RELOAD @"EMContactReloadBlacklist"

//群组
#define GROUP_INFO_UPDATED @"EMGroupInfoUpdated"

//聊天室
#define CHATROOM_INFO_UPDATED @"EMChatroomInfoUpdated"

#endif /* EMDefines_h */
