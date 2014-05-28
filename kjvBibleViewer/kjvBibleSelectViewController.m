//
//  kjvBibleSelectViewController.m
//  kjvBibleViewer
//
//  Created by Hyunji Cho on 2014. 5. 21..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import "global_variable.h"
#import "SWRevealViewController.h"
#import "kjvBibleSelectViewController.h"

@interface kjvBibleSelectViewController ()

@end

@implementation kjvBibleSelectViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 역본 다운로드 후 업데이트 된 내용이 보여주어야 하기 떄문에 어피어시 업데이트
    
    selectedCell =  -1;
    // 받아온 역본들 있나 확인하는 셋팅
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    bible_files = [[NSMutableArray alloc]init];
    NSArray *temp = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory error:nil];
    for(int i=0; i<temp.count; i++)
    {
        // 확장자 제거한 다운로드 받은 바이블 파일 리스트
        [bible_files addObject:[[temp objectAtIndex:i] substringToIndex:[[temp objectAtIndex:i] length]-4]];
    }
    
    // 받은 성경파일중 지금보는 성경 구분하기
    [self arrangeBibleListforMulti];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)arrangeBibleListforMulti
{
    //bible_files_multi = [[NSMutableArray alloc]init];
    bible_files_remain = [[NSMutableArray alloc]init];
    NSString *temp_saved = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_bookname"];
    NSString *BookName = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_another_bookname"];
    
    for(int i=0; i<bible_files.count; i++)
    {
        if(![temp_saved isEqualToString:[bible_files objectAtIndex:i]])
        {
            // 메인성경빼고 다운로드받은 성경 모두 추가
            //[bible_files_multi addObject:[bible_files objectAtIndex:i]];
            
            // 그중, 역본선택하지 않은 성경 모두 추가
            NSRange range = [BookName rangeOfString:[bible_files objectAtIndex:i]];
            if(range.location == NSNotFound)
                [bible_files_remain addObject:[bible_files objectAtIndex:i]];
        }
    }
    
    //NSLog(@"%@ %@", bible_files, bible_files_remain);
}

- (IBAction)leftNavBarButtonClick:(id)sender {
    [self.revealViewController revealToggleAnimated:YES];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *section_name = [NSString alloc];
    if(section == 0) // bible selecion
        section_name = @"성경 선택 및 관리";
    else if (section == 1) // another bible
        section_name = @"다중역본 선택";
    else if (section == 2) // another bible
        section_name = @"추가역본 다운로드";
    
    return section_name;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int num_cell = 0;
    if(section == 0) // 모든성경
        num_cell = bible_files.count;
    else if (section == 1) // 역본 셋팅된 성경
        num_cell = bible_files.count - 1;
    else if (section == 2) // 역본 다운로드 받기 연결
        num_cell = 1;
    
    return num_cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    if (indexPath.section == 2)
        identifier = @"bible_downloadlink";
    else
        identifier = @"plainCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    //section 0
    if(indexPath.section == 0)
    {
        NSString *bname = [bible_files objectAtIndex:(indexPath.row)];
        //NSLog(@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"saved_bookname"] );
        // 바로 선택되었거나 북네임에 저장되어있는 아이는
        if(indexPath.row == selectedCell || [[[NSUserDefaults standardUserDefaults] stringForKey:@"saved_bookname"] isEqualToString:bname])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark; // 체크마크를 달아준다
            //cell.selected = YES;
        } else { // 아니면 체크마크가 없다
            cell.accessoryType = UITableViewCellAccessoryNone;
            //cell.selected = NO;
        }
        
        cell.textLabel.text = [[global_variable getBibleNameConverter] objectForKey:bname];
    }
    //section 1
    else if(indexPath.section == 1)
    {
        NSArray *a_BookName = [[[NSUserDefaults standardUserDefaults] stringForKey:@"saved_another_bookname"] componentsSeparatedByString:@"|"];
        int a_BookNameCount = a_BookName.count;
        if([[a_BookName objectAtIndex:0] isEqualToString:@""])
            a_BookNameCount = 0;
        
        // 체크된것
        if(indexPath.row < a_BookNameCount)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.textLabel.text = [[global_variable getBibleNameConverter] objectForKey:[a_BookName objectAtIndex:indexPath.row]];
        }
        
        // 체크안된것
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = [[global_variable getBibleNameConverter] objectForKey:[bible_files_remain objectAtIndex:(indexPath.row - a_BookNameCount)]];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //성경 선택한 경우
    if(indexPath.section == 0)
    {
        // 역본 선택했다고 알려준다
        selectedCell = indexPath.row;
        NSString *bname = [bible_files objectAtIndex:(indexPath.row)];
        [[NSUserDefaults standardUserDefaults] setObject:bname forKey:@"saved_bookname"];
        
        // 순서대로 역본을 리스트에다 추가
        [self arrangeBibleListforMulti];
        [self.tableView reloadData];
    }
    //다중역본 선택한 경우
    else if(indexPath.section == 1)
    {
        NSArray *a_BookName = [[[NSUserDefaults standardUserDefaults] stringForKey:@"saved_another_bookname"] componentsSeparatedByString:@"|"];
        int a_BookNameCount = a_BookName.count;
        if([[a_BookName objectAtIndex:0] isEqualToString:@""])
            a_BookNameCount = 0;
        
        NSMutableString *na_BookName = [[NSMutableString alloc] init];
        NSString *sep_bar = @"|";
        
        // 체크된것 (del action)
        if(indexPath.row < a_BookNameCount)
        {
            for(int i=0; i<a_BookNameCount; i++)
            {
                NSString *string = [a_BookName objectAtIndex:indexPath.row];
                if([[a_BookName objectAtIndex:i] isEqualToString:string])
                    continue;
                [na_BookName appendString:[a_BookName objectAtIndex:i]];
                [na_BookName appendString:sep_bar];
            }
            if([na_BookName hasSuffix:sep_bar])
                na_BookName = [[na_BookName substringWithRange:NSMakeRange(0, na_BookName.length-1)] mutableCopy];
        }
        
        // 체크안된것 (add action)
        else
        {
            // 역본 선택을 맥시멈 이상 수가 되었다면 안되게 막기
            if(a_BookNameCount < MAXIMUM_CONCURRNET_BIBLE)
            {
                NSString *string = [bible_files_remain objectAtIndex:(indexPath.row - a_BookNameCount)];
                na_BookName = [[[[NSUserDefaults standardUserDefaults] stringForKey:@"saved_another_bookname"] stringByAppendingString:[sep_bar stringByAppendingString:string]] mutableCopy];
                if([na_BookName hasPrefix:sep_bar])
                    na_BookName = [[na_BookName substringWithRange:NSMakeRange(1, na_BookName.length-1)] mutableCopy];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"경고" message:[NSString stringWithFormat:@"%d권 이상 동시에 볼 수 없습니다", MAXIMUM_CONCURRNET_BIBLE] delegate:self cancelButtonTitle: @"닫기" otherButtonTitles:nil];
                alert.tag = 103;
                [alert show];
                return;
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:na_BookName forKey:@"saved_another_bookname"];
        [self arrangeBibleListforMulti];
        [self.tableView reloadData];
    }
}

@end
