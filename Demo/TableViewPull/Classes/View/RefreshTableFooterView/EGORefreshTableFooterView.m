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

#import "EGORefreshTableFooterView.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f
#define PullLoadMoreViewAreaHeight 60.0f
#define PullLoadMoreViewTriggerHeight 65.0f


@interface EGORefreshTableFooterView (Private)
- (void)setState:(EGOPullLoadMoreState)aState;
- (CGFloat) normalizedOffsetFromScrollView:(UIScrollView *) scrollView;
@end

@implementation EGORefreshTableFooterView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, ((PullLoadMoreViewAreaHeight-20.0f)/2), self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		[label release];
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(25.0f, 10.0f, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"blueArrow.png"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(35.0f, ((PullLoadMoreViewAreaHeight-20.0f)/2), 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		[view release];
		
		
		[self setState:EGOOPullLoadMoreNormal];
		
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters


- (void)setState:(EGOPullLoadMoreState)aState{
	
	switch (aState) {
		case EGOOPullLoadMorePulling:
			
			_statusLabel.text = NSLocalizedString(@"Release to load more...", @"Release to load more status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			break;
		case EGOOPullLoadMoreNormal:
			
			if (_state == EGOOPullLoadMorePulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
				[CATransaction commit];
			}
			
			_statusLabel.text = NSLocalizedString(@"Pull up to load more...", @"Pull up to load more status");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
						
			break;
		case EGOOPullLoadMoreLoading:
			
			_statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

- (CGFloat) normalizedOffsetFromScrollView:(UIScrollView *) scrollView
{
    CGFloat scrollAreaContenHeight = scrollView.contentSize.height;
    
    CGFloat headerHeight = self.bounds.size.height; // Our hight is same as the refresh header height, wich is a subview to tableview and part of the content height.
    CGFloat visibleTableHeight = MIN(scrollView.bounds.size.height, (scrollAreaContenHeight - headerHeight));
    CGFloat scrolledDistance = scrollView.contentOffset.y + headerHeight + visibleTableHeight; // If scrolled all the way down this should add upp to the content heigh.
    
    CGFloat normalizedOffset = scrolledDistance - scrollAreaContenHeight;
    
    return normalizedOffset;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoLoadMoreScrollViewDidScroll:(UIScrollView *)scrollView {	
    
    
    
    CGFloat normalizedOffset = [self normalizedOffsetFromScrollView:scrollView];

	if (_state == EGOOPullLoadMoreLoading) {
        /* This fix is not neccessary for footer */
        /*
		CGFloat offset = MAX(normalizedOffset, 0);
		offset = MIN(offset, PullLoadMoreViewAreaHeight);
        UIEdgeInsets currentInsets = scrollView.contentInset;
        currentInsets.bottom = -self.bounds.size.height +offset;
        scrollView.contentInset = currentInsets; */
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoLoadMoreTableFooterDataSourceIsLoading:)]) {
			_loading = [_delegate egoLoadMoreTableFooterDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullLoadMorePulling && normalizedOffset < (PullLoadMoreViewAreaHeight) && normalizedOffset > 0.0f && !_loading) {
			[self setState:EGOOPullLoadMoreNormal];
		} else if (_state == EGOOPullLoadMoreNormal && normalizedOffset > PullLoadMoreViewTriggerHeight && !_loading) {
			[self setState:EGOOPullLoadMorePulling];
		}
		
		if (scrollView.contentInset.bottom != -self.bounds.size.height) {
            UIEdgeInsets currentInsets = scrollView.contentInset;
            currentInsets.bottom = -self.bounds.size.height;
			scrollView.contentInset = currentInsets;
		}
		
	}
	
}

- (void)egoLoadMoreScrollViewDidEndDragging:(UIScrollView *)scrollView {
    
    CGFloat normalizedOffset = [self normalizedOffsetFromScrollView:scrollView];

	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoLoadMoreTableFooterDataSourceIsLoading:)]) {
		_loading = [_delegate egoLoadMoreTableFooterDataSourceIsLoading:self];
	}
	
	if (normalizedOffset >= PullLoadMoreViewTriggerHeight && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoLoadMoreTableFooterDidTriggerRefresh:)]) {
			[_delegate egoLoadMoreTableFooterDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullLoadMoreLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
        UIEdgeInsets currentInsets = scrollView.contentInset;
        currentInsets.bottom =  PullLoadMoreViewAreaHeight - self.bounds.size.height;
        scrollView.contentInset = currentInsets;
		[UIView commitAnimations];

		
	}
	
}

- (void)egoLoadMoreScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom = -self.bounds.size.height;
    scrollView.contentInset = currentInsets;
	[UIView commitAnimations];
	
	[self setState:EGOOPullLoadMoreNormal];

}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
    [super dealloc];
}




@end
