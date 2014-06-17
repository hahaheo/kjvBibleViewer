//
//  kjvSettingViewController.m
//  kjvBibleViewer
//
//  Created by chan on 14. 5. 14..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import "global_variable.h"
#import "SWRevealViewController.h"
#import "kjvSettingViewController.h"

@interface kjvSettingViewController ()

@end

@implementation kjvSettingViewController

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
    
    // 네비 타이틀 항상 흰색
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    // 컬러 반전 스위치 만들고 설정하기
    // 로테이션에 따라 넓이값 다르게 주기
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    int frame_width = self.view.frame.size.width;
    int frame_height = self.view.frame.size.height;
    //누워있다면 width/height 바꿔서 계산하기
    if((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight))
        frame_width = frame_height;
    
    CGRect myFrame = CGRectMake(frame_width - 65.0f, 6.0f, 250.0f, 25.0f);
    self.mySwitch = [[UISwitch alloc] initWithFrame:myFrame];
    self.mySwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    //set the switch to ON
    if ((int)[[NSUserDefaults standardUserDefaults] integerForKey:@"saved_color"] == 1)
        [self.mySwitch setOn:YES];
    else
        [self.mySwitch setOn:NO];
    //attach action method to the switch when the value changes
    [self.mySwitch addTarget:self action:@selector(changeColorReverse:) forControlEvents:UIControlEventValueChanged];
    
    // 기기끄지않기 스위치 만들고 설정하기
    self.mySwitch2 = [[UISwitch alloc] initWithFrame:myFrame];
    self.mySwitch2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    //set the switch to ON
    if ((int)[[NSUserDefaults standardUserDefaults] integerForKey:@"saved_lockscreen"] == 1)
        [self.mySwitch2 setOn:YES];
    else
        [self.mySwitch2 setOn:NO];
    //attach action method to the switch when the value changes
    [self.mySwitch2 addTarget:self action:@selector(changeLockScreen:) forControlEvents:UIControlEventValueChanged];
    
    // 기본 성경 선택 메뉴 만들기
    self.mySwitch3 = [[UISwitch alloc] initWithFrame:myFrame];
    self.mySwitch3.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    //set the switch to ON
    if ((int)[[NSUserDefaults standardUserDefaults] integerForKey:@"saved_defbibleselect"] == 1)
        [self.mySwitch3 setOn:YES];
    else
        [self.mySwitch3 setOn:NO];
    //attach action method to the switch when the value changes
    [self.mySwitch3 addTarget:self action:@selector(defBibleSelection:) forControlEvents:UIControlEventValueChanged];
    
    // 줄간격 지우기 버튼 만들기
    self.mySwitch4 = [[UISwitch alloc] initWithFrame:myFrame];
    self.mySwitch4.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    //set the switch to ON
    if ((int)[[NSUserDefaults standardUserDefaults] integerForKey:@"saved_deleteverseline"] == 1)
        [self.mySwitch4 setOn:YES];
    else
        [self.mySwitch4 setOn:NO];
    //attach action method to the switch when the value changes
    [self.mySwitch4 addTarget:self action:@selector(deleteVerseLine:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *section_name = [NSString alloc];
    if(section == 0) // bible selecion
        section_name = @"본문 글씨크기 설정";
    else if (section == 1) // another bible
        section_name = @"본문 줄간격 설정";
    else if (section == 2) // another bible
        section_name = @"기타 설정";
    
    return section_name;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (IBAction)leftNavBarButtonClick:(id)sender {
    [self.revealViewController revealToggleAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int num_cell = 0;
    if(section == 0) // 글씨 크기
        num_cell = 3;
    else if (section == 1) // 글씨 줄간격
        num_cell = 3;
    else if (section == 2) // 기타 설정s
        num_cell = 7;
    
    return num_cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0:
                identifier = @"fontsize_big";
                break;
            case 1:
                identifier = @"fontsize_normal";
                break;
            case 2:
                identifier = @"fontsize_small";
                break;
        }
    }
    else if (indexPath.section == 1)
    {
        switch (indexPath.row) {
            case 0:
                identifier = @"lineheight_big";
                break;
            case 1:
                identifier = @"lineheight_normal";
                break;
            case 2:
                identifier = @"lineheight_small";
                break;
        }
    }
    else if (indexPath.section == 2)
    {
        switch (indexPath.row) {
            case 0:
                identifier = @"color_reverse";
                break;
            case 1:
                identifier = @"def_bible_select";
                break;
            case 2:
                identifier = @"do_lockscreen";
                break;
            case 3:
                identifier = @"del_verseline";
                break;
            case 4:
                identifier = @"init_readdata";
                break;
            case 5:
                identifier = @"init_searchlog";
                break;
            case 6:
                identifier = @"init_highlight";
                break;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    // text 크기 조절
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.font = [UIFont systemFontOfSize:BIG_FONT_SIZE];
                break;
            case 1:
                cell.textLabel.font = [UIFont systemFontOfSize:DEF_FONT_SIZE];
                break;
            case 2:
                cell.textLabel.font = [UIFont systemFontOfSize:SMALL_FONT_SIZE];
                break;
        }
        
        // 폰트 사이즈대로 체크표시
        if((int)[[NSUserDefaults standardUserDefaults] floatForKey:@"saved_fontsize"] == cell.textLabel.font.pointSize)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;

    }
    else if(indexPath.section == 1)
    {
        cell.textLabel.font = [UIFont systemFontOfSize:DEF_FONT_SIZE];
        
        // 폰트 높이대로 체크표시 = (실사이즈 - 폰트사이즈) / 2
        //CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
        // 애매해서 변경할래
        /*
        if((int)[[NSUserDefaults standardUserDefaults] floatForKey:@"saved_lineheightsize"] == ((frame.size.height - DEF_FONT_SIZE) / 2))
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        */
        if(((int)[[NSUserDefaults standardUserDefaults] floatForKey:@"saved_lineheightsize"] == BIG_FONT_GAP) && (indexPath.row == 0))
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else if(((int)[[NSUserDefaults standardUserDefaults] floatForKey:@"saved_lineheightsize"] == DEF_FONT_GAP) && (indexPath.row == 1))
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else if(((int)[[NSUserDefaults standardUserDefaults] floatForKey:@"saved_lineheightsize"] == SMALL_FONT_GAP) && (indexPath.row == 2))
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        //NSLog(@"row height : %f", frame.size.height);
    }
    else if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            [cell addSubview:self.mySwitch];
        }
        if(indexPath.row == 1)
        {
            [cell addSubview:self.mySwitch3];
        }
        if(indexPath.row == 2)
        {
            [cell addSubview:self.mySwitch2];
        }
        if(indexPath.row == 3)
        {
            [cell addSubview:self.mySwitch4];
        }
    }
    
    return cell;
}

// 열의 높이를 설정
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        switch (indexPath.row) {
            case 0:
                return BIG_FONT_GAP * 2 + 30;
            case 1:
                return DEF_FONT_GAP *2 + 30;
            case 2:
                return SMALL_FONT_GAP * 2 + 30;
        }
    }
    else if (indexPath.section == 0)
        return DEF_FONT_GAP * 2 + 30;
    
    // 나머지 높이 설정
    return 43.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 폰트 선택한 경우
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0:
                [[NSUserDefaults standardUserDefaults] setFloat:BIG_FONT_SIZE forKey:@"saved_fontsize"];
                break;
            case 1:
                [[NSUserDefaults standardUserDefaults] setFloat:DEF_FONT_SIZE forKey:@"saved_fontsize"];
                break;
            case 2:
                [[NSUserDefaults standardUserDefaults] setFloat:SMALL_FONT_SIZE forKey:@"saved_fontsize"];
                break;
        }
    }
    // 줄간격 선택한 경우
    else if (indexPath.section == 1)
    {
        switch (indexPath.row) {
            case 0:
                [[NSUserDefaults standardUserDefaults] setFloat:BIG_FONT_GAP forKey:@"saved_lineheightsize"];
                break;
            case 1:
                [[NSUserDefaults standardUserDefaults] setFloat:DEF_FONT_GAP forKey:@"saved_lineheightsize"];
                break;
            case 2:
                [[NSUserDefaults standardUserDefaults] setFloat:SMALL_FONT_GAP forKey:@"saved_lineheightsize"];
                break;
        }
    }
    // 그외
    else if (indexPath.section == 2)
    {
        UIAlertView *alert;
        switch (indexPath.row) {
            case 4:
                // 기록삭제 경고 설정하기
                alert = [[UIAlertView alloc] initWithTitle:@"알람" message:@"정말로 성경읽은 기록을 삭제하시겠습니까?" delegate:self cancelButtonTitle: @"삭제" otherButtonTitles: @"취소",nil];
                alert.tag = 101;
                [alert show];
                //[alert release];
                break;
            case 5:
                alert = [[UIAlertView alloc] initWithTitle:@"알람" message:@"정말로 검색기록을 삭제하시겠습니까?" delegate:self cancelButtonTitle: @"삭제" otherButtonTitles: @"취소",nil];
                alert.tag = 102;
                [alert show];
                //[alert release];
                break;
            case 6:
                alert = [[UIAlertView alloc] initWithTitle:@"알람" message:@"정말로 저장된 밑줄 기록을 삭제하시겠습니까?" delegate:self cancelButtonTitle: @"삭제" otherButtonTitles: @"취소",nil];
                alert.tag = 103;
                [alert show];
                //[alert release];
                break;
        }
    }
    
    else return;
    
    [self.tableView reloadData];
}

// 성경읽은 데이터 삭제시 트리거
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0) {
        if (alertView.tag == 101) {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"saved_readbible"];
        }
        else if (alertView.tag == 102) {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"saved_searchlog"];
        }
        else if (alertView.tag == 103) {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"saved_highlight"];
        }
    }
}

- (IBAction)changeColorReverse:(UISwitch *)sender {
    if(sender.on)
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"saved_color"];
    else
        [[NSUserDefaults standardUserDefaults] setInteger:COLOR_REVERSED forKey:@"saved_color"];
    return;
}

- (IBAction)changeLockScreen:(UISwitch *)sender {
    if(sender.on)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"saved_lockscreen"];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"saved_lockscreen"];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    return;
}

- (IBAction)defBibleSelection:(UISwitch *)sender {
    if(sender.on)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"saved_defbibleselect"];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"saved_defbibleselect"];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    return;
}

- (IBAction)deleteVerseLine:(UISwitch *)sender {
    if(sender.on)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"saved_deleteverseline"];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"saved_deleteverseline"];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    return;
}

@end
