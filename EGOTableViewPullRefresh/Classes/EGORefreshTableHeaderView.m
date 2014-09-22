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


@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat midY = frame.size.height - PULL_AREA_HEIGTH/2;
		
        isLoading = NO;
        if (NO) {//README show activity only
            
            /* Config Last Updated Label */
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, midY, self.frame.size.width, 20.0f)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.font = [UIFont systemFontOfSize:12.0f];
            label.shadowOffset = CGSizeMake(0.0f, 1.0f);
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentCenter;
            [self addSubview:label];
            _lastUpdatedLabel=label;
            
            /* Config Status Updated Label */
            label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, midY - 18, self.frame.size.width, 20.0f)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.font = [UIFont boldSystemFontOfSize:13.0f];
            label.shadowOffset = CGSizeMake(0.0f, 1.0f);
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentCenter;
            [self addSubview:label];
            _statusLabel=label;
            
            /* Config Arrow Image */
            CALayer *layer = [[CALayer alloc] init];
            layer.frame = CGRectMake(25.0f,midY - 35, 30.0f, 55.0f);
            layer.contentsGravity = kCAGravityResizeAspect;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                layer.contentsScale = [[UIScreen mainScreen] scale];
            }
#endif
            [[self layer] addSublayer:layer];
            _arrowImage=layer;
            
        }
        /* Config activity indicator */
        _circleView = [[CircleView alloc] initWithFrame:CGRectMake(95, midY - 8, 26, 26)];
        [self addSubview:_circleView];
		
		[self setState:EGOOPullNormal];
        
        /* Configure the default colors and arrow image */
        [self setBackgroundColor:nil textColor:nil arrowImage:nil];
		
    }
	
    return self;
	
}


#pragma mark -
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
            
            if(timeToDisplay == /* Singular*/ 1) {
            _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld minute ago",@"PullTableViewLan",@"Last uppdate in minutes singular"),(long)timeToDisplay];
            } else {
                /* Plural */
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld minutes ago",@"PullTableViewLan",@"Last uppdate in minutes plural"), (long)timeToDisplay];

            }
            
        } else if (timeSinceLastUpdate < aDay) {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / anHour);
            if(timeToDisplay == /* Singular*/ 1) {
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld hour ago",@"PullTableViewLan",@"Last uppdate in hours singular"), (long)timeToDisplay];
            } else {
                /* Plural */
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld hours ago",@"PullTableViewLan",@"Last uppdate in hours plural"), (long)timeToDisplay];
                
            }
            
        } else {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / aDay);
            if(timeToDisplay == /* Singular*/ 1) {
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld day ago",@"PullTableViewLan",@"Last uppdate in days singular"), (long)timeToDisplay];
            } else {
                /* Plural */
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld days ago",@"PullTableViewLan",@"Last uppdate in days plural"), (long)timeToDisplay];
            }
            
        }
        
    } else {
        _lastUpdatedLabel.text = nil;
    }
    
    // Center the status label if the lastupdate is not available
    CGFloat midY = self.frame.size.height - PULL_AREA_HEIGTH/2;
    if(!_lastUpdatedLabel.text) {
        _statusLabel.frame = CGRectMake(0.0f, midY - 8, self.frame.size.width, 20.0f);
    } else {
        _statusLabel.frame = CGRectMake(0.0f, midY - 18, self.frame.size.width, 20.0f);
    }
    
}

- (void)setState:(EGOPullState)aState{
	
	switch (aState) {
		case EGOOPullPulling:
			
			_statusLabel.text = NSLocalizedStringFromTable(@"Release to refresh...",@"PullTableViewLan", @"Release to refresh status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case EGOOPullNormal:
			
			if (_state == EGOOPullPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
            } else {
                [self setProgress:0];
                [_circleView setNeedsDisplay];
            }
			
			_statusLabel.text = NSLocalizedStringFromTable(@"Pull down to refresh...",@"PullTableViewLan", @"Pull down to refresh status");
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullLoading:
        {
			_statusLabel.text = NSLocalizedStringFromTable(@"Loading...",@"PullTableViewLan", @"Loading Status");
			
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
            CABasicAnimation* rotate =  [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
            rotate.removedOnCompletion = FALSE;
            rotate.fillMode = kCAFillModeForwards;
            
            //Do a series of 5 quarter turns for a total of a 1.25 turns
            //(2PI is a full turn, so pi/2 is a quarter turn)
            [rotate setToValue: [NSNumber numberWithFloat: M_PI / 2]];
            rotate.repeatCount = 11;
            
            rotate.duration = 0.25;
            //            rotate.beginTime = start;
            rotate.cumulative = TRUE;
            rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            
            [_circleView.layer addAnimation:rotate forKey:@"rotateAnimation"];
        }
			break;
		default:
			break;
	}
	
	_state = aState;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor textColor:(UIColor *) textColor arrowImage:(UIImage *) arrowImage
{
    self.backgroundColor = backgroundColor? backgroundColor : DEFAULT_BACKGROUND_COLOR;
    
    if(textColor) {
        _lastUpdatedLabel.textColor = textColor;
        _statusLabel.textColor = textColor;
    } else {
        _lastUpdatedLabel.textColor = DEFAULT_TEXT_COLOR;
        _statusLabel.textColor = DEFAULT_TEXT_COLOR;
    }
    _lastUpdatedLabel.shadowColor = [_lastUpdatedLabel.textColor colorWithAlphaComponent:0.1f];
    _statusLabel.shadowColor = [_statusLabel.textColor colorWithAlphaComponent:0.1f];
    
    _arrowImage.contents = (id)(arrowImage? arrowImage.CGImage : DEFAULT_ARROW_IMAGE.CGImage);
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
		if (_state == EGOOPullPulling && scrollView.contentOffset.y > -PULL_TRIGGER_HEIGHT && scrollView.contentOffset.y < 0.0f && !isLoading) {
			[self setState:EGOOPullNormal];
		} else if (_state == EGOOPullNormal && scrollView.contentOffset.y < -PULL_AREA_MIN_HEIGTH && !isLoading) {
            float moveY = fabsf(scrollView.contentOffset.y);
            if (moveY > 65)
                moveY = 65;
            [self setProgress:(moveY-15) / (65-15)];
            [_circleView setNeedsDisplay];
            
            if (scrollView.contentOffset.y < -65.0f) {
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

- (void)startAnimatingWithScrollView:(UIScrollView *) scrollView {
    isLoading = YES;
    
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
	
	
	if (scrollView.contentOffset.y <= - PULL_TRIGGER_HEIGHT && !isLoading) {
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
            [_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
        }
        [self startAnimatingWithScrollView:scrollView];
	}
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	
    isLoading = NO;
    
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

- (void)dealloc {
	
	_delegate=nil;
}

- (void)setProgress:(float)p {
    _circleView.progress = p;
    _statusLabel.alpha = p;
    _lastUpdatedLabel.alpha = p;
}




@end
