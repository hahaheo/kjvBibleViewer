//
//  kjvQuickBibleSelectController.m
//  kjvBibleViewer
//
//  Created by Hyunji Cho on 2014. 5. 18..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import "global_variable.h"
#import "kjvQuickBibleSelectController.h"
#import "kjvChapterSelectController.h"

@interface kjvQuickBibleSelectController ()

@end

@implementation kjvQuickBibleSelectController
@synthesize BibleList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 네비 타이틀 항상 흰색
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    BibleList = [global_variable getGroupedNamedBookofBible];
    
    //설정값 가지고 와서 기본 설정하기
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saved_defbibleselect"] == 1)
    {
        _bibleSegControl.selectedSegmentIndex = 1;
        [_bibleQuickView setHidden:YES];
        [_bibleListView setHidden:NO];
    }
    else
    {
        _bibleSegControl.selectedSegmentIndex = 0;
        [_bibleQuickView setHidden:NO];
        [_bibleListView setHidden:YES];
    }
    
}

- (void)viewDidLayoutSubviews
{
    //!!TODO 같은화면에서 회전시 Section 빠른 스크롤 부분에 닿는곳 클릭이 안됨
    // 버튼 그리기
    [[_bibleQuickView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)]; // view 초기화
    [self drawBibleButtons];
}

- (void)drawBibleButtons
{
    int BUTTON_SIZE = 50;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) // 아이패드면 좀더 크게 그린다
        BUTTON_SIZE += IPAD_ICON_PLUS;
    //CGRect screen = [[UIScreen mainScreen] bounds];
    CGSize screenSize = [global_variable getScreenSize]; //IOS8이상부터 자동 디텍팅 되므로 하위호환
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    int screen_width = screenSize.width;
    int screen_height = screenSize.height;
    int lineCount = (int)(screen_width / BUTTON_SIZE);
    
    // 로테이션 방향에 따라 그림 그리기
    UIScrollView *lfaSV;
    if((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight))
        lfaSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height - 30)];
    else if((orientation == UIDeviceOrientationPortrait) || (orientation == UIDeviceOrientationPortraitUpsideDown))
        lfaSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height - 60)];
    // 값 보정
    int linePlus = 0;
    if((NUMBER_OF_BIBLE % lineCount) != 0)
        linePlus++;
    [lfaSV setContentSize:CGSizeMake(screenSize.width, ((NUMBER_OF_BIBLE / lineCount) + linePlus) * BUTTON_SIZE)];
    [lfaSV setShowsVerticalScrollIndicator:YES];
    [lfaSV setShowsHorizontalScrollIndicator:NO];
    [_bibleQuickView addSubview:lfaSV];
    
    for (int i=1; i<=NUMBER_OF_BIBLE; i++)
    {
        UIButton *abutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        abutton.frame = CGRectMake(12 + (((i - 1) % lineCount) * BUTTON_SIZE),(((i - 1) / lineCount) * BUTTON_SIZE), BUTTON_SIZE, BUTTON_SIZE);
        
        NSString *string = [NSString stringWithFormat:@"%02d_",i];
        NSRange Range = [[[NSUserDefaults standardUserDefaults] stringForKey:@"saved_readbible"] rangeOfString:string];
        if(Range.location != NSNotFound)
            [abutton titleLabel].backgroundColor = [UIColor yellowColor];
        else
            [abutton titleLabel].backgroundColor = [UIColor whiteColor];
        [abutton setTag:i-1];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) // 아이패드면 좀더 크게 그린다
            abutton.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        else
            abutton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [abutton setTitle:[NSString stringWithFormat:@"%@",[[global_variable getShortedBookofBible] objectAtIndex:i-1]] forState:UIControlStateNormal];
        [abutton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [lfaSV addSubview:abutton];
    }
}

- (void)buttonClicked:(UIButton*)sender
{
    [self performSegueWithIdentifier:@"bibleChapterSegue" sender:sender];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[BibleList objectAtIndex:section] objectForKey:@"grouptitle"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [BibleList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[BibleList objectAtIndex:section] objectForKey:@"data"] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"bibleChapterSegue" sender:indexPath];
}

/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i=0; i<BibleList.count; i++)
    {
        [arr addObject:[[BibleList objectAtIndex:i] objectForKey:@"grouptitle"]];
    }
    return arr;
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO 인덱스 조금 짤리는거 손보기// 화면 로테이션시 제대로 잡히는데 확인할것
    for(UIView *view in [tableView subviews])
    {
        if([[[view class] description] isEqualToString:@"UITableViewIndex"])
        {
            //CGRect frm = view.frame;
            //frm.size.width = 100;
            //view.frame = frm;
            //[view setBackgroundColor:[UIColor whiteColor]];
        }
    }
    NSString *content = [[[BibleList objectAtIndex:indexPath.section] objectForKey:@"data"]objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plainCell"];
    
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"  %@",content];
    
    return cell;
}

- (IBAction)bibleViewSelect:(id)sender {
    if ([sender selectedSegmentIndex] == 0)
    {
        [_bibleQuickView setHidden:NO];
        [_bibleListView setHidden:YES];
    }
    else
    {
        [_bibleQuickView setHidden:YES];
        [_bibleListView setHidden:NO];
    }
}

// 기기 돌리면 초기화 후 버튼 다시그리기
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self viewDidLayoutSubviews];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"bibleChapterSegue"]) {
        //NSLog(@"%@ %@",sender, [sender class]);
        // 클릭한 주체가 버튼이면 이거 실행
        if([sender isMemberOfClass:[UIButton class]])
        {
        //lfaChapterSelectionViewController *vc = [segue destinationViewController];
        NSInteger tagIndex = [(UIButton *)sender tag];
        [[segue destinationViewController] setNumberofChapter:tagIndex];
        }
        // 버튼이 아니면 이거 실행
        else
        {
            int row_c = 0;
            for(int i=0; i<[(NSIndexPath *)sender section]; i++)
            {
                row_c += [[[BibleList objectAtIndex:i] objectForKey:@"data"] count];
            }
            NSInteger tagIndex = [(NSIndexPath *)sender row] + row_c;
            [[segue destinationViewController] setNumberofChapter:tagIndex];
        }
    }
}

@end
