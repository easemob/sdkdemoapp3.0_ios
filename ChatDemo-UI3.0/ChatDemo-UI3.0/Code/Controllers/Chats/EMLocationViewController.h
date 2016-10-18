//
//  EMLocationViewController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/23.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol EMLocationViewDelegate <NSObject>

-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address;
@end

@interface EMLocationViewController : UIViewController

@property (weak, nonatomic) id<EMLocationViewDelegate> delegate;

- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate;

@end
