//
//  RNKitExcardUtils.h
//  RNKitExcardUtils
//
//  Created by SimMan on 2017/5/8.
//  Copyright © 2017年 RNKit.io. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const TMP_DIRECTORY = @"rnkit-excard/";

@interface RNKitExcardUtils : NSObject

- (NSString*) getTmpDirectory;
- (BOOL)cleanTmpDirectory;
- (BOOL)createDir:(NSString *)dir;
- (NSString *)saveImage:(UIImage *)image quality:(CGFloat)quality;
@end
