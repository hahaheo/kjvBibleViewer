//
//  kjvActivity.m
//  kjvBibleViewer
//
//  Created by Hyunji Cho on 2014. 5. 31..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import "kjvActivity.h"

@implementation kjvActivityProvider
- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] )
        return @"This is a #twitter post!";
    if ( [activityType isEqualToString:UIActivityTypePostToFacebook] )
        return @"This is a facebook post!";
    if ( [activityType isEqualToString:UIActivityTypeMessage] )
        return @"SMS message text";
    if ( [activityType isEqualToString:UIActivityTypeMail] )
        return @"Email text here!";
    if ( [activityType isEqualToString:@"it.albertopasca.myApp"] )
        return @"OpenMyapp custom text";
    return nil;
}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }
@end

@implementation kjvActivity
{
    NSString *highlightData;
}

// ActionSheet에 보여질 앱 이미지
- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"menu"];
}

// ActionSheet에 보여질 크롬 앱 제목
- (NSString *)activityTitle
{
    return @"밑줄 긋기/제거";
}

// ActionSheet에 보여지는 앱은 iOS에 설치된 상태여야한다. (항상 YES)
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    // 선택된 데이터 파싱 작업
    for (int i=1; i<activityItems.count; i++)
    {
        ((NSMutableDictionary)[activityItems objectAtIndex:i])
    }
    
    // 현재 보고있는 성경
    
    // 하이라이트에 이미 저장되어있는 구절은 반대로 체크하기
    
    highlightData;
}

// 앱 실행
- (void)performActivity
{

    
    [self activityDidFinish:YES];
}

- (void)activityDidFinish:(BOOL)completed
{
    //NSLog(@"activityDidFinish");
    [super activityDidFinish:completed];
}

@end