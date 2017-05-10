//
//  RNKitEXOCR.h
//  RNKitEXOCR
//
//  Created by SimMan on 2017/5/8.
//  Copyright © 2017年 RNKit.io. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridgeModule.h>
#else
#import "RCTBridgeModule.h"
#endif

@interface RNKitEXOCR : NSObject <RCTBridgeModule>

@end
