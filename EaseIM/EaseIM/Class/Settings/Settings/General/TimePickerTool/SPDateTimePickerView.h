//
//  SPDateTimePickerView.h
//  EaseIM
//
//  Created by 娜塔莎 on 2019/11/29.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SPDatePickerViewMode) {
    SPDatePickerModeYear = 0,              //年
    SPDatePickerModeYearAndMonth,          //年月
    SPDatePickerModeDate,                  //年月日
    SPDatePickerModeDateHour,              //年月日时
    SPDatePickerModeDateHourMinute,        //年月日时分
    SPDatePickerModeDateHourMinuteSecond,  //年月日时分秒
    SPDatePickerModeTime,                  //时分
    SPDatePickerModeTimeAndSecond,         //时分秒
    SPDatePickerModeMinuteAndSecond,       //分秒
};

@protocol SPDateTimePickerViewDelegate <NSObject>
@optional
/**
 * 确定按钮
 */
- (void)didClickFinishDateTimePickerView:(NSString*)date;
/**
 * 取消按钮
 */
- (void)didClickCancelDateTimePickerView;
@end

@interface SPDateTimePickerView : UIView
/**
 * 设置当前时间
 */
@property(nonatomic, strong)NSDate *currentDate;
/**
 * 设置中心标题文字
 */
@property(nonatomic, copy)NSString *title;

@property(nonatomic, strong)id<SPDateTimePickerViewDelegate>delegate;
/**
 * 时间模式
 */
@property (nonatomic, assign)SPDatePickerViewMode pickerViewMode;

/**
 * 隐藏
 */
- (void)hideDateTimePickerView;
/**
 * 显示
 */
- (void)showDateTimePickerView;
@end
NS_ASSUME_NONNULL_END
