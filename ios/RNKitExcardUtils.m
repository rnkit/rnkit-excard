//
//  RNKitExcardUtils.m
//  RNKitExcardUtils
//
//  Created by SimMan on 2017/5/8.
//  Copyright © 2017年 RNKit.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNKitExcardUtils.h"

@interface RNKitExcardUtils() {
    dispatch_queue_t _opQueue;
}

@end

@implementation RNKitExcardUtils

- (instancetype)init
{
    self = [super init];
    if (self) {
        _opQueue = dispatch_queue_create("io.rnkit.excard", DISPATCH_QUEUE_SERIAL);
        [self createDir: [self getTmpDirectory]];
    }
    return self;
}

- (NSString*) getTmpDirectory
{
    NSString *tmpFullPath = [NSTemporaryDirectory() stringByAppendingString:TMP_DIRECTORY];
    
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:tmpFullPath isDirectory:&isDir];
    if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath: tmpFullPath
                                  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return tmpFullPath;
}

- (BOOL)cleanTmpDirectory
{
    NSString* tmpDirectoryPath = [self getTmpDirectory];
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tmpDirectoryPath error:NULL];
    
    for (NSString *file in tmpDirectory) {
        BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", tmpDirectoryPath, file] error:NULL];
        
        if (!deleted) {
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)saveImage:(UIImage *)image quality:(CGFloat)quality
{
    quality = quality ? quality : 0.8;
    NSString *path = [NSString stringWithFormat:@"%@/%0f.jpg", [self getTmpDirectory], [[NSDate date] timeIntervalSince1970]];
    [UIImageJPEGRepresentation(image, quality) writeToFile:path atomically:YES];
    return path;
}

- (BOOL)createDir:(NSString *)dir
{
    __block BOOL success = false;
    
    dispatch_sync(_opQueue, ^{
        BOOL isDir;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:dir isDirectory:&isDir]) {
            if (isDir) {
                success = true;
                return;
            }
        }
        
        NSError *error;
        [fileManager createDirectoryAtPath:dir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
        if (!error) {
            success = true;
            return;
        }
    });
    
    return success;
}

@end
