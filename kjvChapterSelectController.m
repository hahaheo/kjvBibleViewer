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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"selectedChapterandBibleSegue"]) {
        NSInteger tagIndex = [(UIButton*)sender tag];
        [[segue destinationViewController] saveTargetedid:book_id chapterid:tagIndex];
    }
}


- (void)buttonClicked:(UIButton*)sender
{
    [self performSegueWithIdentifier:@"selectedChapterandBibleSegue" sender:sender];
}

- (void)setNumberofChapter:(int)num
{
    NSString *temp = [[global_variable getNumberofChapterinBook] objectAtIndex:num];
    CGRect screen = [[UIScreen mainScreen] bounds];
    UIScrollView *chapterSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0,100,screen.size.width,screen.size.height-70)];
    [chapterSV setContentSize:CGSizeMake(screen.size.width, ([temp integerValue]/6)*45)];
    [chapterSV setShowsVerticalScrollIndicator:YES];
    [chapterSV setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:chapterSV];
    
    for (int i=1; i<=[temp integerValue]; i++)
    {
        UIButton *abutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        abutton.frame = CGRectMake(12+((i-1)%6)*50,((i-1)/6)*45,44,40);
        
        NSString *string = [NSString stringWithFormat:@"%02d_%03d",num+1,i];
        NSRange Range = [[[NSUserDefaults standardUserDefaults] stringForKey:@"saved_readbible"] rangeOfString:string];
        if(Range.location != NSNotFound)
            [abutton titleLabel].backgroundColor = [UIColor yellowColor];
        else
            [abutton titleLabel].backgroundColor = [UIColor whiteColor];
        
        [abutton setTag:i];
        [abutton setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        [abutton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [chapterSV addSubview:abutton];
    }
    
    _NavTitle.title = [[global_variable getNamedBookofBible] objectAtIndex:num];
    book_id = num;
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
