//
//  kjvAboutViewController.m
//  kjvBibleViewer
//
//  Created by chan on 14. 5. 14..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import "SWRevealViewController.h"
#import "kjvAboutViewController.h"

@interface kjvAboutViewController ()

@end

@implementation kjvAboutViewController

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
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    // Do any additional setup after loading the view.
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Stainless-steel.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //TODO: 화면 크기에 따라 택스트 출력 변환하기
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSLog(@"%f %f", screenRect.size.height, screenRect.size.width);
    // iphone에서 누워있는 경우
    if((screenRect.size.width <= 320) && (orientation != UIDeviceOrientationPortrait))
    {
        CGRect frame = _aboutText.frame;
        frame.origin.y = 40;//pass the cordinate which you want
        _aboutText.frame = frame;
    }
    // ipad 경우
    else if(screenRect.size.width > 320)
    {
        CGRect frame = _aboutText.frame;
        frame.origin.y = 40;//pass the cordinate which you want
        _aboutText.frame = frame;
    }
    [_aboutText updateConstraints];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)leftNavBarButtonClick:(id)sender {
    [self.revealViewController revealToggleAnimated:YES];
}
@end
