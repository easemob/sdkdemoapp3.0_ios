//
//  EMLocationViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/29.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "EMLocationViewController.h"

@interface EMLocationViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic) BOOL canSend;

@property (nonatomic) CLLocationCoordinate2D locationCoordinate;
@property (nonatomic, strong) NSString *address;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) MKPointAnnotation *annotation;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation EMLocationViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _canSend = YES;
    }
    
    return self;
}

- (instancetype)initWithLocation:(CLLocationCoordinate2D)aLocationCoordinate
{
    self = [super init];
    if (self) {
        _canSend = NO;
        _locationCoordinate = aLocationCoordinate;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupSubviews];
    
    if (self.canSend) {
        self.mapView.showsUserLocation = YES;//显示当前位置
        [self _startLocation];
    } else {
        [self _moveToLocation:self.locationCoordinate];
    }
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_white"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar.layer setMasksToBounds:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"close_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];
    if (self.canSend) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendAction)];
    }
    self.title = @"地理位置";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.zoomEnabled = YES;
    [self.view addSubview:self.mapView];
    
    self.annotation = [[MKPointAnnotation alloc] init];
}

#pragma mark - Private

- (void)_startLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 5;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;//kCLLocationAccuracyBest;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    
    [self showHudInView:self.view hint:@"正在定位..."];
}

- (void)_moveToLocation:(CLLocationCoordinate2D)locationCoordinate
{
    [self hideHud];
    
    self.locationCoordinate = locationCoordinate;
    float zoomLevel = 0.01;
    MKCoordinateRegion region = MKCoordinateRegionMake(self.locationCoordinate, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    [self.mapView removeAnnotation:self.annotation];
    self.annotation.coordinate = locationCoordinate;
    [self.mapView addAnnotation:self.annotation];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    __weak typeof(self) weakself = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            weakself.address = placemark.name;
            [weakself _moveToLocation:userLocation.coordinate];
        }
    }];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [self hideHud];
    if (error.code == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[error.userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusDenied:
            break;
        default:
            break;
    }
}

#pragma mark - Action

- (void)closeAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.sendCompletion) {
            self.sendCompletion(self.locationCoordinate, self.address);
        }
    }];
}

@end
