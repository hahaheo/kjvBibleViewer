//
//  kjvChapterSelectController.h
//  kjvBibleViewer
//
//  Created by Hyunji Cho on 2014. 5. 18..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface kjvChapterSelectController : UIViewController
{
    int book_id;
}
@property (strong, nonatomic) IBOutlet UINavigationItem *NavTitle;
-(void)setNumberofChapter:(int)num;
@end
