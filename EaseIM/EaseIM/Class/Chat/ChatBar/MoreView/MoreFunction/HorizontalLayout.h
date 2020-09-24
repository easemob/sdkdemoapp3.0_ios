//
//  HorizontalLayout.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/5/7.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HorizontalLayout : UICollectionViewFlowLayout

/** 每行item数量*/
@property (nonatomic,assign) NSInteger rowCount;
/** 每列item数量*/
@property (nonatomic,assign) NSInteger columCount;


@end

NS_ASSUME_NONNULL_END
