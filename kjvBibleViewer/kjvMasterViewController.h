//
//  kjvMasterViewController.h
//  kjvBibleViewer
//
//  Created by chan on 14. 5. 13..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface kjvMasterViewController : UITableViewController
@property (nonatomic, strong) NSArray *menuItems;
@property (weak, nonatomic) IBOutlet UILabel *Title;
@end
