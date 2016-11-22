# sdkdemoapp3.0_ios
--------
## 简介
本Demo展示了怎么使用环信SDK创建一个完整的类微信的聊天APP。展示的功能包括：注册新用户，用户登录，添加好友，单聊，群聊，发送文字，表情，语音，图片，地理位置等消息，以及实时音视频通话等。
## 关于分支
master分支(也就是默认分支)是环信sdk 2.x版本的稳定代码，2.x开发版本的代码在dev分支上，3.x开发版本的代码在sdk3.x分支上，看自己需求切换分支。release版本分别有相应分支或tag。
## 项目依赖
此demo依赖于easeui和环信SDK,需要安装cocoapods集成easeui和sdk

1.安装cocoapods

```
sudo gem install cocoapods
```
2.安装成功后,下载集成easeui和sdk

```
cd ./ChatDemo-UI3.0

pod install

```
3.点击ChatDemo-UI3.0.xcworkspace进入Demo