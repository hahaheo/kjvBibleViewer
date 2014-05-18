//
//  kjvBibleViewController.m
//  kjvBibleViewer
//
//  Created by chan on 14. 5. 13..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import "global_variable.h"
#import "lfbContainer.h"
#import "kjvBibleViewController.h"
#import "kjvChapterSelectController.h"
#import "kjvBibleSelectController.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    //_navTitleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    //[_NavTitleButton addTarget:self action:@selector(bibleSelectorClick:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    
    //필요 변수 초기화
    contents = [[NSMutableArray alloc] init];
    chapterVerseCount = [[NSMutableArray alloc] init];
    cellCount = 0;
    
    //저장소로 부터 미리 저장된 데이터 값 불러오기 - local Value
    if (([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_bookid"] == nil) || ([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_chapterid"] == nil))
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"saved_bookid"];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"saved_chapterid"];
    }
    bookid = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_bookid"];
    chapterid = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_chapterid"];
    startBookid = bookid;
    startChapterid = chapterid;
    
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
    
    //저장소로 부터 미리 저장된 데이터 값 확인하기 - setting Value
    if (([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_fontsize"] == nil) || ([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_lineheightsize"] == nil) || ([[NSUserDefaults standardUserDefaults] objectForKey:@"saved_color"] == nil))
    {
        [[NSUserDefaults standardUserDefaults] setFloat:DEF_FONT_SIZE forKey:@"saved_fontsize"];
        [[NSUserDefaults standardUserDefaults] setFloat:DEF_FONT_GAP forKey:@"saved_lineheightsize"];
        [[NSUserDefaults standardUserDefaults] setInteger:COLOR_REVERSED forKey:@"saved_color"];
    }
    
    // 폰트/배경색 역전 확인
    int color = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_color"];
    if(color == 1)
        self.tableView.backgroundColor = [UIColor blackColor];
    else
        self.tableView.backgroundColor = [UIColor whiteColor];
    
    // 최상단 리플래쉬 컨트롤 추가
    refreshControl = [[UIRefreshControl alloc] init];
    NSMutableAttributedString *refreshString = [[NSMutableAttributedString alloc] initWithString:@"이전장을 불러옵니다"];
    [refreshString addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, refreshString.length)];
    refreshControl.attributedTitle = refreshString;
    [refreshControl addTarget:self action:@selector(refreshUp:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // 최하단 리플래쉬 컨트롤 추가
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.tableView withClient:self];
    
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
            //[DejalBezelActivityView activityViewForView:self.view withLabel:@"다운로드중입니다..."];
            //[NSThread detachNewThreadSelector:@selector(lfaDefaultDownloadThread:) toTarget:self withObject:DEFAULT_BIBLE];
            [self kjvDownloadThread: DEFAULT_BIBLE];
            //is_firststart = NO;
        }
    }
    
    [self loadContent:BookName bookid:bookid chapterid:chapterid];
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
        [datakjv writeToFile:finalPath atomically:YES];
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"다운로드 url주소가 정확하지 않습니다. 개발자에게 문의바랍니다." delegate:nil cancelButtonTitle:@"닫기" otherButtonTitles:nil];
        [alert show];
        return;
    }
    //[DejalBezelActivityView removeViewAnimated:YES];
    //책 이름 설정 (처음 시작이 아니라는 것임을 알림)
    [[NSUserDefaults standardUserDefaults] setObject:arg forKey:@"saved_bookname"];
    BookName = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_bookname"];
    
    //[self saveCurrentid];
    //[self loadContent:BookName bookid:bookid chapterid:chapterid];
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
    
    // 상단 이름 업데이트
    NSString *bibleName = [[global_variable getNamedBookofBible] objectAtIndex:(book_id-1)];
    NSString *navBibleTitle = [NSString stringWithFormat:@"%@ ▼", bibleName];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:navBibleTitle];
    UIColor *_black = [UIColor blackColor];
    UIFont *font = [UIFont fontWithName:@"Apple SD 산돌고딕 Neo" size:8.0f];
    [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange([bibleName length] + 1, 1)];
    [attString addAttribute:NSForegroundColorAttributeName value:_black range:NSMakeRange(0, [navBibleTitle length])];
    [_navTitleBibleButton setAttributedTitle:attString forState:UIControlStateNormal];
    
    // 스레드 보내기(지금은 낫스레드)
    NSDictionary *extraParams = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:bible_name,[NSString stringWithFormat:@"%d",book_id],[NSString stringWithFormat:@"%d",chapter_id], nil] forKeys:[NSArray arrayWithObjects:@"bibleName",@"bookId",@"chapterId",nil]];
    //[NSThread detachNewThreadSelector:@selector(contentDataCall:) toTarget:self withObject:extraParams];
    [self contentDataCall: extraParams];
}

/* Thread for Search Data */
- (void)contentDataCall:(id)arg
{
    NSString *bible_name = [arg objectForKey:@"bibleName"];
    int book_id = [[arg objectForKey:@"bookId"] integerValue];
    int chapter_id = [[arg objectForKey:@"chapterId"] integerValue];
    
    // 역본 동시보기 선택시 수행
    // TODO: 새로운 업데이트 형식에 맞게 수정할 것
    if([a_BookName isEqualToString:@""] && a_BookName.length > 1)
    {
        NSArray *temp = [lfbContainer getWithBible:bible_name Book:book_id Chapter:chapter_id];
        NSArray *sep = [a_BookName componentsSeparatedByString:@"|"];
        NSMutableArray *temp_a = [[NSMutableArray alloc] init];
        for(int i=0; i<sep.count; i++)
        {
            NSArray *temp_b = [lfbContainer getWithBible:[sep objectAtIndex:i] Book:book_id Chapter:chapter_id];
            [temp_a addObject:temp_b];
        }
        for (int i=0; i<temp.count; i++)
        {
            [contents addObject:[NSString stringWithFormat:@"%@",[temp objectAtIndex:i]]];
            for(int j=0; j<sep.count; j++)
            {
                NSMutableString *separator = [[NSMutableString alloc] init];
                if(j<5){ // 5개까지만 색을 주자
                    for(int k=0; k<=j; k++)
                        [separator appendString:@"_"];
                }
                [contents addObject:[NSString stringWithFormat:@"%@%@",[[temp_a objectAtIndex:j] objectAtIndex:i],separator]];
            }
        }
    }
    else
    {
        // 새로운 챕터 내용 추가
        NSMutableArray *temp = [lfbContainer getWithBible:bible_name Book:book_id Chapter:chapter_id];
        cellCount += [temp count] + 1;
        
        // 이동하자마자 업데이트 하는것 방지하는 용도
        refreshDownLock = YES;
        // 책이 바뀐 경우 아예 새로 고침
        if(bookid != startBookid)
        {
            startBookid = bookid;
            contents = temp;
            cellCount = [contents count] + 1;
            
            chapterVerseCount = [[NSMutableArray alloc] init];
            NSNumber *XWrapperd = [NSNumber numberWithInt:[contents count]];
            [chapterVerseCount addObject:XWrapperd];
            [contents addObject:@""];
        }
        // 뒤로 가는 경우
        else if (chapterid >= startChapterid)
        {
            //[temp addObjectsFromArray:contents];
            //contents = temp;
            [contents addObjectsFromArray:temp];
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
            NSNumber *bulk = [NSNumber numberWithInt:0];
            [chapterVerseCount insertObject:bulk atIndex:0];
            
            for (int i=0; i < [chapterVerseCount count]; i++)
            {
                NSNumber * tmp = [chapterVerseCount objectAtIndex:i];
                tmp = [NSNumber numberWithInt:([tmp integerValue]+[temp count])];
                [chapterVerseCount removeObjectAtIndex:i];
                [chapterVerseCount insertObject:tmp atIndex:i];
            }
            
            // 체크박스를 위한 빈공간 삽입
            [temp addObject:@""];
            [temp addObjectsFromArray:contents];
            contents = temp;
        }
    }
    [self.tableView reloadData];
    
    //현재 보는 책과 챕터수 저장
    bookid = book_id;
    chapterid = chapter_id;
    [self saveCurrentid];
    
    //[DejalBezelActivityView removeViewAnimated:YES];
}
         
- (void)refreshUp:(id)arg
{
    // 맨 위에서 새로고침 했을때, 새로운 장 업데이트 하기
    chapterid = startChapterid - 1;
    //chapterid--;
    if(bookid > 1 && chapterid < 1)
    {
        bookid--;
        chapterid = [[[global_variable getNumberofChapterinBook] objectAtIndex:(bookid-1)] intValue];
        startChapterid = chapterid;
    }
    else if(bookid <= 1 && chapterid < 1)
    {
        bookid = 66;
        chapterid = [[[global_variable getNumberofChapterinBook] objectAtIndex:(bookid-1)] intValue];
        startChapterid = chapterid;
    }
    
    // 테이블 아래다가 새로 추가
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
    chapterid++;
    int MAXchapter = [[[global_variable getNumberofChapterinBook] objectAtIndex:(bookid-1)] intValue];
    if(bookid < 66 && chapterid > MAXchapter)
    {
        bookid++;
        chapterid = 1;
        startChapterid = chapterid;
        
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
    //NSLog(@"haha");
    [NSThread detachNewThreadSelector:@selector(refreshDown:) toTarget:self withObject:nil];
    //[pullToRefreshManager_ tableViewReloadFinished];
}

- (void)saveCurrentid
{
    //데이터 저장
    [[NSUserDefaults standardUserDefaults] setInteger:bookid forKey:@"saved_bookid"];
    [[NSUserDefaults standardUserDefaults] setInteger:chapterid forKey:@"saved_chapterid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)SelectChapter:(UIButton *)sender {
    [self performSegueWithIdentifier:@"chapterSegue" sender:sender];
}

- (void)saveTargetedid:(int)book_id chapterid:(int)chapter_id
{
    //데이터 저장
    [[NSUserDefaults standardUserDefaults] setInteger:book_id forKey:@"saved_bookid"];
    [[NSUserDefaults standardUserDefaults] setInteger:chapter_id forKey:@"saved_chapterid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIFont *)fontForCell:(CGFloat) size
{
    return [UIFont systemFontOfSize:size];
}

#pragma mark - Table view data source
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 각 성경의 마지막 장인 경우 다음 업데이트가 자동으로 되지 않도록 막음
    if(![[[global_variable getNumberofChapterinBook] objectAtIndex:bookid-1] isEqualToString:[NSString stringWithFormat:@"%d",chapterid]])
    {
        //NSLog(@"%@ %@",[[global_variable getNumberofChapterinBook] objectAtIndex:bookid-1], [NSString stringWithFormat:@"%d",chapterid]);
        //NSLog(@"%d",chapterid);
        refreshDownLock = NO;
    }
    //NSLog(@"Will begin dragging");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"Did Scroll");
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
        
        // 폰트 사이즈 가지고 온다
        UIFont *cellFont = [self fontForCell:[[NSUserDefaults standardUserDefaults] floatForKey:@"saved_fontsize"]];
        CGSize labelSize = [content sizeWithFont:cellFont constrainedToSize:CGSizeMake(295,999) lineBreakMode:NSLineBreakByCharWrapping];
        
        // 마지막절은 17.9 만큼 빼준다
        if([chapterVerseCount indexOfObject:[NSNumber numberWithInt:(indexPath.row + 1)]] != NSNotFound)
            labelSize.height -= 17.9f;
        
        //NSLog(@"%f", labelSize.height);
    
        return labelSize.height + (lineheight*2);
    }
}

// 열에 표시할 내용 정의
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 이동할때마다 보여지는 셀의 가장 첫번째 장을 따서 장 업데이트 하기
    for(UITableViewCell *cell in [self.tableView visibleCells])
    {
        // 상단 이름 업데이트
        //NSLog(@"%@", cell.textLabel.text);
        NSArray *chapterStrA = [cell.textLabel.text componentsSeparatedByString:@":"];
        NSString *chapterStr = [chapterStrA objectAtIndex:0];
        if([chapterStr length] > 3) // 중간자일 경우 브래이크로 처리
            break;
        NSString *navBibleChapter = [NSString stringWithFormat:@"%@장 ▼", chapterStr];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:navBibleChapter];
        UIColor *_black = [UIColor blackColor];
        UIFont *font = [UIFont fontWithName:@"Apple SD 산돌고딕 Neo" size:8.0f];
        [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange([chapterStr length] + 2, 1)];
        [attString addAttribute:NSForegroundColorAttributeName value:_black range:NSMakeRange(0, [navBibleChapter length])];
        [_navTitleChapterButton setAttributedTitle:attString forState:UIControlStateNormal];
        
        break;
        
    }
    // 마지막 앞3으로 다가오면 새로운 장 업데이트 하기 (스레드 런)
    if(!refreshDownLock && (([contents count] - 3) == indexPath.row))
        [NSThread detachNewThreadSelector:@selector(refreshDown:) toTarget:self withObject:nil];
    
    // 마지막 절에 표시된 인덱스에 닿으면 실행 (체크박스 업데이트)
    if([chapterVerseCount indexOfObject:[NSNumber numberWithInt:indexPath.row]] != NSNotFound)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkCell"];
        
        NSString *string = [NSString stringWithFormat:@"%02d_%03d",bookid,chapterid];
        NSRange delRange = [readBible rangeOfString:string];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %d장을 읽음표시 합니다",[[global_variable getNamedBookofBible] objectAtIndex:(bookid-1)], chapterid];
        if(delRange.location != NSNotFound)  // 체크된것 (del action) format: 09_012|1_013|03_012|01_019
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else  // 체크안된것 (add action)
            cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }
    
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
        cell.textLabel.font = [self fontForCell:[[NSUserDefaults standardUserDefaults] floatForKey:@"saved_fontsize"]];
        cell.textLabel.text = content;
        
        return cell;
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
        int a_readBibleCount = a_readBible.count;
        if([[a_readBible objectAtIndex:0] isEqualToString:@""])
            a_readBibleCount = 0; //없으면 표시된게 없다고 체크
        
        // 체크된것 (del action) format: 9_12|1_13|3_12|1_19
        NSString *string = [NSString stringWithFormat:@"%02d_%03d",bookid,chapterid];
        NSRange delRange = [readBible rangeOfString:string];
        if(delRange.location != NSNotFound)
        {
            for(int i=0; i<a_readBibleCount; i++)
            {
                if([[a_readBible objectAtIndex:i] isEqualToString:string])
                    continue;
                [na_readBible appendString:[a_readBible objectAtIndex:i]];
                [na_readBible appendString:sep_bar];
            }
            if([na_readBible hasSuffix:sep_bar])
                na_readBible = [[na_readBible substringWithRange:NSMakeRange(0, na_readBible.length-1)] mutableCopy];
        }
        
        // 체크안된것 (add action)
        else
        {
            na_readBible = [[readBible stringByAppendingString:[sep_bar stringByAppendingString:string]] mutableCopy];
            if([na_readBible hasPrefix:sep_bar]) // prefix가 남아있다면 삭제
                na_readBible = [[na_readBible substringWithRange:NSMakeRange(1, na_readBible.length-1)] mutableCopy];
        }
        
        // 셋팅값에 저장한다
        [[NSUserDefaults standardUserDefaults] setObject:na_readBible forKey:@"saved_readbible"];
        //NSRange Range = [[[NSUserDefaults standardUserDefaults] stringForKey:@"saved_readbible"] rangeOfString:string];
        //if(Range.location != NSNotFound)
        //    _NavigationTitle.titleLabel.backgroundColor = [UIColor yellowColor];
        //else
         //   _NavigationTitle.titleLabel.backgroundColor = [UIColor whiteColor];
        
        [self.tableView reloadData];
    }
    
    return;
}

/*
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (BOOL)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if(action == @selector(copy:))
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [self.contents objectAtIndex:indexPath.row];
    }
    return YES;
}
*/

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"chapterSegue"]) {
        //lfaChapterSelectionViewController *vc = [segue destinationViewController];
        [[segue destinationViewController] setNumberofChapter:bookid];
    }
}


@end
