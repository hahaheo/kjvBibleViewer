//
//  kjvBibleDownloadViewController.h
//  kjvBibleViewer
//
//  Created by Hyunji Cho on 2014. 5. 21..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface kjvBibleDownloadViewController : UITableViewController
{
    NSArray *bible_files;
    NSMutableArray *availList; // 받을수 있는 역본이름
    NSMutableArray *availList_down; // 받을수 있는 역본파일이름
    BOOL is_internet_connectable;
}

@end
