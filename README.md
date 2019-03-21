# EMiOSDemo
--------
## 简介
本Demo展示了怎么使用环信SDK创建一个完整的类微信的聊天APP。展示的功能包括：注册新用户，用户登录，添加好友，单聊，群聊，发送文字，表情，语音，图片，地理位置等消息，以及实时音视频通话等。

## demo运行

1.安装cocoapods

```
sudo gem install cocoapods
```
2.安装成功后, 运行Podfile

```
cd ./EMiOSDemo

pod install

```
3.点击EMiOSDemo.xcworkspace进入Demo

## 目录介绍

+class
  -EMDemoHelper [页面跳转，回调弹框提示]
  +Helper [自定义库和页面，第三方库，全局通用]
  +Account [账号相关：登录、注册]
  +Home [登录后主页]
  +Call [实时音视频]
  +Chat [聊天]
  +Chatroom [聊天室]
  +Contact [好友]
  +Conversation [会话]
  +Group [群组]
  +Notification [通知]
  +Settings [设置]
