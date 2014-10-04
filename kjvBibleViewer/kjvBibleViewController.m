//
//  kjvBibleViewController.m
//  kjvBibleViewer
//
//  Created by chan on 14. 5. 13..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import "SWRevealViewController.h"
#import "global_variable.h"
#import "lfbContainer.h"
#import "DejalActivityView.h"
#import "kjvBibleViewController.h"
#import "kjvChapterSelectController.h"
#import "kjvBibleSelectController.h"
#import "kjvActivity.h"

@interface kjvBibleViewController ()

@end

@implementation kjvBibleViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    int color = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_color"];
    if(color == 1)
    {
        self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
        //self.navigationController.navigationBar.translucent = NO;
    }
    else
    {
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        //self.navigationController.navigationBar.translucent = YES;
    }
    // 다른view에서 새로고침이 필요한 경우 수행됨
    if(doviewDidLoad)
       [self viewDidLoad];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // 검색모드일 경우 변수 초기화
    if(doSearch)
    {
        //검색모드에서 나가는 경우 기존의 값 복원시켜주기
        if (([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_searchbookid"] != nil) && ([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_searchchapterid"] != nil))
        {
            [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"saved_searchbookid"] forKey:@"saved_bookid"];
            [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"saved_searchchapterid"] forKey:@"saved_chapterid"];
        }
        
        //검색모드 끄기 및 변수 초기화
        doSearch = NO;
        //verseHeight = 0.0;
        verseJumpid = 0;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    
    // 검색모드일때 백버튼 감추기
    // 버튼 감추기
    if(doSearch)
        self.navigationItem.leftBarButtonItem = nil;
        //self.navigationItem.hidesBackButton = YES;
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // 백버튼 컬러 변경하기
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    
    //필요 변수 초기화
    doviewDidLoad = NO;
    contents = [[NSMutableArray alloc] init];
    chapterVerseCount = [[NSMutableArray alloc] init];
    selectedRows = [[NSMutableArray alloc] init];
    cellCount = 0;
    self.title = @"읽기"; // back버튼을 위한 타이틀 초기화
    
    //저장소로 부터 미리 저장된 데이터 값 불러오기 - local Value
    if (([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_bookid"] == nil) || ([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_chapterid"] == nil))
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"saved_bookid"];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"saved_chapterid"];
    }
    
    bookid = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_bookid"];
    chapterid = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_chapterid"];
    // 값이 이상하면 무조껀 초기화
    if ((bookid > 66 || bookid < 1) || (chapterid > 150 || chapterid < 1 ))
    {
        NSLog(@"ERROR!!");
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"saved_bookid"];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"saved_chapterid"];
        bookid = 1;
        chapterid = 1;
    }
    startBookid = bookid;
    startChapterid = chapterid;
    lastChapterid = chapterid;
    
    //저장소로 부터 미리 저장된 데이터 값 불러오기 - static Value
    if (([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_bookname"] == nil) || ([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_another_bookname"] == nil) || ([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_readbible"] == nil))
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"saved_bookname"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"saved_another_bookname"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"saved_readbible"];
    }
    BookName = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_bookname"];
    a_BookName = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_another_bookname"];
    readBible = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_readbible"];
    BibleName = [[global_variable getNamedBookofBible] objectAtIndex:(bookid-1)];
    
    //저장소로 부터 미리 저장된 데이터 값 확인하기 - setting Value
    if (([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_fontsize"] == nil) || ([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_lineheightsize"] == nil) || ([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_color"] == nil) || ([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_lockscreen"] == nil) || ([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_defbibleselect"] == nil))
    {
        [[NSUserDefaults standardUserDefaults] setFloat:DEF_FONT_SIZE forKey:@"saved_fontsize"];
        [[NSUserDefaults standardUserDefaults] setFloat:DEF_FONT_GAP forKey:@"saved_lineheightsize"];
        [[NSUserDefaults standardUserDefaults] setInteger:COLOR_REVERSED forKey:@"saved_color"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"saved_lockscreen"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"saved_defbibleselect"];
    }
    
    //저장소로 부터 미리 저장된 데이터 값 확인하기 - user Value
    if (([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_searchlog"] == nil) || ([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_highlight"] == nil))
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"고전 사랑 믿음|창 사랑|권능 구원|부활|마 구원|사 행위" forKey:@"saved_searchlog"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"saved_highlight"];
    }
    
    //저장소로 부터 미리 저장된 데이터 값 확인하기 - 2.01 update check
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_deleteverseline"] == nil)
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"saved_deleteverseline"];
    
    // 설정값을 보고 셀 줄간표시 삭제
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saved_deleteverseline"] == 1)
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // 하이라이트 있으면 파싱하기
    NSString *highlight = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_highlight"];
    highlightRange = [highlight componentsSeparatedByString:@"|"];
    
    //DEBUG 용
    //[[NSUserDefaults standardUserDefaults] setObject:@"|01_01_001|03_02_012|02_11_010|10_01_002|66_02_011" forKey:@"saved_highlight"];
    
    int color = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_color"];
    if(color == 1)
    {
        self.tableView.backgroundColor = [UIColor blackColor];
        self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
        //self.navigationController.navigationBar.translucent = NO;
    }
    else
    {
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        //self.navigationController.navigationBar.translucent = YES;
    }
    
    // 락스크린 해제/설정 확인
    int lockscreen = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_lockscreen"];
    if(lockscreen == 1)
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    else
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    // 최상단 리플래쉬 컨트롤 추가
    refreshControl = [[UIRefreshControl alloc] init];
    NSMutableAttributedString *refreshString = [[NSMutableAttributedString alloc] initWithString:@"이전장을 불러옵니다"];
    [refreshString addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, refreshString.length)];
    refreshControl.attributedTitle = refreshString;
    [refreshControl addTarget:self action:@selector(refreshUp:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    //지정된 책이 없다면 새로 받기
    if ([BookName isEqualToString:@""])
    {
        if(![global_variable checkConnectedToInternet])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"처음 성경을 다운로드 받기 위해서는 인터넷 연결이 필요합니다. 인터넷 연결 후 다시 시도하세요" delegate:nil cancelButtonTitle:@"닫기" otherButtonTitles:nil];
            [alert show];
            //is_firststart = YES;
            return;
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"성경 파일이 없습니다. 한글KJV흠정역을 기본으로 다운로드 받습니다." delegate:nil cancelButtonTitle:@"닫기" otherButtonTitles:nil];
            [alert show];
            [DejalBezelActivityView activityViewForView:self.view withLabel:@"다운로드중입니다..."];
            [NSThread detachNewThreadSelector:@selector(kjvDownloadThread:) toTarget:self withObject:DEFAULT_BIBLE];
            //[self kjvDownloadThread: DEFAULT_BIBLE];
            //is_firststart = NO;
        }
    }
    else
    {
        [self loadContent:BookName bookid:bookid chapterid:chapterid];
        //처음 성경 이동후 맨 위로 이동
        [self.tableView setContentOffset:CGPointMake(0, 0)];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)kjvDownloadThread:(id)arg
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.kjv",arg]];
    NSData *datakjv = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:KJV_DOWNLOAD_URL,arg]]];
    if(datakjv)
    {
        [datakjv writeToFile:finalPath atomically:YES];
        // 파일 백업 금지하기 (icloud위반)
        NSURL *url = [NSURL fileURLWithPath:finalPath];
        [global_variable addSkipBackupAttributeToItemAtURL:url];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"다운로드 url주소가 정확하지 않습니다. 개발자에게 문의바랍니다." delegate:nil cancelButtonTitle:@"닫기" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [DejalBezelActivityView removeViewAnimated:YES];
    //책 이름 설정 (처음 시작이 아니라는 것임을 알림)
    [[NSUserDefaults standardUserDefaults] setObject:arg forKey:@"saved_bookname"];
    BookName = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_bookname"];
    
    //[self saveCurrentid];
    [self loadContent:BookName bookid:bookid chapterid:chapterid];
}

- (void)loadContent:(NSString*)bible_name bookid:(int)book_id chapterid:(int)chapter_id
{
    /*
    NSString *string = [NSString stringWithFormat:@"%02d_%03d",book_id, chapter_id];
    NSRange delRange = [readBible rangeOfString:string];
    if(delRange.location != NSNotFound)
        _NavigationTitle.titleLabel.backgroundColor = [UIColor yellowColor];
    else
        _NavigationTitle.titleLabel.backgroundColor = [UIColor whiteColor];
    */
    //[DejalBezelActivityView activityViewForView:self.view withLabel:@"로딩중입니다..."];
    
    // 스레드 보내기(지금은 낫스레드)
    NSDictionary *extraParams = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:bible_name,[NSString stringWithFormat:@"%d",book_id],[NSString stringWithFormat:@"%d",chapter_id], nil] forKeys:[NSArray arrayWithObjects:@"bibleName",@"bookId",@"chapterId",nil]];
    //[NSThread detachNewThreadSelector:@selector(contentDataCall:) toTarget:self withObject:extraParams];
    [self contentDataCall: extraParams];
}

// TODO: 전체 어플에서 부하가 가장 큰 function
/* Thread for Search Data */
- (void)contentDataCall:(id)arg
{
    NSString *bible_name = [arg objectForKey:@"bibleName"];
    int book_id = [[arg objectForKey:@"bookId"] integerValue];
    int chapter_id = [[arg objectForKey:@"chapterId"] integerValue];
    // 임시저장변수
    NSMutableArray *temp_contents = [[NSMutableArray alloc] init];
    
    // 역본 동시보기 선택시 수행
    if(a_BookName != nil && a_BookName.length > 1)
    {
        // 원래 보기로 한 성경을 먼저 넣는다
        NSArray *temp = [lfbContainer getWithBible:bible_name Book:book_id Chapter:chapter_id];
        //  선택한 역본 이름을 먼저 쪼개서 배열에 넣는다
        NSArray *sep = [a_BookName componentsSeparatedByString:@"|"];
        NSMutableArray *temp_a = [[NSMutableArray alloc] init];
        for(int i=0; i<sep.count; i++)
        {
            // 받아오는건 한번에 받아오는것 밖에 안되기 때문에 어쩔수 없이 한번씩 처리
            NSArray *temp_b = [lfbContainer getWithBible:[sep objectAtIndex:i] Book:book_id Chapter:chapter_id];
            [temp_a addObject:temp_b];
        }
        for (int i=0; i<temp.count; i++)
        {
            // 받아온 데이터를 하나의 배열에 담는다
            [temp_contents addObject:[temp objectAtIndex:i]];
            for(int j=0; j<sep.count; j++)
            {
                NSMutableString *separator = [[NSMutableString alloc] init];
                if(j<5){ // 5개까지만 색을 주자
                    for(int k=0; k<=j; k++)
                        [separator appendString:@"_"];
                }
                [temp_contents addObject:[NSString stringWithFormat:@"%@%@",[[temp_a objectAtIndex:j] objectAtIndex:i],separator]];
            }
        }
    }
    else
    {
        // 한 역본만 볼때 챕터 내용 추가
        temp_contents= [lfbContainer getWithBible:bible_name Book:book_id Chapter:chapter_id];
    }
    
    cellCount += [temp_contents count] + 1;
        
    // 이동하자마자 업데이트 하는것 방지하는 용도
    refreshDownLock = YES;
    // 책이 바뀐 경우 아예 새로 고침
    if(bookid != startBookid)
    {
        startBookid = bookid;
        contents = temp_contents;
        cellCount = [contents count] + 1;
            
        chapterVerseCount = [[NSMutableArray alloc] init];
        NSNumber *XWrapperd = [NSNumber numberWithInt:[contents count]];
        [chapterVerseCount addObject:XWrapperd];
        [contents addObject:@""];
    }
    // 뒤로 가는 경우 (기준은 startChapterid)
    else if (chapterid >= startChapterid)
    {
        // 먼저 값 처리
        lastChapterid = chapterid;
        //[temp addObjectsFromArray:contents];
        //contents = temp_contents;
        [contents addObjectsFromArray:temp_contents];
        NSNumber *XWrapperd = [NSNumber numberWithInt:[contents count]];
        [chapterVerseCount addObject:XWrapperd];
        //[chapterVerseCount insertObject:XWrapperd atIndex:0];
        // 체크박스를 위한 빈공간 삽입
        [contents addObject:@""];
    }
    // 앞으로 가는 경우
    else
    {
        // 먼저 값 처리
        startChapterid--;
        NSNumber *bulk = [NSNumber numberWithInt:-1];
        [chapterVerseCount insertObject:bulk atIndex:0];
            
        for (int i=0; i < [chapterVerseCount count]; i++)
        {
            NSNumber * tmp = [chapterVerseCount objectAtIndex:i];
            tmp = [NSNumber numberWithInt:([tmp integerValue]+[temp_contents count]+1)];
            [chapterVerseCount replaceObjectAtIndex:i withObject:tmp];
            //[chapterVerseCount removeObjectAtIndex:i];
            //[chapterVerseCount insertObject:tmp atIndex:i];
        }
            
        // 체크박스를 위한 빈공간 삽입
        [temp_contents addObject:@""];
        [temp_contents addObjectsFromArray:contents];
        contents = temp_contents;
    }
    [self.tableView reloadData];
    
    // 업데이트된 이름으로 성경이름 바꾸기
    BibleName = [[global_variable getNamedBookofBible] objectAtIndex:(bookid-1)];
    // 상단 이름 업데이트
    NSString *navBibleTitle = [NSString stringWithFormat:@"%@ ▼", BibleName];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:navBibleTitle];
    UIColor *_black = [UIColor blackColor];
    UIFont *font = [UIFont systemFontOfSize:8.0f];
    [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange([BibleName length] + 1, 1)];
    [attString addAttribute:NSForegroundColorAttributeName value:_black range:NSMakeRange(0, [navBibleTitle length])];
    [_navTitleBibleButton setAttributedTitle:attString forState:UIControlStateNormal];
    //현재 보는 책과 챕터수 저장
    bookid = book_id;
    chapterid = chapter_id;
    [self saveCurrentid];
    
    // TODO: 시110장의 경우 걸칠때 잔상남는 버그 있음
    // 최하단 리플래쉬 컨트롤 추가
    //[pullToRefreshManager_ tableViewDelete];
    if(pullToRefreshManager_ == nil)
        pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.tableView withClient:self];
    [pullToRefreshManager_ relocatePullToRefreshView];
    //[DejalBezelActivityView removeViewAnimated:YES];
}
         
- (void)refreshUp:(id)arg
{
    // 맨 위에서 새로고침 했을때, 새로운 장 업데이트 하기
    // !!TODO 나중에: 장 타이틀을 보고 업데이트 하자
    //int chapter_id = [_navTitleChapterButton.titleLabel.text intValue];
    chapterid = startChapterid - 1;
    if(bookid > 1 && chapterid < 1)
    {
        bookid--;
        chapterid = [[[global_variable getNumberofChapterinBook] objectAtIndex:(bookid-1)] intValue];
        startChapterid = chapterid;
        lastChapterid = chapterid;
    }
    else if(bookid <= 1 && chapterid < 1)
    {
        bookid = 66;
        chapterid = [[[global_variable getNumberofChapterinBook] objectAtIndex:(bookid-1)] intValue];
        startChapterid = chapterid;
        lastChapterid = chapterid;
    }
    
    // 테이블 위에다가 새로 추가
    [self loadContent:BookName bookid:bookid chapterid:chapterid];
    // 테이블 마지막에 있는 애 길이 구해서 (-4는 보정값)
    NSIndexPath *ip = [NSIndexPath indexPathForRow:([[chapterVerseCount objectAtIndex:0] intValue] - 4) inSection:0];
    //NSLog(@"%d",ip.row);
    CGRect rect = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:ip] toView:[self.tableView superview]];
    // 마지막으로 이동하기
    [self.tableView setContentOffset:rect.origin];
    [self.tableView reloadData];
    
    [refreshControl endRefreshing];
}
         
- (void)refreshDown:(id)arg
{
    // 맨 아래로 갔을때 새로운 장 업데이트 하기
    int MAXchapter = [[[global_variable getNumberofChapterinBook] objectAtIndex:(bookid-1)] intValue];
    
    chapterid = lastChapterid + 1;
    if(bookid < 66 && chapterid > MAXchapter)
    {
        bookid++;
        chapterid = 1;
        startChapterid = chapterid;
        lastChapterid = chapterid;
        
        // 테이블 갱신
        [self loadContent:BookName bookid:bookid chapterid:chapterid];
        [self.tableView setContentOffset:CGPointMake(0, 0)];
        [self.tableView reloadData];
    }
    else if(bookid >= 66 && chapterid > MAXchapter)
    {
        bookid = 1;
        chapterid = 1;
        startChapterid = chapterid;
        lastChapterid = chapterid;
        
        // 테이블 갱신
        [self loadContent:BookName bookid:bookid chapterid:chapterid];
        [self.tableView setContentOffset:CGPointMake(0, 0)];
        [self.tableView reloadData];
    }
    else
    {
        // 테이블 아래다가 새로 추가
        [self loadContent:BookName bookid:bookid chapterid:chapterid];
    }
}

/**
 * Tells client that refresh has been triggered
 * After reloading is completed must call [MNMBottomPullToRefreshManager tableViewReloadFinished]
 *
 * @param manager PTR manager
 */
- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
    //TODO: 짧은절 (시133) 당겨서 업데이트시 똑같은 성경 그대로 업데이트 되는 것 고치기
    //NSLog(@"%d", chapterid);
    //[NSThread detachNewThreadSelector:@selector(refreshDown:) toTarget:self withObject:[NSNumber numberWithInt:chapterid + 1]];
    [NSThread detachNewThreadSelector:@selector(refreshDown:) toTarget:self withObject:nil];
    //[pullToRefreshManager_ tableViewReloadFinished];
}

/*
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil)
        NSLog(@"long press on table view but not on a row");
    else
        NSLog(@"long press on table view at row %d", indexPath.row);
}
*/

- (void)saveCurrentid
{
    //데이터 저장
    [[NSUserDefaults standardUserDefaults] setInteger:bookid forKey:@"saved_bookid"];
    [[NSUserDefaults standardUserDefaults] setInteger:chapterid forKey:@"saved_chapterid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSearchVerseJump {
    //설정된 verse 길이 만큼 점프
    //[self.tableView setContentOffset:CGPointMake(0, 200)];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:verseJumpid inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [self.tableView reloadData];
    verseJumpid = 0;
}

- (IBAction)navTitleChapterClick:(UIButton *)sender {
    // 선택된 것이 있다면 activity로 이동
    if ([self.tableView indexPathForSelectedRow] != nil)
    {
        // 선택한 결과 정렬하기
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
        selectedRows = [[selectedRows sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]] mutableCopy];
        
        // 인덱스 제거
        for(NSMutableDictionary *dic in selectedRows)
        {
            [dic removeObjectForKey:@"id"];
        }
        
        // 맨 처음에 역본/성경 추가하기
        [selectedRows insertObject:[NSString stringWithFormat:@"[%@] %@",[[global_variable getBibleNameConverter] objectForKey:BookName], [[global_variable getNamedBookofBible] objectAtIndex:(bookid-1)]] atIndex:0];
        
        // activity 실행        
        // 커스텀 액티비티 추가
        kjvActivity *highlightCustomActivity = [[kjvActivity alloc] init];
        kjvKakaoActivity *kakaoCustomActivity = [[kjvKakaoActivity alloc] init];
        NSArray *applicationActivities = [NSArray arrayWithObjects:highlightCustomActivity,kakaoCustomActivity,nil];
        
        //item 추가
        self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:selectedRows applicationActivities:applicationActivities];
        self.activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter,UIActivityTypeAirDrop];
        //ios8 대응 업데이트
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)
            self.activityViewController.popoverPresentationController.sourceView = sender;
        [self presentViewController:self.activityViewController animated:YES completion:^
        { // 완료시 실행이 아니라 액티비티 버튼 누르면 시작되는 거임
            // 선택한 범위 모두 없애고
            for (NSString *string in selectedRows)
            {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:[contents indexOfObject:string] inSection:0];
                [self.tableView deselectRowAtIndexPath:ip animated:NO];
            }
            // 완료되면 오브젝트 삭제하고
            [selectedRows removeAllObjects];
            // 오른쪽 아이콘 이름 변경한다
            //[self updateSelectedRowCountButton];
        }];
        // 완료시 테이블 업데이트
        [self.activityViewController setCompletionHandler:^(NSString *act, BOOL done)
        {
             // 밑줄 업데이트 하고
             // 하이라이트 있으면 파싱하기
             NSString *highlight = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_highlight"];
             highlightRange = [highlight componentsSeparatedByString:@"|"];
             // 오른쪽 아이콘 이름 변경한다
             [self updateSelectedRowCountButton];
        }];
        
    }
    else if(doSearch) // 검색모드때 disable
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"검색모드에서는 다른 성경으로 이동할 수 없습니다" delegate:nil cancelButtonTitle:@"닫기" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self performSegueWithIdentifier:@"chapterSegue" sender:self];
    }
}

- (IBAction)leftNavBarButtonClick:(id)sender {
    // Change button color
    //_sidebarButton.tintColor = [UIColor colorWithWhite:0.96f alpha:0.2f];
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    [self.revealViewController revealToggleAnimated:YES];
    //_sidebarButton.target = self.revealViewController;
    //_sidebarButton.action = @selector(revealToggle:);
}

- (IBAction)navTitleBibleClick:(id)sender {
    if(doSearch) // 검색모드때 disable
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"검색모드에서는 다른 장으로 이동할 수 없습니다" delegate:nil cancelButtonTitle:@"닫기" otherButtonTitles:nil];
        [alert show];

    }
    else
        [self performSegueWithIdentifier:@"bibleSegue" sender:self];
}

+ (void)saveTargetedid:(int)book_id chapterid:(int)chapter_id
{
    //데이터 저장
    [[NSUserDefaults standardUserDefaults] setInteger:book_id forKey:@"saved_bookid"];
    [[NSUserDefaults standardUserDefaults] setInteger:chapter_id forKey:@"saved_chapterid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setdoSearch:(int)book_id chapterid:(int)chapter_id verse:(int)_verse
{
    //저장되어있던 데이터를 다른곳에 저장 (나가면서 복원시켜줄거임)
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"saved_bookid"] forKey:@"saved_searchbookid"];
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"saved_chapterid"] forKey:@"saved_searchchapterid"];
    
    // 여러역본보기 얼마나 선택중인지 확인해서 배수곱하기
    NSArray* na_BookName = [[[NSUserDefaults standardUserDefaults] stringForKey:@"saved_another_bookname"] componentsSeparatedByString:@"|"];
    int BookCount = 1;
    if([na_BookName[0] length] > 1)
        BookCount += na_BookName.count;

    // segue로 이동오면 변할수 있게 데이터 저장
    [self saveTargetedid:book_id chapterid:chapter_id];
    verseJumpid = (_verse * BookCount) + (BookCount * -1);
    //verseHeight = 0.0;
    // 검색중 표시
    doSearch = YES;
}

+ (void)setdoviewDidLoad:(BOOL)toggle
{
    doviewDidLoad = toggle;
    return;
}

#pragma mark - Table view data source
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // TODO: contents에 가장 첫장(startChapterid)/가장 마지막 장을 가지고있는 정보와 알고리즘을 만들것. 해당 정보는 업데이트 앞/뒤와 마지막장 검출에 쓰임
    // 이는 장점프나 성경전환/ 즉 테이블 내용이 초기화될떄 같이 초기화 된다.

    // 각 성경의 마지막 장인 경우 다음 업데이트가 자동으로 되지 않도록 막음
    if([[[global_variable getNumberofChapterinBook] objectAtIndex:bookid-1] isEqualToString:[NSString stringWithFormat:@"%d",lastChapterid]])
    {
        //NSLog(@"%@ %@",[[global_variable getNumberofChapterinBook] objectAtIndex:bookid-1], [NSString stringWithFormat:@"%d",chapterid]);
        //NSLog(@"%d",chapterid);
        refreshDownLock = YES;
    }
    else
        refreshDownLock = NO;
    //NSLog(@"Will begin dragging");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    //[pullToRefreshManager_ tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [pullToRefreshManager_ tableViewReleased];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [pullToRefreshManager_ relocatePullToRefreshView];
}

// 섹션 갯수
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

// 열 갯수
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return cellCount;
}

// 셀 배경 초기화
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 하이라이트 체크한 구절은 노랑, 체크하지 않은 구절은 클리어컬러 주기
    // 먼저 지금 절을 00_00_000 형태로 변환하기 단, chapterid를 사용하지 말고, content내용을 파싱해서 봐야 한다
    NSString *content = [contents objectAtIndex:indexPath.row];
    NSArray *temp_1 = [content componentsSeparatedByString:@" "];
    // 성경이 아닌것을 볼때는 패스
    if(![[temp_1 objectAtIndex:0] isEqual: @""])
    {
        NSArray *temp_2 = [[temp_1 objectAtIndex:0] componentsSeparatedByString:@":"];
        int chapter_id = [[temp_2 objectAtIndex:0] intValue];
        int verse_id = [[temp_2 objectAtIndex:1] intValue];
        NSString *currentPosition = [NSString stringWithFormat:@"%02d_%02d_%03d", bookid, chapter_id, verse_id];
        if(([highlightRange indexOfObject:currentPosition] != NSNotFound))
        {
            cell.textLabel.textColor = [UIColor blackColor];
            [cell setBackgroundColor:[UIColor yellowColor]];
        }
        else
            [cell setBackgroundColor:[UIColor clearColor]];
    }
    else // 성경이 아닌것을 볼때는 패스
        [cell setBackgroundColor:[UIColor clearColor]];
    
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //end of loading
        //for example [activityIndicator stopAnimating];
        // 검색모드일 경우 선택한 절로 점프하기
        if(doSearch && (verseJumpid > 0))
            [self setSearchVerseJump];
    }
}

// TODO: 영어 성경의 경우 높이가 다르게 나온다.. 보정필요
// 열의 높이를 설정
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 마지막 행의 경우 크기를 fix
    if([chapterVerseCount indexOfObject:[NSNumber numberWithInt:indexPath.row]] != NSNotFound)
        return 60.0f;
    else
    {
        // 다중역본선택시 프리픽스 지우기
        NSString *content = [contents objectAtIndex:indexPath.row];
        NSRange range = NSMakeRange(0, content.length);
        if ([content hasSuffix:@"_____"])
            range = NSMakeRange(0, content.length-5);
        else if ([content hasSuffix:@"____"])
            range = NSMakeRange(0, content.length-4);
        else if ([content hasSuffix:@"___"])
            range = NSMakeRange(0, content.length-3);
        else if ([content hasSuffix:@"__"])
            range = NSMakeRange(0, content.length-2);
        else if ([content hasSuffix:@"_"])
            range = NSMakeRange(0, content.length-1);
        content = [content substringWithRange:range];
        
        float lineheight = [[NSUserDefaults standardUserDefaults] floatForKey:@"saved_lineheightsize"];
        //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) // 아이패드면 좀더 크게 그린다
        //    lineheight += IPAD_GAP_PLUS;
        
        // 폰트 사이즈 가지고 온다
        UIFont *cellFont = [global_variable fontForCell:[[NSUserDefaults standardUserDefaults] floatForKey:@"saved_fontsize"]];
        
        // 화면크기 구하기
        CGRect screen = [[UIScreen mainScreen] bounds];
        //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        //GAP_CORDI는 마지막글자 잘리는것 보정하기 위한 값, 경우에따라 계속 변함
        int screen_width = screen.size.width - GAP_CORDI;
        int screen_height = screen.size.height - GAP_CORDI;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            screen_width -= GAP_PAD_CORDI;
            screen_height -= GAP_PAD_CORDI;
        }
        //누워있다면 width/height 바꿔서 계산하기
        //IOS8 대응 업데이트
        if(((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight)) && (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1))
            screen_width = screen_height;

        //화면 넓이를 토대로 폰트길이구하기(290)
        //TODO: 화면 로테이션시 가끔 업데이트가 되지 않고 기존의 길이가 유지될 때가 있음.
        CGSize labelSize = [content sizeWithFont:cellFont constrainedToSize:CGSizeMake(screen_width, 9999) lineBreakMode:NSLineBreakByCharWrapping];
        
        // 검색시 verse까지의 height를 구한다
        //if ((verseJumpid - 1) > indexPath.row)
        //    verseHeight += labelSize.height;
        
        //TODO: HARDCODING
        // 마지막절은 보정해준다
        if([chapterVerseCount indexOfObject:[NSNumber numberWithInt:(indexPath.row + 1)]] != NSNotFound)
        {
            if([[NSUserDefaults standardUserDefaults] floatForKey:@"saved_fontsize"] == SMALL_FONT_SIZE)
                labelSize.height -= 11.9f; // sml
            else if([[NSUserDefaults standardUserDefaults] floatForKey:@"saved_fontsize"] == BIG_FONT_SIZE && lineheight == BIG_FONT_GAP )
                labelSize.height -= 27.9f; // nor
            else
                labelSize.height -= 17.9f; // nor
        }
        
        //NSLog(@"%@", [contents objectAtIndex:indexPath.row]);
        //NSLog(@"%d %f", screen_width, labelSize.height);
    
        return labelSize.height + (lineheight*2);
    }
}

// 열에 표시할 내용 정의
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 이동할때마다 보여지는 셀의 가장 첫번째 장을 따서 장 업데이트 하기
    for(UITableViewCell *cell in [self.tableView visibleCells])
    {
        // 셀에 선택한 부분이 있으면 업데이트 생략
        if([selectedRows count] != 0)
            break;
        // 상단 이름 업데이트
        //NSLog(@"%@", cell.textLabel.text);
        NSArray *chapterStrA = [cell.textLabel.text componentsSeparatedByString:@":"];
        NSString *chapterStr = [chapterStrA objectAtIndex:0];
        if([chapterStr length] > 3) // 중간자일 경우 브래이크로 처리
            break;
        //chapterid = [chapterStr intValue];
        NSString *navBibleChapter = [NSString stringWithFormat:@"%@장 ▼", chapterStr];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:navBibleChapter];
        UIColor *_black = [UIColor blackColor];
        UIFont *font = [UIFont systemFontOfSize:8.0f];
        [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange([chapterStr length] + 2, 1)];
        [attString addAttribute:NSForegroundColorAttributeName value:_black range:NSMakeRange(0, [navBibleChapter length])];
        [_navTitleChapterButton setAttributedTitle:attString forState:UIControlStateNormal];
        break;
    }
    
    // 마지막 앞3으로 다가오면 새로운 장 업데이트 하기 (스레드 런)
    if(!doSearch && !refreshDownLock && (([contents count] - 2) == indexPath.row))
    {
        //NSArray *cellChapter = [[contents objectAtIndex:indexPath.row] componentsSeparatedByString:@":"];
        //NSNumber *nextChapter = [NSNumber numberWithInt:[[cellChapter objectAtIndex:0] intValue] + 1];
        [NSThread detachNewThreadSelector:@selector(refreshDown:) toTarget:self withObject:nil];
    }
    
    // 마지막 절에 표시된 인덱스에 닿으면 장 표시 업데이트 (체크박스 업데이트)
    if([chapterVerseCount indexOfObject:[NSNumber numberWithInt:indexPath.row]] != NSNotFound)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkCell"];
        NSArray *cellChapter = [[contents objectAtIndex:indexPath.row-1] componentsSeparatedByString:@":"];
        NSString *string = [NSString stringWithFormat:@"%02d_%03d", bookid, [[cellChapter objectAtIndex:0] intValue]];
        NSRange delRange = [readBible rangeOfString:string];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@장을 읽음표시 합니다",BibleName, [cellChapter objectAtIndex:0]];
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"saved_color"] == 1) // 색반전일 경우
            cell.textLabel.textColor = [UIColor whiteColor];
        
        if(delRange.location != NSNotFound)  // 체크된것 (del action) format: 09_012|1_013|03_012|01_019
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else  // 체크안된것 (add action)
            cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }
    
    // 테이블에 내용 표시하기
    else
    {
        NSString *content = [contents objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plainCell"];
        //!!TODO:컬러입히기 STATIC 값
        NSRange range = NSMakeRange(0, content.length);
        if ([content hasSuffix:@"_____"])
        {
            cell.textLabel.textColor = [UIColor brownColor];
            range = NSMakeRange(0, content.length-5);
        }
        else if ([content hasSuffix:@"____"])
        {
            cell.textLabel.textColor = [UIColor darkGrayColor];
            range = NSMakeRange(0, content.length-4);
        }
        else if ([content hasSuffix:@"___"])
        {
            cell.textLabel.textColor = [UIColor redColor];
            range = NSMakeRange(0, content.length-3);
        }
        else if ([content hasSuffix:@"__"])
        {
            cell.textLabel.textColor = [UIColor orangeColor];
            range = NSMakeRange(0, content.length-2);
        }
        else if ([content hasSuffix:@"_"])
        {
            cell.textLabel.textColor = [UIColor blueColor];
            range = NSMakeRange(0, content.length-1);
        }
        else
        {
            int color = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_color"];
            if(color == 1) // 색반전일 경우
                cell.textLabel.textColor = [UIColor whiteColor];
            else // 보통일 경우
                cell.textLabel.textColor = [UIColor blackColor];
        }

        content = [content substringWithRange:range];
        cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [global_variable fontForCell:[[NSUserDefaults standardUserDefaults] floatForKey:@"saved_fontsize"]];
        /*
        // 여기서 처리하지 말고 클리어컬러쪽에서 그냥 처리해버리기
        // 하이라이트 체크한 구절이면 배경색 바꾸기 (검색중일땐 표시하지 않음)
        // 먼저 지금 절을 00_00_000 형태로 변환하기 단, chapterid를 사용하지 말고, content내용을 파싱해서 봐야 한다
        NSArray *temp_1 = [content componentsSeparatedByString:@" "];
        NSArray *temp_2 = [[temp_1 objectAtIndex:0] componentsSeparatedByString:@":"];
        int chapter_id = [[temp_2 objectAtIndex:0] intValue];
        int verse_id = [[temp_2 objectAtIndex:1] intValue];
        NSString *currentPosition = [NSString stringWithFormat:@"%02d_%02d_%03d", bookid, chapter_id, verse_id];
        if(!doSearch && ([highlightRange indexOfObject:currentPosition] != NSNotFound))
        {
            cell.backgroundColor = [UIColor yellowColor];
            cell.textLabel.textColor = [UIColor blackColor]; // 무조껀 블랙으로 나타내기
        }
        */
        
        cell.textLabel.text = content;
        
        return cell;
    }
}

// 열을 선택해제한 경우
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //성경읽음 체크 선택한경우
    if([chapterVerseCount indexOfObject:[NSNumber numberWithInt:indexPath.row]] != NSNotFound)
    {
        // 아무일 없음
        return;
    }
    else
    {
        // 선택한 내용을 삭제하기
        NSString *deSelectedRow = [contents objectAtIndex:indexPath.row];
        // key/value 로 bibleid_bookid_chapterid를 구함
        NSArray *tem = [deSelectedRow componentsSeparatedByString:@":"]; // 12:11 ...
        NSArray *tem2 = [[tem objectAtIndex:1] componentsSeparatedByString:@" "]; // 11 하나님 가라사대...
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%02d_%02d_%03d", bookid, [[tem objectAtIndex:0] intValue], [[tem2 objectAtIndex:0] intValue]] forKey:@"id"];
        [dic setObject:deSelectedRow forKey:@"content"];
        [selectedRows removeObject:dic];
        //NSLog(@"%d",[tableView indexPathForSelectedRow].row);
        
        // 오른쪽 아이콘 이름 바꾸기
        [self updateSelectedRowCountButton];
    }
}

// 열을 선택한 경우
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //성경읽음 체크 선택한경우
    if([chapterVerseCount indexOfObject:[NSNumber numberWithInt:indexPath.row]] != NSNotFound)
    {
        NSMutableString *na_readBible = [[NSMutableString alloc] init];
        NSString *sep_bar = @"|";
        
        //읽음 표시 된 바이블 리스트를 쪼개고
        NSArray *a_readBible = [readBible componentsSeparatedByString:sep_bar];
        
        NSArray *cellChapter = [[contents objectAtIndex:indexPath.row-1] componentsSeparatedByString:@":"];
        NSString *string = [NSString stringWithFormat:@"%02d_%03d", bookid, [[cellChapter objectAtIndex:0] intValue]];
        //NSString *string = [NSString stringWithFormat:@"%02d_%03d",bookid,chapterid];
        // 체크된것 (del action 지우기) format: 9_12|1_13|3_12|1_19
        NSRange delRange = [readBible rangeOfString:string];
        if(delRange.location != NSNotFound)
        {
            for(int i=0; i<a_readBible.count; i++)
            {
                if([[a_readBible objectAtIndex:i] isEqualToString:string])
                    continue;
                [na_readBible appendString:[a_readBible objectAtIndex:i]];
                [na_readBible appendString:sep_bar];
            }
            if([na_readBible hasSuffix:sep_bar])
                na_readBible = [[na_readBible substringWithRange:NSMakeRange(0, na_readBible.length-1)] mutableCopy];
        }
        
        // 체크안된것 (add action 추가하기)
        else
        {
            na_readBible = [[readBible stringByAppendingString:[sep_bar stringByAppendingString:string]] mutableCopy];
            if([na_readBible hasPrefix:sep_bar]) // prefix가 남아있다면 삭제
                na_readBible = [[na_readBible substringWithRange:NSMakeRange(1, na_readBible.length-1)] mutableCopy];
        }
        
        // 셋팅값에 저장한다
        [[NSUserDefaults standardUserDefaults] setObject:na_readBible forKey:@"saved_readbible"];
        readBible = na_readBible;
        /*
        NSRange Range = [[[NSUserDefaults standardUserDefaults] stringForKey:@"saved_readbible"] rangeOfString:string];
        if(Range.location != NSNotFound)
            _NavigationTitle.titleLabel.backgroundColor = [UIColor yellowColor];
        else
            _NavigationTitle.titleLabel.backgroundColor = [UIColor whiteColor];
        */
        [self.tableView reloadData];
    }
    else
    {
        // 일반 성경 내용을 선택한 경우 해당 내용을 배열에 넣기
        NSString *selectedRow = [contents objectAtIndex:indexPath.row];
        // key/value 로 bibleid_bookid_chapterid를 구함
        NSArray *tem = [selectedRow componentsSeparatedByString:@":"]; // 12:11 ...
        NSArray *tem2 = [[tem objectAtIndex:1] componentsSeparatedByString:@" "]; // 11 하나님 가라사대...
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%02d_%02d_%03d", bookid, [[tem objectAtIndex:0] intValue], [[tem2 objectAtIndex:0] intValue]] forKey:@"id"];
        [dic setObject:selectedRow forKey:@"content"];
        [selectedRows addObject:dic];
        
        // 오른쪽 아이콘 이름 바꾸기
        [self updateSelectedRowCountButton];
        //NSLog(@"%@",selectedRows);
    }
    
    return;
}

- (void)updateSelectedRowCountButton
{

    if([selectedRows count] == 0)
    {
        // 선택된것이 아무것도 없으면 상단 장 표시 정상화 - 새로고침
        [self.tableView reloadData];
    }
    else
    {
        // 오른쪽 아이콘 이름 바꾸기
        NSString *str = [NSString stringWithFormat:@"%d개 선택됨", [selectedRows count]];
        NSString *navBibleChapter = [NSString stringWithFormat:@"%@ ▼", str];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:navBibleChapter];
        UIColor *_black = [UIColor blackColor];
        UIFont *_font = [UIFont systemFontOfSize:13.0f];
        UIFont *font = [UIFont systemFontOfSize:8.0f];
        [attString addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, [str length])];
        [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange([str length] + 1, 1)];
        [attString addAttribute:NSForegroundColorAttributeName value:_black range:NSMakeRange(0, [navBibleChapter length])];
        [_navTitleChapterButton setAttributedTitle:attString forState:UIControlStateNormal];
    }
}

/*

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //[_objects removeObjectAtIndex:indexPath.row];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

*/

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
*/
/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


// 길게 선택시 메뉴 보임
/*
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    return (action == @selector(copy:));
}

- (BOOL)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if(action == @selector(copy:))
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [contents objectAtIndex:indexPath.row];
    }
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"chapterSegue"]) {
        //lfaChapterSelectionViewController *vc = [segue destinationViewController];
        [[segue destinationViewController] setNumberofChapter:bookid-1];
    }
}

@end
