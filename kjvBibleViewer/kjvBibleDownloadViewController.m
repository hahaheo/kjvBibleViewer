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

@import CloudKit;
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ERROR" message:@"성경을 다운로드 받기 위해서는 인터넷 연결이 필요합니다. 인터넷 연결 후 다시 시도하세요" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
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
    
    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:arg];
    [publicDatabase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
        if (error) {
            // Error handling for failed fetch from public database
            UIAlertController *alert = [UIAlertController alloc];
            if ([error code] == 1) {
                alert = [UIAlertController alertControllerWithTitle:@"ERROR" message:@"애플계정이 활성화되지 않았습니다. 역본 다운로드를 위해 애플계정 로그인이 필요합니다. 설정->iCloud 에서 애플계정 로그인을 해주세요." preferredStyle:UIAlertControllerStyleAlert];
            }
            else {
                alert = [UIAlertController alertControllerWithTitle:@"ERROR" message:@"다운로드가 유효하지 않습니다. 개발자에게 문의 바랍니다." preferredStyle:UIAlertControllerStyleAlert];
            }
            [self presentViewController:alert animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:nil];
            });
        }
        else {
            // Display the fetched record
            CKAsset *asset = [record objectForKey:@"file"];
            NSData *datalfa = [NSData dataWithContentsOfURL:[asset fileURL]];
            [datalfa writeToFile:finalPath atomically:YES];
            // 파일 백업 금지하기 (icloud위반)
            [global_variable addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:finalPath]];
            
            NSInteger svd_bookid = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_bookid"];
            NSInteger svd_chapterid = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_chapterid"];
            if(!(svd_bookid > 0) && !(svd_chapterid > 0))
            {
                [[NSUserDefaults standardUserDefaults] setObject:arg forKey:@"saved_bookname"];
                [kjvBibleViewController saveTargetedid:1 chapterid:1];
            }
            
            [DejalActivityView removeView];
            [self loadDownloadableData];
            [self.tableView reloadData];
        }
    }];
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
        [DejalBezelActivityView activityViewForView:self.view withLabel:@"다운로드중입니다."];
        [NSThread detachNewThreadSelector:@selector(kjvDownloadThread:) toTarget:self withObject:[availList_down objectAtIndex:indexPath.row]];
    }
}

@end
