/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "EMFacialView.h"
#import "EMEmoji.h"
#import "EMFaceView.h"

@interface EMFacialView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation EMFacialView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _faces = [NSMutableArray arrayWithArray:[EMEmoji allEmoji]];
        _scrollview = [[UIScrollView alloc] initWithFrame:frame];
        _scrollview.pagingEnabled = YES;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.alwaysBounceHorizontal = YES;
        _scrollview.delegate = self;
        _pageControl = [[UIPageControl alloc] init];
        [self addSubview:_scrollview];
        [self addSubview:_pageControl];
    }
    return self;
}

-(void)loadFacialView
{
    for (UIView *view in [self.scrollview subviews]) {
        [view removeFromSuperview];
    }
    
    [_scrollview setContentOffset:CGPointZero];
	NSInteger maxRow = 4;
    NSInteger maxCol = 7;
    NSInteger pageSize = (maxRow - 1) * 7;
    CGFloat itemWidth = self.frame.size.width / maxCol;
    CGFloat itemHeight = self.frame.size.height / maxRow;
    
    CGRect frame = self.frame;
    frame.size.height -= itemHeight;
    _scrollview.frame = frame;
    
    NSInteger totalPage = [_faces count]%pageSize == 0 ? [_faces count]/pageSize : [_faces count]/pageSize + 1;
    [_scrollview setContentSize:CGSizeMake(totalPage * CGRectGetWidth(self.frame), itemHeight * (maxRow - 1))];
    
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = totalPage;
    _pageControl.frame = CGRectMake(0, (maxRow - 1) * itemHeight + 5, CGRectGetWidth(self.frame), itemHeight - 10);
    
    for (int i = 0; i < totalPage; i ++) {
        for (int row = 0; row < (maxRow - 1); row++) {
            for (int col = 0; col < maxCol; col++) {
                NSInteger index = i * pageSize + row * maxCol + col;
                if (index != 0 && (index - (pageSize-1))%pageSize == 0) {
                    [_faces insertObject:@"" atIndex:index];
                    break;
                }
                if (index < [_faces count]) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    [button setBackgroundColor:[UIColor clearColor]];
                    [button setFrame:CGRectMake(i * CGRectGetWidth(self.frame) + col * itemWidth, row * itemHeight, itemWidth, itemHeight)];
                    [button.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
                    [button setTitle: [_faces objectAtIndex:index] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
                    button.tag = index;
                    [_scrollview addSubview:button];
                }
                else{
                    break;
                }
            }
        }
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setBackgroundColor:[UIColor clearColor]];
        [deleteButton setFrame:CGRectMake(i * CGRectGetWidth(self.frame) + (maxCol - 1) * itemWidth, (maxRow - 2) * itemHeight, itemWidth, itemHeight)];
        [deleteButton setImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateNormal];
        [deleteButton setImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateHighlighted];
        deleteButton.tag = 10000;
        [deleteButton addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollview addSubview:deleteButton];
    }
}


-(void)selected:(UIButton*)bt
{
    if (bt.tag == 10000 && _delegate) {
        [_delegate deleteSelected:nil];
    } else{
        NSString *str = [_faces objectAtIndex:bt.tag];
        if (_delegate) {
            [_delegate selectedFacialView:str];
        }
    }
}

- (void)sendAction:(id)sender
{
    if (_delegate) {
        [_delegate sendFace];
    }
}

- (void)sendPngAction:(UIButton*)bt
{
    if (bt.tag == 10000 && _delegate) {
        [_delegate deleteSelected:nil];
    }else{
        NSString *str = [_faces objectAtIndex:bt.tag];
        if (_delegate) {
            str = [NSString stringWithFormat:@"\\::%@]",str];
            [_delegate selectedFacialView:str];
        }
    }
}

- (void)sendGifAction:(UIButton*)bt
{
    NSString *str = [_faces objectAtIndex:bt.tag];
    if (_delegate) {
        [_delegate sendFace:str];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset =  scrollView.contentOffset;
    if (offset.x == 0) {
        _pageControl.currentPage = 0;
    } else {
        int page = offset.x / CGRectGetWidth(scrollView.frame);
        _pageControl.currentPage = page;
    }
}

@end
