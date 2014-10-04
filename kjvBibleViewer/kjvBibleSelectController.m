//
//  kjvBibleSelectController.m
//  kjvBibleViewer
//
//  Created by Hyunji Cho on 2014. 5. 18..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import "global_variable.h"
#import "kjvBibleSelectController.h"
#import "kjvChapterSelectController.h"

@interface kjvBibleSelectController ()

@end

@implementation kjvBibleSelectController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    BibleList = [global_variable getGroupedNamedBookofBible];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i=0; i<BibleList.count; i++)
    {
        [arr addObject:[[[BibleList objectAtIndex:i] objectForKey:@"data"] objectAtIndex:0]];
    }
    return arr;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *content = [[[BibleList objectAtIndex:indexPath.section] objectForKey:@"data"]objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plainCell"];
    
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"  %@",content];
    
    return cell;
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"bibleChapterSegue"]) {
        int row_c = 0;
        for(int i=0; i<[(NSIndexPath *)sender section]; i++)
        {
            row_c += [[[BibleList objectAtIndex:i] objectForKey:@"data"] count];
        }
        NSInteger tagIndex = [(NSIndexPath *)sender row] + row_c;
        [[segue destinationViewController] setNumberofChapter:tagIndex];
    }
}

@end
