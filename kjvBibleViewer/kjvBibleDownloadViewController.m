//
//  kjvBibleDownloadViewController.m
//  kjvBibleViewer
//
//  Created by Hyunji Cho on 2014. 5. 21..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import "global_variable.h"
#import "kjvBibleViewController.h"
#import "kjvBibleDownloadViewController.h"
#import "DejalActivityView.h"

@interface kjvBibleDownloadViewController ()

@end

@implementation kjvBibleDownloadViewController

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
    
    if(![global_variable checkConnectedToInternet])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"성경을 다운로드 받기 위해서는 인터넷 연결이 필요합니다. 인터넷 연결 후 다시 시도하세요" delegate:nil cancelButtonTitle:@"닫기" otherButtonTitles:nil];
        [alert show];
        is_internet_connectable = NO;
        return;
    }
    else
        is_internet_connectable = YES;
    
    [self loadDownloadableData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDownloadableData
{
    // 받은 파일들 확인
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    bible_files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory error:nil];
    
    availList = [[NSMutableArray alloc]init];
    availList_down = [[NSMutableArray alloc]init];
    
    //설치된 성경은 스킵
    for (int i=0; i<[[global_variable getBibleNameConverter] count]; i++)
    {
        Boolean check = NO;
        for(int j=0; j<bible_files.count; j++)
        {
            NSMutableString *bname = [bible_files objectAtIndex:(j)];
            if([[[global_variable getDownloadableBibleName] objectAtIndex:i] isEqualToString:[bname substringToIndex:(bname.length-4)]])
            {
                check = YES;
                break;
            }
        }
        if(check)
            continue;
        // 받을수 있는 파일들 파일이름과 성경이름으로 구분하여 저장
        [availList addObject:[[global_variable getBibleNameConverter] objectForKey:[[global_variable getDownloadableBibleName] objectAtIndex:i]]];
        [availList_down addObject:[[global_variable getDownloadableBibleName] objectAtIndex:i]];
    }
}

- (void)kjvDownloadThread:(id)arg
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.kjv",arg]];
    NSData *datalfa = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:KJV_DOWNLOAD_URL,arg]]];
    if(datalfa)
    {
        [datalfa writeToFile:finalPath atomically:YES];
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
    int svd_bookid = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_bookid"];
    int svd_chapterid = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_chapterid"];
    if(!(svd_bookid > 0) && !(svd_chapterid > 0))
    {
        [[NSUserDefaults standardUserDefaults] setObject:arg forKey:@"saved_bookname"];
        [kjvBibleViewController saveTargetedid:1 chapterid:1];
    }
    
    [DejalBezelActivityView removeViewAnimated:YES];
    [self loadDownloadableData];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"다운로드 가능한 목록";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return availList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"plainCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [availList objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(is_internet_connectable)
    {
        [DejalBezelActivityView activityViewForView:self.view withLabel:@"다운로드중입니다..."];
        [NSThread detachNewThreadSelector:@selector(kjvDownloadThread:) toTarget:self withObject:[availList_down objectAtIndex:indexPath.row]];
    }
}

@end
