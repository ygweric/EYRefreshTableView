//
//  EGOTableViewPullRefreshDemoAppDelegate.h
//  EGOTableViewPullRefreshDemo
//
//  Created by Emre Berge Ergenekon on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EGOTableViewPullRefreshDemoViewController;

@interface EGOTableViewPullRefreshDemoAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, strong) IBOutlet EGOTableViewPullRefreshDemoViewController *viewController;

@end
