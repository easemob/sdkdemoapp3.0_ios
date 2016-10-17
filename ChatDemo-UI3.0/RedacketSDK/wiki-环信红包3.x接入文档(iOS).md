
====== 环信红包接入文档(iOS) =======

------

===== 环信红包简介 =====
1. 为 APP 提供了完整的收发红包功能。

红包包含的功能：
1. 发红包功能（支持支付宝支付,微信支付将于下版支持）
    1.1 单人红包
    1.2 群红包
    1.3 定向红包
2.转账功能
3.钱包
	3.1 零钱 
	3.2 零钱充值
	3.3 零钱提现
	3.4 零钱明细

2. 环信官方''SDK3.2.0 ChatDemoUI3.0''版Demo已默认集成红包功能，可以直接下载试用。

===== SDK介绍 =====

''RedpacketSDK''包含: 

* ''RedpacketStaticLib''静态库提供，实现了红包收发流程和账号安全体系。 

* ''RedpacketOpen''开源方式提供，实现了红包消息的展示

* ''AliPay'' 支付宝SDK


===== Step1. 导入SDK =====

1. 将RedpacketSDK文件夹导入工程(其中RedpacketStaticLib 和Alipay 可以通过Pod 'RedpacketLib'导入)

===== Step2. 配置商户ID =====

**@description:** 

* appKey为环信分配的appKey,格式为''****#****''

<code objc>
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
	//TODO:1 配置商户的AppKey
    [[RedPacketUserConfig sharedConfig] configWithAppKey:@"easemob-demo#chatdemoui"];
    
    ...
    ...
}
    
<code>

===== Step3. 替换聊天窗口 =====
**@description:** 

* 替代''ChatViewController''为''RedPacketChatViewController（带有红包功能的聊天窗口）''

===== Step4. 零钱页和零钱 =====

**@description:**

* ''ChatDemoUI3.0''的零钱页放在了''SettingsViewController''页面里。

* 通过''[RedpacketViewControl changeMoneyController]''获取零钱页。
* 通过''[RedpacketViewControl getChangeMoney:...]''获取零钱。

===== Step5. 支持支付宝 =====

=== 支付宝回调处理 ===

<code objc>
 #ifdef REDPACKET_AVALABLE
 #pragma mark - Alipay

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:nil];
}

// NOTE: iOS9.0之前使用的API接口
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
        }];
    }
    return YES;
}

// NOTE: iOS9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
        }];
    }
    return YES;
}

 #endif
 
<code>

=== 添加支付宝回调Scheme === 

* 添加URLScheme回调, 默认为`App的identifier Bundle`， 并通过`RedpacketBridge`中的`redacketURLScheme`将`App的identifier Bundle`传入SDK.

* 选中要编译的项目，在右侧的窗口中选择Targets中的某个target, 右侧Bulid Setting旁边有一个info选项，打开后最下边有一个URLTypes，点击加号添加一个URLType， URL schemes 设为 `App的identifier Bundle` 即可。


===== Step6. 可能发生的错误 =====

* RedpacketChatViewController报错，请查看RedpacketChatViewController是否引用了基类的私有方法，或者私有继承的协议，请将这些协议更开到.h文件中。

<code objc>
//	涉及到的协议

EaseMessageViewControllerDelegate

EaseMessageViewControllerDataSource

EaseMessageCellDelegate

//	涉及到的方法

- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext;

- (void)showMenuViewController:(UIView *)showInView
                   andIndexPath:(NSIndexPath *)indexPath
                    messageType:(EMMessageBodyType)messageType;

- (BOOL)shouldSendHasReadAckForMessage:(EMMessage *)message
                                  read:(BOOL)read;

<code>

* 某些方法找不到，请检查BulidSetting中 OtherLinkFlag的标记是否设置正确，如果缺省，还需添加''-Objc''

* 发红包按钮点击没反应，请查看''RedpacketChatViewController''中''static NSInteger const _redpacket_send_index   = 5;'' 值是否正确

* 缺少类库，支付宝需要添加的类库 [支付宝类库](https://doc.open.alipay.com/doc2/detail?treeId=59&articleId=103676&docType=1)

* 缺少参数，如果每个接口都报缺少参数，则是Token没有获取到，请检查''YZHRedpacketBridge''中红包注册的方法是否实现，或者是否传入了正确的参数。 如果是发红包页面报缺少参数，请检查''YZHRedpacketBridge''中的dataSource是否实现

* 其它，此方案为环信官方Demo的集成方案，并不完全实用所有情况，如有不适，还望变通实现。



