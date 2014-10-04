//
//  kjvBibleSelectViewController.h
//  kjvBibleViewer
//
//  Created by Hyunji Cho on 2014. 5. 21..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface kjvBibleSelectViewController : UITableViewController
{
    NSMutableArray *bible_files; // 모든성경
    NSMutableArray *bible_files_multi;
    NSMutableArray *bible_files_remain; // 지금보는 성경 뺴고 나머지 모두
    int selectedCell;
}
- (IBAction)leftNavBarButtonClick:(id)sender;
@end
