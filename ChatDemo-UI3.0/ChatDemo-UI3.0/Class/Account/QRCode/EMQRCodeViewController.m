//
//  EMQRCodeViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/12.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMQRCodeViewController.h"

#import "Masonry.h"
#import "WSLNativeScanTool.h"
#import "WSLScanView.h"

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
        [weakself.scanTool sessionStopRunning];
        [weakself.scanTool openFlashSwitch:NO];
        
        if (weakself.scanFinishCompletion) {
            //TODO:scanFinishCompletion
            weakself.scanFinishCompletion(aScanString);
        }
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
    [backButton setImage:[UIImage imageNamed:@"close_gray"] forState:UIControlStateNormal];
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
    self.scanView.colorAngle = [UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0];
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
