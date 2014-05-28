//
//  lfbContainer.m
//  lfa viewer
//
//  Created by Chan Heo on 3/20/13.
//  Copyright (c) 2013 Chan Heo. All rights reserved.
//  Modified 2014/05/17 from Chan Heo

#import "lfbContainer.h"
#import "global_variable.h"
#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"

@implementation lfbContainer

+(NSMutableArray *)getWithBible:(NSString *)bible Book:(int)book Chapter:(int)chapter
{
    NSString *documentsDirectory = (NSString *)[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    ZipFile *unzipFile = [[ZipFile alloc] initWithFileName:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.kjv", bible]] mode:ZipFileModeUnzip];
    
    NSMutableArray *f_return; // 결과값 저장소
    NSArray *lists = [unzipFile listFileInZipInfos];
    for (FileInZipInfo *info in lists) {
        //NSLog(@"- %@ %@ %d (%d)", info.name, info.date, info.size, info.level);
        
        if([info.name isEqualToString:[NSString stringWithFormat:@"%@%02d_%d.lfb", bible, book, chapter]]) {
            //locate the file in the zip
            [unzipFile locateFileInZip:info.name];
            
            //expand the file in memory
            ZipReadStream *read = [unzipFile readCurrentFileInZip];
            NSMutableData *data = [[NSMutableData alloc] initWithLength:BUFFER_SIZE]; // !!TODO: 가변 buffer size require
            [read readDataWithBuffer:data];
            [read finishedReading];
            
            // 창,출,레..형태로 값 받아옴
            NSArray *sBookName;
            if([[global_variable getKoreanBookofBible] indexOfObject:bible] != NSNotFound) //한국어 역본이면
               sBookName = [[global_variable getShortedBookofBible] objectAtIndex:(book-1)];
            else // 그외 언어면
               sBookName = [[global_variable getShortedEngBookofBible] objectAtIndex:(book-1)];
               
            //lfb 파일의 모든 내용을 하나의 String으로 받아옴
            NSString *temp = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            
            // 앞에 \n01창 을 자름으로써 형태를 잡는다
            f_return = [[temp componentsSeparatedByString:[NSString stringWithFormat:@"\n%02d%@ ", book, sBookName]] mutableCopy];
            // 맨뒤 '/n' 지워줌
            NSString *first = [f_return objectAtIndex:0] ;
            NSString *last = [f_return objectAtIndex:[f_return count]-1];
            [f_return replaceObjectAtIndex:0 withObject:[first substringFromIndex:[[NSString stringWithFormat:@"%02d%@ ", book, sBookName] length]]];
            [f_return replaceObjectAtIndex:[f_return count]-1 withObject:[last substringToIndex:[last length] - 2]];
            
            //dealloc
            [data release];
            [read release];
            [sBookName release];
            [lists release];
            [unzipFile release];
            
            return f_return;
        }
    }
    [f_return addObject:@"ERROR: Not Found"];
    return f_return;
}

+(NSString *)getWithBibleVerse:(NSString *)bible Book:(int)book Chapter:(int)chapter Verse:(int)verse
{
    NSString *documentsDirectory = (NSString *)[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    ZipFile *unzipFile = [[ZipFile alloc] initWithFileName:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.kjv", bible]] mode:ZipFileModeUnzip];
    
    NSMutableArray *f_return;
    NSArray *lists = [unzipFile listFileInZipInfos];
    for (FileInZipInfo *info in lists) {
        //NSLog(@"- %@ %@ %d (%d)", info.name, info.date, info.size, info.level);
        
        if([info.name isEqualToString:[NSString stringWithFormat:@"%@%02d_%d.lfb", bible, book, chapter]]) {
            //locate the file in the zip
            [unzipFile locateFileInZip:info.name];
            
            //expand the file in memory
            ZipReadStream *read = [unzipFile readCurrentFileInZip];
            NSMutableData *data = [[NSMutableData alloc] initWithLength:BUFFER_SIZE]; // !!TODO: 가변 buffer size require
            [read readDataWithBuffer:data];
            [read finishedReading];
            
            // 창,출,레..형태로 값 받아옴
            NSArray *sBookName;
            if([[global_variable getKoreanBookofBible] indexOfObject:bible] != NSNotFound) //한국어 역본이면
                sBookName = [[global_variable getShortedBookofBible] objectAtIndex:(book-1)];
            else // 그외 언어면
                sBookName = [[global_variable getShortedEngBookofBible] objectAtIndex:(book-1)];
            
            //lfb 파일의 모든 내용을 하나의 String으로 받아옴
            NSString *temp = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            
            // 앞에 \n을 자름으로써 형태를 잡는다
            f_return = [[temp componentsSeparatedByString:[NSString stringWithFormat:@"%\n", book, sBookName]] mutableCopy];
            //[f_return removeObjectAtIndex:0];
            
            //dealloc
            [data release];
            [read release];
            [sBookName release];
            [lists release];
            [unzipFile release];
            
            //마지막절일 경우_를 붙혀준다
            if(verse == [f_return count])
                [f_return replaceObjectAtIndex:verse-1 withObject:[NSString stringWithFormat:@"%@%@", @"_", [f_return objectAtIndex:verse-1]]];
            
            // 순서대로니까 objectatindex로 풀어주자
            return [f_return objectAtIndex:verse - 1];
            
        }
    }

    return @"ERROR: Not Found";
}
@end
