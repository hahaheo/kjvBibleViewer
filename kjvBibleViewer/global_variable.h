//
//  global_variable.h
//  lfa viewer
//
//  Created by Chan Heo on 3/20/13.
//  Copyright (c) 2013 Chan Heo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define REMOVE_PULL_RELOAD_BOTTOM_TAG 1234
#define BUFFER_SIZE 65535
#define MAX_SEARCH_RESULT 300
#define SIZE_OF_SEARCHSPACE 200
#define REFRESH_HEADER_HEIGHT 52.0f
#define NUMBER_OF_BIBLE 66
#define NUMBER_OF_CHAPTER 1189
#define KJV_DOWNLOAD_URL @"http://hahaheo.iptime.org/kjvBibles/%@.kjv"
#define DEFAULT_BIBLE @"korHKJV"
#define SMALL_FONT_SIZE 10.0f
#define DEF_FONT_SIZE 15.0f
#define BIG_FONT_SIZE 23.0f
#define SMALL_FONT_GAP 3.0f
#define DEF_FONT_GAP 5.0f
#define BIG_FONT_GAP 10.0f
#define COLOR_REVERSED 0

@interface global_variable : NSObject
+(NSArray *)getShortedBookofBible;
+(NSArray *)getShortedEngBookofBible;
+(NSArray *)getNamedBookofBible;
+(NSArray *)getNumberofChapterinBook;
+(NSArray *)getGroupedNamedBookofBible;
+(NSDictionary *)getBibleNameConverter;
+(NSArray *)getDownloadableBibleName;
+(BOOL)checkConnectedToInternet;

@end
