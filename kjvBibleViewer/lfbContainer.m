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
            NSArray *sBookName = [[global_variable getShortedBookofBible] objectAtIndex:(book-1)];
            //lfb 파일의 모든 내용을 하나의 String으로 받아옴
            NSString *temp = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            
            // 앞에 01창을 자름으로써 형태를 잡는다
            f_return = [[temp componentsSeparatedByString:[NSString stringWithFormat:@"%02d%@ ", book, sBookName]] mutableCopy];
            
            //if(f_return.count < 2)
            //    f_return = [temp componentsSeparatedByString:[NSString stringWithFormat:@"%02d%@ ", book, sBookName]];
            
            // 맨앞에 필요없는 01창 지움
            [f_return removeObjectAtIndex:0];
            
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
@end
