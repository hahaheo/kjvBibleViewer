//
//  kjvActivity.m
//  kjvBibleViewer
//
//  Created by Hyunji Cho on 2014. 5. 31..
//  Copyright (c) 2014년 chan. All rights reserved.
//

#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "kjvActivity.h"

@implementation kjvActivityProvider
- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
   
    return nil;
}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }
@end

@implementation kjvActivity

// ActionSheet에 보여질 앱 이미지
- (UIImage *)activityImage
{
    // Note: These images need to have a transparent background and I recommend these sizes:
    // iPadShare@2x should be 126 px, iPadShare should be 53 px, iPhoneShare@2x should be 100
    // px, and iPhoneShare should be 50 px. I found these sizes to work for what I was making.
    return [UIImage imageNamed:@"highlight"];
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
    // 다중역본 case: 같은 세션일 경우 체크
    NSString *bhighlight;
    // 이미 하이라이트된 정보 가져오기
    NSMutableString *highlight = [[[NSUserDefaults standardUserDefaults] stringForKey:@"saved_highlight"] mutableCopy];
    // 현재 보고있는 성경
    int bookid = [[NSUserDefaults standardUserDefaults] integerForKey:@"saved_bookid"];
    
    // 선택된 데이터 파싱 작업
    for(int i=1; i<activityItems.count; i++)
    {
        NSArray *temp = [activityItems[i] componentsSeparatedByString:@":"];
        NSArray *temp2 = [temp[1] componentsSeparatedByString:@" "];
        // 다중역본일 경우 앞에 역본괄호 제거
        NSArray *sep = [[[NSUserDefaults standardUserDefaults] stringForKey:@"saved_another_bookname"] componentsSeparatedByString:@"|"];
        NSString *chapterNum = temp[0]; // 장
        if (sep.count > 1)
        {
            NSArray *temp3 = [temp[0] componentsSeparatedByString:@"]"];
            chapterNum = temp3[1];
        }
        else chapterNum = temp[0]; // 장
        NSString *verseNum = temp2[0]; // 절
        NSString *nhighlight = [NSString stringWithFormat:@"|%02d_%02d_%03d", bookid, [chapterNum intValue], [verseNum intValue]];
        if ([bhighlight isEqualToString:nhighlight]) continue;
        bhighlight = nhighlight;

        // 해당 내용을 바탕으로 하이라이트에 이미 저장되어있나 체크하기
        NSRange textRange = [highlight rangeOfString:nhighlight];
        if(textRange.location != NSNotFound)
        {
            // 이미 highlight가 선언되어 있던거라면 삭제하기
            [highlight deleteCharactersInRange:textRange];
        }
        else
        {
            // 안에 없으면 새로 추가하기
            [highlight appendString:nhighlight];
        }
    }
    // 환경변수에 저장하기
    [[NSUserDefaults standardUserDefaults] setObject:highlight forKey:@"saved_highlight"];
}

// 앱 실행 - 여기서는 할거 없음
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

@implementation kjvKakaoActivity

// ActionSheet에 보여질 앱 이미지
- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"kakaotalk"];
}

// ActionSheet에 보여질 크롬 앱 제목
- (NSString *)activityTitle
{
    return @"카카오톡 보내기";
}

// ActionSheet에 보여지는 앱은 iOS에 설치된 상태여야한다.
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSString *kakaotalk = [NSString stringWithFormat:@"%@",@"kakaolink://"];
    BOOL isInstalledKakaoTalk = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kakaotalk]];
    
    return isInstalledKakaoTalk;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    // String에 하나하나 추가
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"%@ ", activityItems[0]]; // 가장 앞 타이틀 추가
    for(int i=1; i<activityItems.count; i++)
    {
        [result appendFormat:@"%@ ", [activityItems[i] valueForKey:@"content"]];
    }
    
    KakaoTalkLinkObject *button = [KakaoTalkLinkObject createWebButton:@"KeepBible 홈페이지 이동" url:@"http://keepbible.com"];
    KakaoTalkLinkObject *label = [KakaoTalkLinkObject createLabel:result];
    [KOAppCall openKakaoTalkAppLink:@[label,button]];
}

// 앱 실행 - 여기서는 할거 없음
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
