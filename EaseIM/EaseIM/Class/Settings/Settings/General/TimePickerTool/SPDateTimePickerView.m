//
//  SPDateTimePickerView.m
//  EaseIM
//
//  Created by 娜塔莎 on 2019/11/29.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "SPDateTimePickerView.h"

#define ScreenWith   [UIScreen mainScreen].bounds.size.width
#define ScreenHeight self.frame.size.height
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
// 获取RGB颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]

@interface SPDateTimePickerView()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSInteger yearRange;
    NSInteger dayRange;
    NSInteger startYear;
    NSInteger selectedYear;
    NSInteger selectedMonth;
    NSInteger selectedDay;
    NSInteger selectedHour;
    NSInteger selectedMinute;
    NSInteger selectedSecond;
    NSCalendar *calendar;
    
}
@property (nonatomic,strong) UIView *contentView; //背景View
@property (nonatomic,strong) UIPickerView *pickerView;
@property (nonatomic,strong) UIView *upView; //盛放按钮的View
@property (nonatomic,strong) UIButton *cancelButton; //左边退出按钮
@property (nonatomic,strong) UIButton *chooseButton; //右边的确定按钮
@property (nonatomic,strong) UILabel *titleLabel; //标题
@property (nonatomic,strong) UILabel *durationLabel; //开始-结束分隔线
@property (nonatomic,strong) UIView *splitView; //分割线
@property (nonatomic,strong) NSString *string;
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) NSArray *columnArray;//存放每种情况需要分割的列
@end

@implementation SPDateTimePickerView
#pragma mark - 懒加载
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWith, 220)];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}
- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, 180)];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.dataSource=self;
        _pickerView.delegate=self;
    }
    return _pickerView;
}
- (UIView *)upView{
    if (!_upView) {
        _upView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        _upView.backgroundColor = [UIColor whiteColor];
    }
    return _upView;
}
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(12, 0, 40, 40);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [UIColor clearColor];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelButton setTitleColor:UIColorFromRGB(0x0d8bf5) forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}
- (UIButton *)chooseButton {
    if (!_chooseButton) {
        _chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _chooseButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 52, 0, 40, 40);
        [_chooseButton setTitle:@"确定" forState:UIControlStateNormal];
        _chooseButton.backgroundColor = [UIColor clearColor];
        _chooseButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_chooseButton setTitleColor:UIColorFromRGB(0x0d8bf5) forState:UIControlStateNormal];
        [_chooseButton addTarget:self action:@selector(configButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chooseButton;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.cancelButton.frame), 0, ScreenWith - 104, 40)];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
       // _titleLabel.text = @"设置时间段";
    }
    return _titleLabel;
}
- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = [UIColor blackColor];
        _durationLabel.font = [UIFont systemFontOfSize:16];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.text = @"~";
    }
    return _durationLabel;
}
- (UIView *)splitView {
    if (!_splitView) {
        _splitView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, 0.5)];
        _splitView.backgroundColor = UIColorFromRGB(0xe6e6e6);
    }
    return _splitView;
}
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = RGBA(0, 0, 0, 0.5);
        self.alpha = 0;
        // 存放每种情况需要分割的列
        self.columnArray = @[@(1),@(2),@(3),@(4),@(5),@(6),@(2),@(3),@(2)];
    }
    return self;
}

- (void)_setupSubviews
{
    // 1.添加子控件
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.pickerView];
    [self.contentView addSubview:self.upView];
    [self.upView addSubview:self.cancelButton];
    [self.upView addSubview:self.chooseButton];
    [self.upView addSubview:self.titleLabel];
    [self.upView addSubview:self.splitView];
    [self.contentView addSubview:self.durationLabel];
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@20);
        make.centerX.centerY.equalTo(self.pickerView);
    }];
}

#pragma mark - setter
- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

#pragma mark - UIPickerViewDataSource
// 多少列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [self.columnArray[self.pickerViewMode] integerValue];
}
//确定每一列返回的东西
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (self.pickerViewMode) {
        case SPDatePickerModeYear: //年
        {
            switch (component) {
                case 0:
                {
                    return yearRange;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case SPDatePickerModeYearAndMonth://年月
        {
            switch (component) {
                case 0:
                {
                    return yearRange;
                }
                    break;
                case 1:
                {
                    return 12;
                }
                    
                default:
                    break;
            }
        }
            break;
        case SPDatePickerModeDate://年月日
        {
            switch (component) {
                case 0:
                {
                    return yearRange;
                }
                    break;
                case 1:
                {
                    return 12;
                }
                case 2:
                {
                    return dayRange;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case SPDatePickerModeDateHour://年月日时
        {
            switch (component) {
                case 0:
                {
                    return yearRange;
                }
                    break;
                case 1:
                {
                    return 12;
                }
                case 2:
                {
                    return dayRange;
                }
                    break;
                case 3:
                {
                    return 24;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case SPDatePickerModeDateHourMinute://年月日时分
        {
            switch (component) {
                case 0:
                {
                    return yearRange;
                }
                    break;
                case 1:
                {
                    return 12;
                }
                case 2:
                {
                    return dayRange;
                }
                    break;
                case 3:
                {
                    return 24;
                }
                    break;
                case 4:
                {
                    return 60;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case SPDatePickerModeDateHourMinuteSecond://年月日时分秒
        {
            switch (component) {
                case 0:
                {
                    return yearRange;
                }
                    break;
                case 1:
                {
                    return 12;
                }
                case 2:
                {
                    return dayRange;
                }
                    break;
                case 3:
                {
                    return 24;
                }
                    break;
                case 4:
                {
                    return 60;
                }
                    break;
                case 5:
                {
                    return 60;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case SPDatePickerModeTime://时分
        {
            switch (component) {
                    
                case 0:
                {
                    return 24;
                }
                    break;
                case 1:
                {
                    return 24;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case SPDatePickerModeTimeAndSecond://时分秒
        {
            switch (component) {
                    
                case 0:
                {
                    return 24;
                }
                    break;
                case 1:
                {
                    return 60;
                }
                    break;
                case 2:
                {
                    return 60;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case SPDatePickerModeMinuteAndSecond://分秒
        {
            switch (component) {
                    
                case 0:
                {
                    return 60;
                }
                    break;
                case 1:
                {
                    return 60;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    return 0;
}
#pragma mark  UIPickerViewDelegate
// 默认时间的处理
-(void)setCurrentDate:(NSDate *)currentDate
{
    // 获取当前时间
    NSCalendar *calendar0 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags =  NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    comps = [calendar0 components:unitFlags fromDate:currentDate];
    NSInteger year   = [comps year];
    NSInteger month  = [comps month];
    NSInteger day    = [comps day];
    NSInteger hour   = [comps hour];
    NSInteger minute = [comps minute];
    NSInteger second = [comps second];
    
    selectedYear     = year;
    selectedMonth    = month;
    selectedDay      = day;
    selectedHour     = hour;
    selectedMinute   = minute;
    selectedSecond   = second;
    startYear = year-15;
    yearRange = 50;
    
    dayRange = [self isAllDay:year andMonth:month];
    
    switch (self.pickerViewMode) {
        case 0:
        {
            [self.pickerView selectRow:year-startYear inComponent:0 animated:NO];
            [self pickerView:self.pickerView didSelectRow:year-startYear inComponent:0];

        }
            break;
        case 1:
        {
            [self.pickerView selectRow:year-startYear inComponent:0 animated:NO];
            [self.pickerView selectRow:month-1 inComponent:1 animated:NO];
            
            [self pickerView:self.pickerView didSelectRow:year-startYear inComponent:0];
            [self pickerView:self.pickerView didSelectRow:month-1 inComponent:1];
        }
            break;
        case 2:
        {
            [self.pickerView selectRow:year-startYear inComponent:0 animated:NO];
            [self.pickerView selectRow:month-1 inComponent:1 animated:NO];
            [self.pickerView selectRow:day-1 inComponent:2 animated:NO];
            
            [self pickerView:self.pickerView didSelectRow:year-startYear inComponent:0];
            [self pickerView:self.pickerView didSelectRow:month-1 inComponent:1];
            [self pickerView:self.pickerView didSelectRow:day-1 inComponent:2];
        }
            break;
        case 3:
        {
            [self.pickerView selectRow:year-startYear inComponent:0 animated:NO];
            [self.pickerView selectRow:month-1 inComponent:1 animated:NO];
            [self.pickerView selectRow:day-1 inComponent:2 animated:NO];
            [self.pickerView selectRow:hour inComponent:3 animated:NO];
            
            [self pickerView:self.pickerView didSelectRow:year-startYear inComponent:0];
            [self pickerView:self.pickerView didSelectRow:month-1 inComponent:1];
            [self pickerView:self.pickerView didSelectRow:day-1 inComponent:2];
            [self pickerView:self.pickerView didSelectRow:hour inComponent:3];
        }
            break;
        case 4:
        {
            [self.pickerView selectRow:year-startYear inComponent:0 animated:NO];
            [self.pickerView selectRow:month-1 inComponent:1 animated:NO];
            [self.pickerView selectRow:day-1 inComponent:2 animated:NO];
            [self.pickerView selectRow:hour inComponent:3 animated:NO];
            [self.pickerView selectRow:minute inComponent:4 animated:NO];
            
            [self pickerView:self.pickerView didSelectRow:year-startYear inComponent:0];
            [self pickerView:self.pickerView didSelectRow:month-1 inComponent:1];
            [self pickerView:self.pickerView didSelectRow:day-1 inComponent:2];
            [self pickerView:self.pickerView didSelectRow:hour inComponent:3];
            [self pickerView:self.pickerView didSelectRow:minute inComponent:4];
        }
            break;
        case 5:
        {
            [self.pickerView selectRow:year-startYear inComponent:0 animated:NO];
            [self.pickerView selectRow:month-1 inComponent:1 animated:NO];
            [self.pickerView selectRow:day-1 inComponent:2 animated:NO];
            [self.pickerView selectRow:hour inComponent:3 animated:NO];
            [self.pickerView selectRow:minute inComponent:4 animated:NO];
            [self.pickerView selectRow:second inComponent:5 animated:NO];

            
            [self pickerView:self.pickerView didSelectRow:year-startYear inComponent:0];
            [self pickerView:self.pickerView didSelectRow:month-1 inComponent:1];
            [self pickerView:self.pickerView didSelectRow:day-1 inComponent:2];
            [self pickerView:self.pickerView didSelectRow:hour inComponent:3];
            [self pickerView:self.pickerView didSelectRow:minute inComponent:4];
            [self pickerView:self.pickerView didSelectRow:second inComponent:5];

        }
            break;
        case 6:
        {
            [self.pickerView selectRow:hour inComponent:0 animated:NO];
            [self.pickerView selectRow:hour inComponent:1 animated:NO];
            
            [self pickerView:self.pickerView didSelectRow:hour inComponent:0];
            [self pickerView:self.pickerView didSelectRow:hour inComponent:1];
        }
            break;
        case 7:
        {
            [self.pickerView selectRow:hour inComponent:0 animated:NO];
            [self.pickerView selectRow:minute inComponent:1 animated:NO];
            [self.pickerView selectRow:second inComponent:2 animated:NO];
            
            [self pickerView:self.pickerView didSelectRow:hour inComponent:0];
            [self pickerView:self.pickerView didSelectRow:minute inComponent:1];
            [self pickerView:self.pickerView didSelectRow:second inComponent:2];
        }
            break;
        case 8:
        {
            [self.pickerView selectRow:minute inComponent:0 animated:NO];
            [self.pickerView selectRow:second inComponent:1 animated:NO];
            
            [self pickerView:self.pickerView didSelectRow:minute inComponent:0];
            [self pickerView:self.pickerView didSelectRow:second inComponent:1];
        }
            break;
            
        default:
            break;
    }
    
    [self.pickerView reloadAllComponents];
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel*label = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWith*component/6.0, 0,ScreenWith/6.0, 30)];
    label.font = [UIFont systemFontOfSize:15.0];
    label.tag = component*100+row;
    label.textAlignment = NSTextAlignmentCenter;
    
    
    switch (self.pickerViewMode) {
        case 0:
        {
            switch (component) {
                case 0:
                {
                    label.text = [NSString stringWithFormat:@"%ld年",(long)(startYear + row)];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        case 1:
        {
            switch (component) {
                case 0:
                {
                    label.text=[NSString stringWithFormat:@"%ld年",(long)(startYear + row)];
                }
                    break;
                case 1:
                {
                    label.text=[NSString stringWithFormat:@"%ld月",(long)row+1];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch (component) {
                case 0:
                {
                    label.text=[NSString stringWithFormat:@"%ld年",(long)(startYear + row)];
                }
                    break;
                case 1:
                {
                    label.text=[NSString stringWithFormat:@"%ld月",(long)row+1];
                }
                    break;
                case 2:
                {
                    
                    label.text=[NSString stringWithFormat:@"%ld日",(long)row+1];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 3:
        {
            switch (component) {
                case 0:
                {
                    label.text=[NSString stringWithFormat:@"%ld年",(long)(startYear + row)];
                }
                    break;
                case 1:
                {
                    label.text=[NSString stringWithFormat:@"%ld月",(long)row+1];
                }
                    break;
                case 2:
                {
                    
                    label.text=[NSString stringWithFormat:@"%ld日",(long)row+1];
                }
                    break;
                case 3:
                {
                    label.text=[NSString stringWithFormat:@"%ld时",(long)row];
                }
                    break;
                    
                default:
                    break;
            }
            label.textAlignment=NSTextAlignmentCenter;

        }
            break;
        case 4:
        {
            switch (component) {
                case 0:
                {
                    label.text=[NSString stringWithFormat:@"%ld年",(long)(startYear + row)];
                }
                    break;
                case 1:
                {
                    label.text=[NSString stringWithFormat:@"%ld月",(long)row+1];
                }
                    break;
                case 2:
                {
                    
                    label.text=[NSString stringWithFormat:@"%ld日",(long)row+1];
                }
                    break;
                case 3:
                {
                    label.text=[NSString stringWithFormat:@"%ld时",(long)row];
                }
                    break;
                case 4:
                {
                    label.text=[NSString stringWithFormat:@"%ld分",(long)row];
                }
                    break;
                    
                default:
                    break;
            }
            label.textAlignment=NSTextAlignmentCenter;

        }
            break;
        case 5:
        {
            switch (component) {
                case 0:
                {
                    label.text=[NSString stringWithFormat:@"%ld年",(long)(startYear + row)];
                }
                    break;
                case 1:
                {
                    label.text=[NSString stringWithFormat:@"%ld月",(long)row+1];
                }
                    break;
                case 2:
                {
                    
                    label.text=[NSString stringWithFormat:@"%ld日",(long)row+1];
                }
                    break;
                case 3:
                {
                    label.text=[NSString stringWithFormat:@"%ld时",(long)row];
                }
                    break;
                case 4:
                {
                    label.text=[NSString stringWithFormat:@"%ld分",(long)row];
                }
                    break;
                case 5:
                {
                    label.text=[NSString stringWithFormat:@"%ld秒",(long)row];
                }
                    break;
                    
                default:
                    break;
            }
            label.textAlignment=NSTextAlignmentCenter;
            
        }
            break;
        case 6:
        {
            switch (component) {
                case 0:
                {
                    label.textAlignment=NSTextAlignmentLeft;
                    label.text=[NSString stringWithFormat:@"%ld : 00",(long)row];
                }
                    break;
                case 1:
                {
                    label.textAlignment=NSTextAlignmentRight;
                    label.text=[NSString stringWithFormat:@"%ld : 00",((long)row + 1)];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 7:
        {
            switch (component) {
                case 0:
                {
                    label.textAlignment=NSTextAlignmentLeft;
                    label.text=[NSString stringWithFormat:@"%ld时",(long)row];
                }
                    break;
                case 1:
                {
                    label.textAlignment=NSTextAlignmentCenter;
                    label.text=[NSString stringWithFormat:@"%ld分",(long)row];
                }
                    break;
                case 2:
                {
                    label.textAlignment=NSTextAlignmentRight;
                    label.text=[NSString stringWithFormat:@"%ld秒",(long)row];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 8:
        {
            switch (component) {
                case 0:
                {
                    label.textAlignment=NSTextAlignmentLeft;
                    label.text=[NSString stringWithFormat:@"%ld分",(long)row];
                }
                    break;
                case 1:
                {
                    label.textAlignment=NSTextAlignmentRight;
                    label.text=[NSString stringWithFormat:@"%ld秒",(long)row];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    return label;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return ([UIScreen mainScreen].bounds.size.width-40)/[self.columnArray[self.pickerViewMode] integerValue];
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30;
}

// 监听picker的滑动
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    
    switch (self.pickerViewMode) {
        case 0:
        {
            switch (component) {
                case 0:
                {
                    selectedYear = startYear + row;
                    dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                }
                    break;
                    
                default:
                    break;
            }
            
            _string =[NSString stringWithFormat:@"%ld",
                      selectedYear];
        }
            break;
        case 1:
        {
            switch (component) {
                case 0:
                {
                    selectedYear=startYear + row;
                    dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                }
                    break;
                case 1:
                {
                    selectedMonth=row+1;
                    dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                }
                    break;
                    
                default:
                    break;
            }
            
            _string =[NSString stringWithFormat:@"%ld-%.2ld",
                      selectedYear,
                      selectedMonth];
        }
            break;
        case 2:
        {
            switch (component) {
                case 0:
                {
                    selectedYear=startYear + row;
                    dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                }
                    break;
                case 1:
                {
                    selectedMonth=row+1;
                    dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                }
                    break;
                case 2:
                {
                    selectedDay=row+1;
                }
                    break;
                    
                default:
                    break;
            }
            
            _string =[NSString stringWithFormat:@"%ld-%.2ld-%.2ld",
                      selectedYear,
                      selectedMonth,
                      selectedDay];
        }
            break;
        case 3:
        {
            switch (component) {
                case 0:
                {
                    selectedYear=startYear + row;
                    dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                }
                    break;
                case 1:
                {
                    selectedMonth=row+1;
                    dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                }
                    break;
                case 2:
                {
                    selectedDay=row+1;
                }
                    break;
                case 3:
                {
                    selectedHour=row;
                }
                    break;
                    
                default:
                    break;
            }
            
            _string =[NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld",
                      selectedYear,
                      selectedMonth,
                      selectedDay,
                      selectedHour];
        }
            break;
        case 4:
        {
            switch (component) {
                case 0:
                {
                    selectedYear=startYear + row;
                    dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                }
                    break;
                case 1:
                {
                    selectedMonth=row+1;
                    dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                }
                    break;
                case 2:
                {
                    selectedDay=row+1;
                }
                    break;
                case 3:
                {
                    selectedHour=row;
                }
                    break;
                case 4:
                {
                    selectedMinute=row;
                }
                    break;
                    
                default:
                    break;
            }
            
            _string =[NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld",
                      selectedYear,
                      selectedMonth,
                      selectedDay,
                      selectedHour,
                      selectedMinute];
        }
            break;
        case 5:
        {
            switch (component) {
                case 0:
                {
                    selectedYear=startYear + row;
                    dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                }
                    break;
                case 1:
                {
                    selectedMonth=row+1;
                    dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                }
                    break;
                case 2:
                {
                    selectedDay=row+1;
                }
                    break;
                case 3:
                {
                    selectedHour=row;
                }
                    break;
                case 4:
                {
                    selectedMinute=row;
                }
                    break;
                case 5:
                {
                    selectedSecond=row;
                }
                    break;
                    
                default:
                    break;
            }
            
            _string =[NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld %.2ld",
                      selectedYear,
                      selectedMonth,
                      selectedDay,
                      selectedHour,
                      selectedMinute,
                      selectedSecond];
        }
            break;
        case 6:
        {
            switch (component) {
                case 0:
                {
                    selectedHour=row;
                }
                    break;
                case 1:
                {
                    selectedMinute=row+1;
                }
                    break;
                    
                default:
                    break;
            }
            
            _string = [NSString stringWithFormat:@"%ld-%ld",selectedHour,selectedMinute];
        }
            break;
        case 7:
        {
            switch (component) {
                case 0:
                {
                    selectedHour=row;
                }
                    break;
                case 1:
                {
                    selectedMinute=row;
                }
                    break;
                case 2:
                {
                    selectedSecond=row;
                }
                    break;
                    
                default:
                    break;
            }
            
            _string = [NSString stringWithFormat:@"%.2ld:%.2ld %.2ld",
                       selectedHour,
                       selectedMinute,
                       selectedSecond];
        }
            break;
        case 8:
        {
            switch (component) {
                case 0:
                {
                    selectedMinute=row;
                }
                    break;
                case 1:
                {
                    selectedSecond=row;
                }
                    break;
                    
                default:
                    break;
            }
            
            _string = [NSString stringWithFormat:@"%.2ld %.2ld",
                       selectedMinute,
                       selectedSecond];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - show and hidden
- (void)showDateTimePickerView{
    [self _setupSubviews];
    [self setCurrentDate:[NSDate date]];
    self.frame = CGRectMake(0, 0, ScreenWith, ScreenHeight);
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1;
        self.contentView.frame = CGRectMake(0, ScreenHeight-220, ScreenWith, 220);
        
    } completion:^(BOOL finished) {
        
    }];
}
- (void)hideDateTimePickerView{
    
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 0;
        self.contentView.frame = CGRectMake(0, ScreenHeight, ScreenWith, 220);
    } completion:^(BOOL finished) {
        self.frame = CGRectMake(0, ScreenHeight, ScreenWith, ScreenHeight);
    }];
    
}
#pragma mark - private Function
//取消的隐藏
- (void)cancelButtonClick
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickCancelDateTimePickerView)]) {
        [self.delegate didClickCancelDateTimePickerView];
    }
    
    [self hideDateTimePickerView];
    
}

//确认的隐藏
-(void)configButtonClick
{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickFinishDateTimePickerView:)]) {
        [self.delegate didClickFinishDateTimePickerView:_string];
    }
    
    [self hideDateTimePickerView];
}

-(NSInteger)isAllDay:(NSInteger)year andMonth:(NSInteger)month
{
    int day=0;
    switch(month)
    {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            day=31;
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            day=30;
            break;
        case 2:
        {
            if(((year%4==0)&&(year%100!=0))||(year%400==0))
            {
                day=29;
                break;
            }
            else
            {
                day=28;
                break;
            }
        }
        default:
            break;
    }
    return day;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hideDateTimePickerView];
}
@end
