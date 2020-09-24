//
//  EMQRCodeViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/12.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMQRCodeViewController.h"

#import "WSLNativeScanTool.h"
#import "WSLScanView.h"

/*
 第一版（因时间不够，先只弄北京集群）：
 
 {
     "Appkey":"必填项：应用Appkey",
     "ApnsCertname":"可选项：推送证书名",
     "Username":"必填项：登录用户名",
     "Password":"可选项：登录密码",
 }
 
 
 第二版（在第一版基础上添加私有化服务器配置项）：
 
 {
     "Username":"必填项：登录用户名",
     "Password":"可选项：登录密码",
 
     "HttpsOnly":bool型[true->rest操作只能使用https，默认false],

     "SpecifyServer":int型[0->使用默认地址即北京集群，1->使用以下自定义服务器配置，默认0],
     "IMServer":"必填项：im服务器地址",
     "IMPort":"必填项：im服务器端口号",
     "RestServer":"必填项：rest服务器地址",
 }
 */

@interface EMQRCodeViewController ()

@property (nonatomic, strong) WSLNativeScanTool *scanTool;
@property (nonatomic, strong) UIView *scanOutputView;
@property (nonatomic, strong) WSLScanView *scanView;

@end

@implementation EMQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _setupViews];
    
    //初始化扫描工具
    __weak typeof(self) weakself = self;
    self.scanTool = [[WSLNativeScanTool alloc] initWithPreview:self.scanOutputView andScanFrame:_scanView.scanRetangleRect];
    self.scanTool.scanFinishedBlock = ^(NSString *aScanString) {
        NSLog(@"扫描结果 %@",aScanString);
        NSDictionary *dic = nil;
        if ([aScanString length] > 0) {
            NSData *jsonData = [aScanString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
            if (!error && [obj isKindOfClass:[NSDictionary class]]) {
                dic = (NSDictionary *)obj;
                if ([dic count] == 0) {
                    dic = nil;
                }
            }
        }
        
        if (!dic) {
            [EMAlertController showErrorAlert:@"未知的二维码信息"];
        } else {
            [EMAlertController showSuccessAlert:@"设置成功"];
            
            if (weakself.scanFinishCompletion) {
                weakself.scanFinishCompletion(dic);
            }
        }
        
        [weakself.scanTool sessionStopRunning];
        [weakself closeAction];
    };
    
    [self.scanTool sessionStartRunning];
    [self.scanView startScanAnimation];
}

#pragma mark - Subviews

- (void)_setupViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(5);
        make.top.equalTo(self.view).offset(20);
        make.width.height.equalTo(@50);
    }];
    
    //输出流视图
    self.scanOutputView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.scanOutputView];
    
    //构建扫描样式视图
    self.scanView = [[WSLScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scanView.scanRetangleRect = CGRectMake((self.view.frame.size.width - 250) / 2, (self.view.frame.size.height - 250) / 2, 250, 250);
    self.scanView.colorAngle = kColor_Blue;
    self.scanView.photoframeAngleW = 20;
    self.scanView.photoframeAngleH = 20;
    self.scanView.photoframeLineW = 2;
    self.scanView.isNeedShowRetangle = YES;
    self.scanView.colorRetangleLine = [UIColor grayColor];
    self.scanView.notRecoginitonArea = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.scanView.animationImage = [UIImage imageNamed:@"scanLine"];
//    __weak typeof(self) weakself = self;
//    self.scanView.flashSwitchBlock = ^(BOOL open) {
//        [weakself.scanTool openFlashSwitch:open];
//    };
    [self.view addSubview:self.scanView];
    
    [self.view bringSubviewToFront:backButton];
}

#pragma mark - Action

- (void)closeAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
