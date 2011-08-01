//
//  PullTableViewController.h
//  TableViewPull
//
//  Created by Emre Ergenekon on 2011-07-30.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"

@interface PullTableViewController : UITableViewController <PullTableViewDelegate>{
    NSUInteger numberOfCells;
}

@end
