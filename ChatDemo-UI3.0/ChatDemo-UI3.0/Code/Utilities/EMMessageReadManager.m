//
//  EMMessageReadManager.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMMessageReadManager.h"

#import "MWPhotoBrowser.h"

static EMMessageReadManager *manager = nil;

@interface EMMessageReadManager () <MWPhotoBrowserDelegate>

@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) UINavigationController *photoNavigationController;
@property (strong, nonatomic) MWPhotoBrowser *photoBrowser;

@end

@implementation EMMessageReadManager

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[EMMessageReadManager alloc] init];
    });
    return manager;
}

#pragma mark - getter

- (NSMutableArray *)photos
{
    if (_photos == nil) {
        _photos = [[NSMutableArray alloc] init];
    }
    
    return _photos;
}

- (MWPhotoBrowser *)photoBrowser
{
    if (_photoBrowser == nil) {
        _photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        _photoBrowser.displayActionButton = YES;
        _photoBrowser.displayNavArrows = YES;
        _photoBrowser.displaySelectionButtons = NO;
        _photoBrowser.alwaysShowControls = NO;
        _photoBrowser.zoomPhotosToFill = YES;
        _photoBrowser.enableGrid = NO;
        _photoBrowser.startOnGrid = NO;
        [_photoBrowser setCurrentPhotoIndex:0];
    }
    
    return _photoBrowser;
}

- (UINavigationController *)photoNavigationController
{
    if (_photoNavigationController == nil) {
        _photoNavigationController = [[UINavigationController alloc] initWithRootViewController:self.photoBrowser];
        _photoNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    [self.photoBrowser reloadData];
    return _photoNavigationController;
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return [self.photos count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.photos.count)
    {
        return [self.photos objectAtIndex:index];
    }
    
    return nil;
}

#pragma mark - public

- (void)showBrowserWithImages:(NSArray *)imageArray
{
    if (imageArray && [imageArray count] > 0) {
        NSMutableArray *photoArray = [NSMutableArray array];
        for (id object in imageArray) {
            MWPhoto *photo;
            if ([object isKindOfClass:[UIImage class]]) {
                photo = [MWPhoto photoWithImage:object];
            }
            else if ([object isKindOfClass:[NSURL class]])
            {
                photo = [MWPhoto photoWithURL:object];
            }
            [photoArray addObject:photo];
        }
        self.photos = photoArray;
    }
    UIViewController *rootController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootController presentViewController:self.photoNavigationController animated:YES completion:nil];
}

@end
