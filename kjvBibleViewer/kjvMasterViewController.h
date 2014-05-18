//
//  kjvMasterViewController.h
//  kjvBibleViewer
//
//  Created by chan on 14. 5. 13..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class kjvDetailViewController;

@interface kjvMasterViewController : UITableViewController

@property (strong, nonatomic) kjvDetailViewController *detailViewController;

@end
