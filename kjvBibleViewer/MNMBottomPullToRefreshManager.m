/*
 * Copyright (c) 2012 Mario Negro Martín
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 */

#import "MNMBottomPullToRefreshManager.h"
#import "MNMBottomPullToRefreshView.h"

CGFloat const kAnimationDuration = 0.2f;

@interface MNMBottomPullToRefreshManager()

/*
 * Pull-to-refresh view
 */
@property (nonatomic, readwrite, strong) MNMBottomPullToRefreshView *pullToRefreshView;

/*
 * Table view which p-t-r view will be added
 */
@property (nonatomic, readwrite, weak) UITableView *table;

/*
 * Client object that observes changes
 */
@property (nonatomic, readwrite, weak) id<MNMBottomPullToRefreshManagerClient> client;

/*
 * Returns the correct offset to apply to the pull-to-refresh view, depending on contentSize
 *
 * @return The offset
 * @private
 */
- (CGFloat)tableScrollOffset;

@end

@implementation MNMBottomPullToRefreshManager

@synthesize pullToRefreshView = pullToRefreshView_;
@synthesize table = table_;
@synthesize client = client_;

#pragma mark -
#pragma mark Instance initialization

/*
 * Initializes the manager object with the information to link view and table
 */
- (id)initWithPullToRefreshViewHeight:(CGFloat)height tableView:(UITableView *)table withClient:(id<MNMBottomPullToRefreshManagerClient>)client {

    if (self = [super init]) {
        
        client_ = client;
        table_ = table;
        //NSLog(@"%f %f",CGRectGetWidth([table_ frame]), CGRectGetHeight([table_ frame]));
        // 방향에 따라 넓이값 다르게 주기
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        int frame_width = CGRectGetWidth([table_ frame]);
        int frame_height = CGRectGetHeight([table_ frame]);
        //누워있다면 width/height 바꿔서 계산하기
        if((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight))
            frame_width = frame_height;
        
        // 뷰를 중앙에 방향 맞추기
        pullToRefreshView_ = [[MNMBottomPullToRefreshView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame_width, height)];
        pullToRefreshView_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    
    return self;
}

#pragma mark -
#pragma mark Visuals

/*
 * Returns the correct offset to apply to the pull-to-refresh view, depending on contentSize
 */
- (CGFloat)tableScrollOffset {
    
    CGFloat offset = 0.0f;        
    
    if ([table_ contentSize].height + 60 < CGRectGetHeight([table_ frame])) {
        //NSLog(@"1 %f",[table_ contentOffset].y);
        offset = -[table_ contentOffset].y - 10;
        
    } else {
        //NSLog(@"%f, %f, %f", [table_ contentSize].height, [table_ contentOffset].y, CGRectGetHeight([table_ frame]));
        offset = ([table_ contentSize].height - [table_ contentOffset].y) - CGRectGetHeight([table_ frame]);
    }
    
    return offset;
}

/*
 * Relocate pull-to-refresh view
 */
- (void)relocatePullToRefreshView {
    
    CGFloat yOrigin = 0.0f;
    
    if ([table_ contentSize].height + 60 >= CGRectGetHeight([table_ frame])) {
        
        yOrigin = [table_ contentSize].height;
        
    } else { // 아이폰 3.5에 맞게 수정필요
        //NSLog(@"2 %f",CGRectGetHeight([table_ frame]));
        yOrigin = CGRectGetHeight([table_ frame]) - 30;
    }
    
    CGRect frame = [pullToRefreshView_ frame];
    frame.origin.y = yOrigin;
    [pullToRefreshView_ setFrame:frame];
    
    [table_ addSubview:pullToRefreshView_];
}

/*
 * Sets the pull-to-refresh view visible or not. Visible by default
 */
- (void)setPullToRefreshViewVisible:(BOOL)visible {
    
    [pullToRefreshView_ setHidden:!visible];
}

#pragma mark -
#pragma mark Table view scroll management

/*
 * Checks state of control depending on tableView scroll offset
 */
- (void)tableViewScrolled {
    
    if (![pullToRefreshView_ isHidden] && ![pullToRefreshView_ isLoading]) {
        
        CGFloat offset = [self tableScrollOffset];

        if (offset >= 0.0f) {
            
            [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStateIdle offset:offset];
            
        } else if (offset <= 0.0f && offset >= -[pullToRefreshView_ fixedHeight]) {
                
            [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStatePull offset:offset];
            
        } else {
            
            [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStateRelease offset:offset];
        }
    }
}

/*
 * Checks releasing of the tableView
 */
- (void)tableViewReleased {
    
    if (![pullToRefreshView_ isHidden] && ![pullToRefreshView_ isLoading]) {
        
        CGFloat offset = [self tableScrollOffset];
        CGFloat height = -[pullToRefreshView_ fixedHeight];
        
        //NSLog(@"%f %f", offset, height);
        
        if (offset <= 0.0f && offset < height) {
            
            [client_ bottomPullToRefreshTriggered:self];
            /*
            [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStateLoading offset:offset];
            
            [UIView animateWithDuration:kAnimationDuration animations:^{
                
                if ([table_ contentSize].height >= CGRectGetHeight([table_ frame])) {
                
                    [table_ setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, -height, 0.0f)];
                    
                } else {
                    
                    [table_ setContentInset:UIEdgeInsetsMake(height, 0.0f, 0.0f, 0.0f)];
                }
            }];
             */
        }
    }
}

//TODO 내가 대충만든 펑션
- (void)tableViewDelete {
    CGFloat yOrigin = 0.0f;
    yOrigin = CGRectGetHeight([table_ frame]) + 1000;
    
    CGRect frame = [pullToRefreshView_ frame];
    frame.origin.y = yOrigin;
    [pullToRefreshView_ setFrame:frame];
    
    [table_ addSubview:pullToRefreshView_];
}

/*
 * The reload of the table is completed
 */
- (void)tableViewReloadFinished {
    [table_ setContentInset:UIEdgeInsetsZero];
    [self relocatePullToRefreshView];
    [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStateIdle offset:CGFLOAT_MAX];
}

@end