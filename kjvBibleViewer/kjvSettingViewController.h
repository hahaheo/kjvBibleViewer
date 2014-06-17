//
//  kjvSettingViewController.h
//  kjvBibleViewer
//
//  Created by chan on 14. 5. 14..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface kjvSettingViewController : UITableViewController <UIAlertViewDelegate>
- (IBAction)leftNavBarButtonClick:(id)sender;

@property (nonatomic, strong) UISwitch *mySwitch;
@property (nonatomic, strong) UISwitch *mySwitch2;
@property (nonatomic, strong) UISwitch *mySwitch3;
@property (nonatomic, strong) UISwitch *mySwitch4;
@end
