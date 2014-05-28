//
//  lfbContainer.h
//  lfa viewer
//
//  Created by Chan Heo on 3/20/13.
//  Copyright (c) 2013 Chan Heo. All rights reserved.
//  Modified 2014/05/17 from Chan Heo

#import <Foundation/Foundation.h>
@interface lfbContainer : NSObject

+(NSMutableArray *)getWithBible:(NSString *)bible Book:(int)book Chapter:(int)chapter;
+(NSString *)getWithBibleVerse:(NSString *)bible Book:(int)book Chapter:(int)chapter Verse:(int)verse;
@end
