//
//  kjvBibleViewController.h
//  kjvBibleViewer
//
//  Created by chan on 14. 5. 13..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"

// 검색중에는 자동업데이트금지/장-챕터고르기 금지 시키는 변수
static int verseid = 0; // 펑션에서 불러올때 값을 홀딩해야함. disappear에서 초기화 처리 함
static BOOL doSearch = NO; // disappear에서 초기화 처리 함
static BOOL refreshDownLock = YES; // 초기화 처리할 필요 없음
static BOOL doviewDidLoad = NO; // viewdidload에서 초기화 처리 함

@interface kjvBibleViewController : UITableViewController <MNMBottomPullToRefreshManagerClient>
{
    UIRefreshControl *refreshControl;
    
    NSString *BookName; // 현재 보고있는 성경역본의 이름
    NSString *a_BookName; // 얼터 역본 이름
    NSString *readBible; // 읽은 성경 범위
    NSString *BibleName;
    NSArray *highlightRange; // 사용자 밑줄 해야할 범위
    NSMutableArray *selectedRows; // 선택된 내용 저장
    
    // 최초 오픈시 설정되어있던 성경과 챕터
    int startChapterid;
    int startBookid;
    int lastChapterid;
    
    // 현재 설정된 성경과 챕터
    int bookid;
    int chapterid;
    
    // 나타내야할 셀 갯수
    int cellCount;
    
    NSMutableArray *contents;
    NSMutableArray *chapterVerseCount;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
}
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (strong, nonatomic) IBOutlet UIButton *navTitleBibleButton;
@property (strong, nonatomic) IBOutlet UIButton *navTitleChapterButton;
- (IBAction)navTitleBibleClick:(UIButton *)sender;
- (IBAction)navTitleChapterClick:(UIButton *)sender;
- (IBAction)leftNavBarButtonClick:(id)sender;

+ (void)saveTargetedid:(int)book_id chapterid:(int)chapter_id;
+ (void)setdoviewDidLoad:(BOOL)toggle;
+ (void)setdoSearch:(int)book_id chapterid:(int)chapter_id verse:(int)_verse;
@end
