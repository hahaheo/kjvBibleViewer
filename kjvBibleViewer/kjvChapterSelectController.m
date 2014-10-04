//
//  kjvChapterViewController.m
//  kjvBibleViewer
//
//  Created by Hyunji Cho on 2014. 5. 18..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import "global_variable.h"
#import "kjvChapterSelectController.h"
#import "kjvBibleViewController.h"

@interface kjvChapterSelectController ()

@end

@implementation kjvChapterSelectController

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
    
    // 네비 타이틀 항상 흰색
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonClicked:(UIButton*)sender
{
    // 선택한 성경과 장을 저장하고
    [kjvBibleViewController saveTargetedid:book_id chapterid:sender.tag];
    
    // 새로고침 하기
    [kjvBibleViewController setdoviewDidLoad:YES];
    
    // 그전으로 이동하기
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController popToViewController:prevVC animated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
    //[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setNumberofChapter:(int)num
{
    [self setNumberofChapter:num isChangeOrientation:false];
}

- (void)setNumberofChapter:(int)num isChangeOrientation:(BOOL)isCO
{
    int BUTTON_SIZE = 50;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) // 아이패드면 좀더 크게 그린다
        BUTTON_SIZE += IPAD_ICON_PLUS;
    NSString *temp = [[global_variable getNumberofChapterinBook] objectAtIndex:num];
    CGSize screenSize = [global_variable getScreenSize]; //IOS8이상부터 자동 디텍팅 되므로 하위호환
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    int screen_width = screenSize.width;
    int screen_height = screenSize.height;
    //int diff = 0;
    //누워있다면 width/height 바꿔서 계산하기
    //if((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight))
    //    diff = 15; // 누웠을때 보정값
    int lineCount = (int)(screen_width / BUTTON_SIZE);
    // uiscroll을 만들어서 내용 추가
    UIScrollView *chapterSV;
    //ios8 대응, 첫 시작시에만 적용
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) // 7.1 이하인 경우 무조껀 실행,
        chapterSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, screen_width, screen_height - 60)];
    else if (isCO) // 7.1 이상인데 landscape로 화면 돌린경우 적용
    {
        if(((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight)) && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            chapterSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, screen_width, screen_height - 30)];
        else
            chapterSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, screen_width, screen_height - 60)];
    }
    else // 7.1 이상인데 첫 화면 진입한 경우
        chapterSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
    
    // 값 보정
    int linePlus = 0;
    if(([temp integerValue] % lineCount) != 0)
        linePlus++;
    [chapterSV setContentSize:CGSizeMake(screen_width, (([temp integerValue] / lineCount) + linePlus) * BUTTON_SIZE)]; // 스크린의 전체 크기 구하기
    [chapterSV setShowsVerticalScrollIndicator:YES];
    [chapterSV setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:chapterSV];
    
    for (int i=1; i<=[temp integerValue]; i++)
    {
        UIButton *abutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        abutton.frame = CGRectMake(5 + ((i - 1) % lineCount) * BUTTON_SIZE, ((i - 1) / lineCount) * BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE);
        
        NSString *string = [NSString stringWithFormat:@"%02d_%03d",num + 1, i];
        NSRange Range = [[[NSUserDefaults standardUserDefaults] stringForKey:@"saved_readbible"] rangeOfString:string];
        if(Range.location != NSNotFound)
            [abutton titleLabel].backgroundColor = [UIColor yellowColor];
        else
            [abutton titleLabel].backgroundColor = [UIColor whiteColor];
        
        [abutton setTag:i];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) // 아이패드면 좀더 크게 그린다
            abutton.titleLabel.font = [UIFont systemFontOfSize:23.0f];
        else
            abutton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [abutton setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        [abutton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [chapterSV addSubview:abutton];
    }
    
    _NavTitle.title = [[global_variable getNamedBookofBible] objectAtIndex:num];
    book_id = num+1;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)]; // view 초기화
    [self setNumberofChapter:book_id - 1 isChangeOrientation:true];
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
