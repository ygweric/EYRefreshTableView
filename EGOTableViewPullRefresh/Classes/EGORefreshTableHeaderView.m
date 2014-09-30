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

#import "EGORefreshTableHeaderView.h"


@interface EGORefreshTableHeaderView()

@property(nonatomic,assign) EGOPullState state;
@property(nonatomic,strong) UILabel *lastUpdatedLabel;
@property(nonatomic,strong) CircleView *circleView;
@property(nonatomic,assign) BOOL isLoading;
- (void)setState:(EGOPullState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat midY = frame.size.height - PULL_AREA_HEIGTH/2;
        _isLoading = NO;
        {
            /* Config Last Updated Label */
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, midY+12, self.frame.size.width, 20.0f)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.textColor=[UIColor blackColor];
            label.font = [UIFont systemFontOfSize:12.0f];
            label.shadowOffset = CGSizeMake(0.0f, 1.0f);
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            [self addSubview:label];
            _lastUpdatedLabel=label;
        }
        {
            _circleView = [[CircleView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-13, midY - 8-8, 26, 26)];;
            [self addSubview:_circleView];
        }
        [self setState:EGOOPullNormal];
    }
    return self;
}


#pragma mark -
-(void)setTextColor:(UIColor *)textColor{
    _textColor=textColor;
    if (_lastUpdatedLabel) {
        _lastUpdatedLabel.textColor=textColor;
    }
}
-(void)setCircleColor:(UIColor *)circleColor{
    _circleColor=circleColor;
    if (_circleView) {
        _circleView.color=circleColor;
    }
}
#pragma mark Setters

#define aMinute 60
#define anHour 3600
#define aDay 86400

- (void)refreshLastUpdatedDate {
    NSDate * date = nil;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
	}
    if(date) {
        NSTimeInterval timeSinceLastUpdate = [date timeIntervalSinceNow];
        NSInteger timeToDisplay = 0;
        timeSinceLastUpdate *= -1;
        if(timeSinceLastUpdate < anHour) {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / aMinute);
            if (timeToDisplay==0) {
                _lastUpdatedLabel.text = @"刚刚更新";
            } else {
                _lastUpdatedLabel.text = [NSString stringWithFormat:@"%ld分前更新", (long)timeToDisplay];
            }
        } else if (timeSinceLastUpdate < aDay) {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / anHour);
            _lastUpdatedLabel.text = [NSString stringWithFormat:@"%ld小时前更新", (long)timeToDisplay];
        } else {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / aDay);
             _lastUpdatedLabel.text =[NSString stringWithFormat:@"%ld天前更新", (long)timeToDisplay];
        }
    } else {
        _lastUpdatedLabel.text = @"下拉刷新";
    }
}

- (void)setState:(EGOPullState)aState{
	_state = aState;
	switch (aState) {
		case EGOOPullPulling:
			
            
			break;
		case EGOOPullNormal:
            [self setProgress:0];
            [self refreshLastUpdatedDate];
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
    
	if (_state == EGOOPullLoading) {
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, PULL_AREA_HEIGTH);
        UIEdgeInsets currentInsets = scrollView.contentInset;
        currentInsets.top = offset;
        scrollView.contentInset = currentInsets;
		
	} else if (scrollView.isDragging) {
		if (_state == EGOOPullPulling && scrollView.contentOffset.y > -PULL_TRIGGER_HEIGHT && scrollView.contentOffset.y < 0.0f && !_isLoading) {
			[self setState:EGOOPullNormal];
		} else if (_state == EGOOPullNormal && scrollView.contentOffset.y < -PULL_AREA_MIN_HEIGTH && !_isLoading) {
            float moveY = fabsf(scrollView.contentOffset.y);
            if (moveY > PULL_TRIGGER_HEIGHT)
                moveY = PULL_TRIGGER_HEIGHT;
            [self setProgress:(moveY-PULL_AREA_MIN_HEIGTH) / (PULL_TRIGGER_HEIGHT-PULL_AREA_MIN_HEIGTH)];
            if (scrollView.contentOffset.y < -PULL_TRIGGER_HEIGHT) {
                [self setState:EGOOPullPulling];
            }
        }
		if (scrollView.contentInset.top != 0) {
            UIEdgeInsets currentInsets = scrollView.contentInset;
            currentInsets.top = 0;
            scrollView.contentInset = currentInsets;
		}
		
	}
	
}
//refresh the tableview by program
- (void)startAnimatingWithScrollView:(UIScrollView *) scrollView {
    _isLoading = YES;
    [self setState:EGOOPullLoading];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.top = PULL_AREA_HEIGTH;
    scrollView.contentInset = currentInsets;
    [UIView commitAnimations];
    if(scrollView.contentOffset.y == 0){
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -PULL_TRIGGER_HEIGHT) animated:YES];
    }    
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	
	if (scrollView.contentOffset.y <= - PULL_TRIGGER_HEIGHT && !_isLoading) {
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
            [_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
        }
        [self startAnimatingWithScrollView:scrollView];
	}
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
    _isLoading = NO;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.top = 0;
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
    [self refreshLastUpdatedDate];
}


#pragma mark -
#pragma mark Dealloc

- (void)setProgress:(float)p {
    _circleView.progress = p;
    [_circleView setNeedsDisplay];
    _lastUpdatedLabel.alpha = p;
}




@end
