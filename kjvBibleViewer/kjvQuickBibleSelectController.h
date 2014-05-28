//
//  kjvQuickBibleSelectController.h
//  kjvBibleViewer
//
//  Created by Hyunji Cho on 2014. 5. 18..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface kjvQuickBibleSelectController : UIViewController <UITableViewDelegate, UITableViewDataSource>
- (IBAction)bibleViewSelect:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *bibleQuickView;
@property (strong, nonatomic) IBOutlet UITableView *bibleListView;
@property (strong, nonatomic) NSArray *BibleList;
@property (strong, nonatomic) IBOutlet UISegmentedControl *bibleSegControl;
@end
