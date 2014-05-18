//
//  kjvBibleViewController.h
//  kjvBibleViewer
//
//  Created by chan on 14. 5. 13..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"

static NSString * BookName;
static NSString * a_BookName;
static NSString * readBible;

// 최초 오픈시 설정되어있던 성경과 챕터
static int startChapterid;
static int startBookid;

// 현재 설정된 성경과 챕터
static int bookid;
static int chapterid;

// 나타내야할 셀 갯수
static int cellCount;

static BOOL refreshDownLock = YES;
static NSMutableArray *contents;
static NSMutableArray *chapterVerseCount;
static MNMBottomPullToRefreshManager *pullToRefreshManager_;

@interface kjvBibleViewController : UITableViewController <MNMBottomPullToRefreshManagerClient>
{
    UIRefreshControl *refreshControl;
}
@property (strong, nonatomic) IBOutlet UIButton *navTitleBibleButton;
@property (strong, nonatomic) IBOutlet UIButton *navTitleChapterButton;
- (IBAction)SelectChapter:(UIButton *)sender;

- (void)saveTargetedid:(int)book_id chapterid:(int)chapter_id;
@end
