//
//  kjvSearchViewController.m
//  kjvBibleViewer
//
//  Created by chan on 14. 5. 14..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import "global_variable.h"
#import "SWRevealViewController.h"
#import "lfbContainer.h"
#import "lfbSearchContainer.h"
#import "DejalActivityView.h"
#import "kjvBibleViewController.h"
#import "kjvSearchViewController.h"

@interface kjvSearchViewController ()

@end

@implementation kjvSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    // 네비 타이틀 항상 흰색
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    // 폰트랑 배경은 항상 디폴트
    font = [global_variable fontForCell:DEF_FONT_SIZE];
    _TableView.backgroundColor = [UIColor whiteColor];
    
    // 인터넷 연결되어있나 확인
    if(![global_variable checkConnectedToInternet])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"지정된 성경이 없으므로 검색을 사용할수 없습니다" delegate:nil cancelButtonTitle:@"닫기" otherButtonTitles:nil];
        [alert show];
        is_internet_connectable = NO;
        return;
    }
    else
        is_internet_connectable = YES;
    
    // 첫 실행시 검색 기록이 있다면 불러와서 띄우기
    is_not_input_Search = YES;
    NSString *searchlog = [[NSUserDefaults standardUserDefaults] objectForKey:@"saved_searchlog"];
    if(searchlog.length > 1)
    {
        contents = [[NSMutableArray alloc] init]; // init.
        //읽은 기록을 쪼갠다
        NSString *sep_bar = @"|";
        NSArray *a_searchlog = [searchlog componentsSeparatedByString:sep_bar];
        //역순으로 넣기
        for(int i=a_searchlog.count - 1; i>=0; i--)
            [contents addObject:[a_searchlog objectAtIndex:i]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 써치바 관련 트리거
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    searchBar.text = nil;
    _TableView.allowsSelection = NO;
    _TableView.scrollEnabled = NO;
    
    // 최하단 리플래쉬 컨트롤 추가
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.TableView withClient:self];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    _TableView.allowsSelection = YES;
    _TableView.scrollEnabled = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    if(!is_internet_connectable)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"지정된 성경이 없으므로 검색을 사용할수 없습니다" delegate:nil cancelButtonTitle:@"닫기" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if(_SearchBar.text.length < 2)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"검색어는 2자 이상 작성해야 합니다" message:@"" delegate:nil cancelButtonTitle:@"닫기" otherButtonTitles:nil];
        [alert show];
        return;
    }
    // 검색 기록에 추가
    NSString *searchlog = [[NSUserDefaults standardUserDefaults] objectForKey:@"saved_searchlog"];
    NSMutableString *na_searchlog = [[NSMutableString alloc] init];
    NSString *sep_bar = @"|";
    
    na_searchlog = [[searchlog stringByAppendingString:[sep_bar stringByAppendingString:_SearchBar.text]] mutableCopy];
    if([na_searchlog hasPrefix:sep_bar]) // prefix가 남아있다면 삭제
        na_searchlog = [[na_searchlog substringWithRange:NSMakeRange(1, na_searchlog.length-1)] mutableCopy];
    
    [[NSUserDefaults standardUserDefaults] setObject:na_searchlog forKey:@"saved_searchlog"];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"입력된 단어가 많을수록 교차검색으로 인해 \n많은시간이 소요됩니다"];
    [_SearchBar resignFirstResponder];
    contents = [[NSMutableArray alloc] init]; // init.
    SEARCH_SPACE_LEVEL = 0;
    is_not_input_Search = NO;
    
    [NSThread detachNewThreadSelector:@selector(searchDataCall:) toTarget:self withObject:nil];
}

/* Thread for Search Data */
-(void) searchDataCall: (id)arg
{
    // 검색어 파싱
    NSString *searchText = _SearchBar.text;
    // 현재 보고있는 역본 파싱
    NSString *BookName = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_bookname"];
    // 검색 수행
    NSArray *temp = [[lfbSearchContainer alloc] getSearchResult:BookName Search:searchText Next:SEARCH_SPACE_LEVEL];
    // 만약에 검색결과가 1개 미만이면 서치스페이스 자동으로 늘려서 검색한다
    while (temp.count < 1)
    {
        SEARCH_SPACE_LEVEL++;
        temp = [[lfbSearchContainer alloc] getSearchResult:BookName Search:searchText Next:SEARCH_SPACE_LEVEL];
        if(SEARCH_SPACE_LEVEL >= (NUMBER_OF_CHAPTER / SIZE_OF_SEARCHSPACE))
            break;
    }
    
    // 결과에 검색한것 추가
    for(int i=0; i<temp.count; i++)
        [contents addObject:[temp objectAtIndex:i]];
    
    // 검색 후 각종 설정
    [_SearchBar setShowsCancelButton:NO animated:YES];
    //[_SearchBar resignFirstResponder];
    _TableView.allowsSelection = YES;
    _TableView.scrollEnabled = YES;
    [_TableView reloadData];
    
    [pullToRefreshManager_ relocatePullToRefreshView];
    
    [DejalBezelActivityView removeViewAnimated:YES];
    // 검색범위를 넘으면 리플래시 출력 중단
    if(SEARCH_SPACE_LEVEL >= (NUMBER_OF_CHAPTER / SIZE_OF_SEARCHSPACE))
        [pullToRefreshManager_ setPullToRefreshViewVisible:NO];

    return;
}

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
    SEARCH_SPACE_LEVEL++;
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"더 많은 성경을 검색중입니다\n검색에 많은 시간이 소요될수 있습니다"];
    [NSThread detachNewThreadSelector:@selector(searchDataCall:) toTarget:self withObject:@"nojump"];

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 검색범위 안에 있을때만 리플래쉬
    if(!is_not_input_Search)
    {
        if(SEARCH_SPACE_LEVEL < (NUMBER_OF_CHAPTER / SIZE_OF_SEARCHSPACE))
            [pullToRefreshManager_ tableViewReleased];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if(!is_not_input_Search)
       [pullToRefreshManager_ relocatePullToRefreshView];
}


// 행의 수 리턴
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [contents count];
}

// 행을 선택한 경우
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 성경검색 로그를 선택한 경우
    if (is_not_input_Search)
    {
        [_SearchBar becomeFirstResponder];
        _SearchBar.text = [contents objectAtIndex:indexPath.row];
    }
    // 검색구절을 선택한 경우
    else
    {
        // 클릭한 구절 파싱
        NSString *result = [contents objectAtIndex:indexPath.row];
        //읽은 기록을 쪼갠다
        NSArray *a_result = [result componentsSeparatedByString:@" "];
        // 첫번째는 성경
        NSString *shortBible = [a_result objectAtIndex:0];
        int indexShortBible = [[global_variable getShortedBookofBible] indexOfObject:shortBible] + 1;
        if(indexShortBible > 66) // 못찾으면 영어성경과 대조
        {
            indexShortBible = [[global_variable getShortedEngBookofBible] indexOfObject:shortBible] + 1;
        }
        // 두번째에서 또 쪼갬
        NSString *temp = [a_result objectAtIndex:1];
        NSArray *aa_result = [temp componentsSeparatedByString:@":"];
        //  첫번째는 장, 두번째는 절
        NSString *chapter = [aa_result objectAtIndex:0];
        NSString *verse = [aa_result objectAtIndex:1];
        
        // 본문으로 이동하면서 tableview 셋팅하기
        [kjvBibleViewController setdoSearch:indexShortBible chapterid:[chapter integerValue] verse:[verse integerValue]];
        [self performSegueWithIdentifier:@"searchFindSegue" sender:self];
    }
    //[_SearchBar resignFirstResponder];
}

// 셀 배경 초기화
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

// 행 높이 설정
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [contents objectAtIndex:indexPath.row];
    float lineheight = DEF_FONT_GAP;
    //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) // 아이패드면 좀더 크게 그린다
    //    lineheight += IPAD_GAP_PLUS;
    
    // 폰트사이즈 가지고 온다
    //CGSize labelSize = [cellText sizeWithFont:font constrainedToSize:CGSizeMake(295,999) lineBreakMode:NSLineBreakByCharWrapping];
    
    // 화면크기 구하기
    CGRect screen = [[UIScreen mainScreen] bounds];
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    int screen_width = screen.size.width - GAP_CORDI;
    int screen_height = screen.size.height - GAP_CORDI;
    //누워있다면 width/height 바꿔서 계산하기
    if((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight))
        screen_width = screen_height;
    //화면 넓이를 토대로 폰트길이구하기(290)
    CGSize labelSize = [cellText sizeWithFont:font constrainedToSize:CGSizeMake(screen_width, 9999) lineBreakMode:NSLineBreakByCharWrapping];

    
    // 마지막절은 17.9 만큼 빼준다
    //if([chapterVerseCount indexOfObject:[NSNumber numberWithInt:(indexPath.row + 1)]] != NSNotFound)
    //    labelSize.height -= 17.9f;
    
    return labelSize.height + (lineheight*2);
}

// 행 보여줄 내용 설정
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *content = [contents objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plainCell"];
    
    // 검색한 단어에만 하이라이트 주기
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:content];
    NSArray *searchWord = [_SearchBar.text componentsSeparatedByString:@" "];
    [attrString beginEditing];
    for(int i=0; i<searchWord.count; i++) // 단어 수 만큼 루프
    {
        NSRange nextString; nextString.location = 0;
        // 전체에서 한번 찾는다 (뒤에서부터 찾기)
        NSRange findString = [content rangeOfString:[searchWord objectAtIndex:i] options:NSBackwardsSearch];
        while (!(findString.location == NSNotFound)) // 못찾을때까지 루프 돌림
        {
            // 찾은 부분을 색칠 한다
            //!!TODO 배경 바꿔주는건 원인모를 오류가 나서 글씨 바꿔주는 것으로 변경
            [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:findString];
            //[attrString addAttribute: NSForegroundColorAttributeName value:[UIColor greenColor] range:findString];
            // 그다음 부분을 찾는다
            nextString.length = findString.location;
            findString = [content rangeOfString:[searchWord objectAtIndex:i] options:NSBackwardsSearch range:nextString];
        }

    }
    [attrString endEditing];
   
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = font;
    cell.textLabel.attributedText = attrString;
    //cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

- (IBAction)leftNavBarButtonClick:(id)sender {
    [self.revealViewController revealToggleAnimated:YES];
}
@end
