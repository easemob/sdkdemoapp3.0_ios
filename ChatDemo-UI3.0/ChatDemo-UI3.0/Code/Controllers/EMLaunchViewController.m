//
//  EMLaunchViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/20.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMLaunchViewController.h"

@interface EMLaunchViewController ()

@property (weak ,nonatomic) IBOutlet UIImageView *launchImageView;

@end

@implementation EMLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBackgroundColor];
    [self setLauchAnimation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.65 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL isAutoLogin = [EMClient sharedClient].isAutoLogin;
        if (isAutoLogin){
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
        }
    });
}

- (void)setBackgroundColor
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [UIScreen mainScreen].bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)RGBACOLOR(62, 92, 120, 1).CGColor,(id)RGBACOLOR(36, 62, 85, 1).CGColor,nil];
    [gradient setStartPoint:CGPointMake(0.0, 0.0)];
    [gradient setEndPoint:CGPointMake(0.0, 1.0)];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)setLauchAnimation
{
    _launchImageView.animationImages = @[[UIImage imageNamed:@"logo1"],
                                         [UIImage imageNamed:@"logo2"],
                                         [UIImage imageNamed:@"logo3"],
                                         [UIImage imageNamed:@"logo4"],
                                         [UIImage imageNamed:@"logo5"],
                                         [UIImage imageNamed:@"logo6"],
                                         [UIImage imageNamed:@"logo7"],
                                         [UIImage imageNamed:@"logo8"],
                                         [UIImage imageNamed:@"logo9"],
                                         [UIImage imageNamed:@"logo10"],
                                         [UIImage imageNamed:@"logo11"]];
    _launchImageView.animationDuration = 1.65;
    _launchImageView.animationRepeatCount = 1;
    [_launchImageView startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
