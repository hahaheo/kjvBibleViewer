//
//  kjvSearchViewController.h
//  kjvBibleViewer
//
//  Created by chan on 14. 5. 14..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"

static MNMBottomPullToRefreshManager *pullToRefreshManager_;

@interface kjvSearchViewController : UIViewController <MNMBottomPullToRefreshManagerClient, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    int SEARCH_SPACE_LEVEL;
    BOOL is_not_input_Search;
    BOOL is_not_bookname;
    NSMutableArray *contents;
    UIFont *font;
}
- (IBAction)leftNavBarButtonClick:(id)sender;
@property (strong, nonatomic) IBOutlet UISearchBar *SearchBar;
@property (strong, nonatomic) IBOutlet UITableView *TableView;


@end
