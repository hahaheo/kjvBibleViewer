//
//  kjvAboutViewController.h
//  kjvBibleViewer
//
//  Created by chan on 14. 5. 14..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface kjvAboutViewController : UIViewController
- (IBAction)leftNavBarButtonClick:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *aboutText;

@end
