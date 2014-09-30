//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "LoadMoreTableFooterView.h"
#import "CircleView.h"

typedef enum{
    EGOOPullPulling = 0,
    EGOOPullNormal,
    EGOOPullLoading,
} EGOPullState;


#define FLIP_ANIMATION_DURATION 0.18f

#define PULL_AREA_HEIGTH 50.0f
#define PULL_TRIGGER_HEIGHT (PULL_AREA_HEIGTH + 5.0f)
#define PULL_AREA_MIN_HEIGTH 20.0f


@interface LoadMoreTableFooterView ()
@property(nonatomic,assign) EGOPullState state;
@property(nonatomic,strong) CircleView *circleView;
@property(nonatomic,assign) BOOL isLoading;
@end

@implementation LoadMoreTableFooterView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _isLoading = NO;
        self.backgroundColor=[UIColor greenColor];
        {
            _circleView = [[CircleView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-13, 8, 26, 26)];;
            [self addSubview:_circleView];
        }
		[self setState:EGOOPullNormal]; // Also transform the image
    }
    return self;
}
-(void)setCircleColor:(UIColor *)circleColor{
    _circleColor=circleColor;
    if (_circleView) {
        _circleView.color=circleColor;
    }
}

#pragma mark - Util
- (CGFloat)scrollViewOffsetFromBottom:(UIScrollView *) scrollView
{
    CGFloat scrollAreaContenHeight = scrollView.contentSize.height;
    
    CGFloat visibleTableHeight = MIN(scrollView.bounds.size.height, scrollAreaContenHeight);
    CGFloat scrolledDistance = scrollView.contentOffset.y + visibleTableHeight; // If scrolled all the way down this should add upp to the content heigh.
    
    CGFloat normalizedOffset = scrollAreaContenHeight -scrolledDistance;
    
    return normalizedOffset;
    
}

- (CGFloat)visibleTableHeightDiffWithBoundsHeight:(UIScrollView *) scrollView
{
    return (scrollView.bounds.size.height - MIN(scrollView.bounds.size.height, scrollView.contentSize.height));
}


#pragma mark -
#pragma mark Setters


- (void)setState:(EGOPullState)aState{
	_state = aState;
	switch (aState) {
		case EGOOPullPulling:

            break;
		case EGOOPullNormal:
			[self setProgress:0];
			break;
		case EGOOPullLoading:
        {
            CABasicAnimation* rotate =  [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
            rotate.removedOnCompletion = FALSE;
            rotate.fillMode = kCAFillModeForwards;
            [rotate setToValue: [NSNumber numberWithFloat: M_PI / 2]];
            rotate.repeatCount = INT_MAX;
            rotate.duration = 0.25;
            rotate.cumulative = TRUE;
            rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            [_circleView.layer addAnimation:rotate forKey:@"rotateAnimation"];
        }
			break;
		default:
			break;
	}
}


#pragma mark -
#pragma mark ScrollView Methods


- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
    CGFloat bottomOffset = [self scrollViewOffsetFromBottom:scrollView];
	if (_state == EGOOPullLoading) {
		CGFloat offset = MAX(bottomOffset * -1, 0);
		offset = MIN(offset, PULL_AREA_HEIGTH);
        UIEdgeInsets currentInsets = scrollView.contentInset;
        currentInsets.bottom = offset? offset + [self visibleTableHeightDiffWithBoundsHeight:scrollView]: 0;
        scrollView.contentInset = currentInsets;
	} else if (scrollView.isDragging) {
		if (_state == EGOOPullPulling && bottomOffset > -PULL_TRIGGER_HEIGHT && bottomOffset < 0.0f && !_isLoading) {//error case
			[self setState:EGOOPullNormal];
		} else if (_state == EGOOPullNormal && bottomOffset < -PULL_AREA_MIN_HEIGTH && !_isLoading) {
            //bottomOffset = -67
            if (bottomOffset < -PULL_TRIGGER_HEIGHT)
                bottomOffset = -PULL_TRIGGER_HEIGHT;
            [self setProgress:((-bottomOffset)-PULL_AREA_MIN_HEIGTH) / (PULL_TRIGGER_HEIGHT-PULL_AREA_MIN_HEIGTH)];
            if (bottomOffset < -PULL_TRIGGER_HEIGHT) {
                [self setState:EGOOPullPulling];
            }
		}
		if (scrollView.contentInset.bottom != 0) {
            UIEdgeInsets currentInsets = scrollView.contentInset;
            currentInsets.bottom = 0;
            scrollView.contentInset = currentInsets;
		}
		
	}
	
}

- (void)startAnimatingWithScrollView:(UIScrollView *) scrollView {
    _isLoading = YES;
    [self setState:EGOOPullLoading];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom = PULL_AREA_HEIGTH + [self visibleTableHeightDiffWithBoundsHeight:scrollView];
    scrollView.contentInset = currentInsets;
    [UIView commitAnimations];
    if([self scrollViewOffsetFromBottom:scrollView] == 0){
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + PULL_TRIGGER_HEIGHT) animated:YES];
    }
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	
	if ([self scrollViewOffsetFromBottom:scrollView] <= - PULL_TRIGGER_HEIGHT && !_isLoading) {
        if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDidTriggerLoadMore:)]) {
            [_delegate loadMoreTableFooterDidTriggerLoadMore:self];
        }
        [self startAnimatingWithScrollView:scrollView];
    }
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	
    _isLoading = NO;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom = 0;
    scrollView.contentInset = currentInsets;
	[UIView commitAnimations];
    
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_circleView.layer removeAllAnimations];
    });
    
    [self setState:EGOOPullNormal];
}
- (void)egoRefreshScrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self setState:EGOOPullNormal];
}


#pragma mark -

- (void)setProgress:(float)p {
    _circleView.progress = p;
    [_circleView setNeedsDisplay];
}



@end
