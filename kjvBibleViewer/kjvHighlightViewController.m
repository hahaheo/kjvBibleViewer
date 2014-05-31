//
//  kjvHighlightViewController.m
//  kjvBibleViewer
//
//  Created by chan on 14. 5. 14..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import "global_variable.h"
#import "lfbContainer.h"
#import "SWRevealViewController.h"
#import "kjvBibleViewController.h"
#import "kjvHighlightViewController.h"

@interface kjvHighlightViewController ()

@end

@implementation kjvHighlightViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // 폰트랑 배경은 항상 디폴트
    font = [global_variable fontForCell:DEF_FONT_SIZE];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    NSString *BookName = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_bookname"];
    // 첫 실행시 검색 기록이 있다면 불러와서 띄우기
    NSString *highlightLog = [[NSUserDefaults standardUserDefaults] objectForKey:@"saved_highlight"];
    if(highlightLog.length > 1)
    {
        contents = [[NSMutableArray alloc] init]; // init.
        //읽은 기록을 쪼갠다
        NSString *sep_bar = @"|";
        NSArray *a_highlightLog = [highlightLog componentsSeparatedByString:sep_bar];
        
        //쪼갠 다음에 내용을 불러온다 bookid/chapterid/verseid 00_00_000 (맨앞에있는것은 제외)
        for(int i=1; i<a_highlightLog.count; i++)
        {
            NSArray *bibleIndex = [[a_highlightLog objectAtIndex:i] componentsSeparatedByString:@"_"];
            // 인덱스 데이터를 통해 해당 절을 가져오고 그것을 contents에 추가한다
            [contents addObject:[lfbContainer getWithBibleVerse:BookName Book:[[bibleIndex objectAtIndex:0] intValue] Chapter:[[bibleIndex objectAtIndex:1] intValue] Verse:[[bibleIndex objectAtIndex:2] intValue]]];
        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)leftNavBarButtonClick:(id)sender {
    [self.revealViewController revealToggleAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [contents count];
}

// 행을 선택한 경우
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 클릭한 구절 파싱
    NSString *result = [contents objectAtIndex:indexPath.row];
    //읽은 기록을 쪼갠다
    NSArray *a_result = [result componentsSeparatedByString:@" "];
    // 첫번째는 성경
    NSString *shortBible = [a_result objectAtIndex:0];
    int indexShortBible = [[shortBible substringToIndex:2] intValue];
    // 두번째에서 또 쪼갬
    NSString *temp = [a_result objectAtIndex:1];
    NSArray *aa_result = [temp componentsSeparatedByString:@":"];
    //  첫번째는 장, 두번째는 절
    NSString *chapter = [aa_result objectAtIndex:0];
    NSString *verse = [aa_result objectAtIndex:1];
        
    // 본문으로 이동하면서 tableview 셋팅하기
    [kjvBibleViewController setdoSearch:indexShortBible chapterid:[chapter integerValue] verse:[verse integerValue]];
    [self performSegueWithIdentifier:@"highlightFindSegue" sender:self];
}

// 셀 배경 초기화
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

// 행 높이 설정
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isLast = NO;
    NSString *cellText = [contents objectAtIndex:indexPath.row];
    // 마지막 절 _ 지우기
    if ([cellText hasPrefix:@"_"])
    {
        isLast = YES;
        cellText = [cellText substringFromIndex:1];
    }
    
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
    
    //TODO: HARDCODING
    // 마지막절은 보정해준다
    if(isLast)
    {
        if([[NSUserDefaults standardUserDefaults] floatForKey:@"saved_fontsize"] == SMALL_FONT_SIZE)
            labelSize.height -= 11.9f; // sml
        else if([[NSUserDefaults standardUserDefaults] floatForKey:@"saved_fontsize"] == BIG_FONT_SIZE && lineheight == BIG_FONT_GAP )
            labelSize.height -= 27.9f; // nor
        else
            labelSize.height -= 17.9f; // nor
    }
    
    return labelSize.height + (lineheight*2);
}

// 행 보여줄 내용 설정
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *content = [contents objectAtIndex:indexPath.row];
    // 마지막 절 _ 지우기
    if ([content hasPrefix:@"_"])
        content = [content substringFromIndex:3];
    else
        content = [content substringFromIndex:2];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plainCell"];
    
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = font;
    cell.textLabel.text = content;
    cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
