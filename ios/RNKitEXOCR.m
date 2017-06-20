//
//  RNKitEXOCR.m
//  RNKitEXOCR
//
//  Created by SimMan on 2017/5/8.
//  Copyright © 2017年 RNKit.io. All rights reserved.
//

#import "RNKitEXOCR.h"

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTConvert.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTRootView.h>
#else
#import "RCTConvert.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTEventDispatcher.h"
#import "RCTRootView.h"
#endif

#import <ExCardSDK/ExCardSDK.h>


#if __has_include(<ExBankCardSDK/ExBankCardSDK.h>)
#define HAS_BANK_CARD YES  // 银行卡
#endif

#if __has_include(<ExCardSDK/EXOCRDRCardRecoManager.h>)
#define HAS_DR_CARD YES // 驾驶证识别
#endif

#if __has_include(<ExCardSDK/EXOCRIDCardRecoManager.h>)
#define HAS_ID_CARD YES // 身份证识别
#endif

#if __has_include(<ExCardSDK/EXOCRVECardRecoManager.h>)
#define HAS_VE_CARD YES // 行驶证识别
#endif

#import "RNKitExcardUtils.h"

#define ERROR_CLEANUP_ERROR_KEY @"E_ERROR_WHILE_CLEANING_FILES"
#define ERROR_CLEANUP_ERROR_MSG @"Error while cleaning up tmp files"

static NSString * stringWithFormat(id obj)
{
    return [NSString stringWithFormat:@"%@", obj];
}

@implementation RCTConvert (UIInterfaceOrientationMask)
RCT_ENUM_CONVERTER(UIInterfaceOrientationMask, (@{
                                                  @"Portrait": @(UIInterfaceOrientationMaskPortrait),
                                                  @"LandscapeLeft": @(UIInterfaceOrientationMaskLandscapeLeft),
                                                  @"LandscapeRight": @(UIInterfaceOrientationMaskLandscapeRight),
                                                  @"PortraitUpsideDown": @(UIInterfaceOrientationMaskPortraitUpsideDown),
                                                  @"Landscape": @(UIInterfaceOrientationMaskLandscape),
                                                  @"MaskAll": @(UIInterfaceOrientationMaskAll),
                                                  @"AllButUpsideDown": @(UIInterfaceOrientationMaskAllButUpsideDown),
                                                  }), UIInterfaceOrientationMaskAll, integerValue)
@end

@interface RNKitEXOCR()

#ifdef HAS_BANK_CARD
@property (nonatomic, strong) EXOCRBankRecoManager *bankRecoManger;      // 银行卡
#endif
#ifdef HAS_DR_CARD
@property (nonatomic, strong) EXOCRDRCardRecoManager *drCardRecoManager; // 驾驶证
#endif
#ifdef HAS_ID_CARD
@property (nonatomic, strong) EXOCRIDCardRecoManager *idCardRecoManager; // 身份证
#endif
#ifdef HAS_VE_CARD
@property (nonatomic, strong) EXOCRVECardRecoManager *veCardRecoManager; // 行驶证
#endif

@property (nonatomic, strong) RNKitExcardUtils *excardUtils;
@property (nonatomic, retain) NSMutableDictionary *options;
@end

@implementation RNKitEXOCR

- (instancetype)init
{
    self = [super init];
    if (self) {
#if __has_include(<ExCardSDK/EXOCRCardEngineManager.h>)
        [EXOCRCardEngineManager initEngine];
#endif
    }
    return self;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(config:(NSDictionary *)args) {
    self.options = [NSMutableDictionary dictionaryWithDictionary:args];

#ifdef HAS_BANK_CARD
    if (args[@"OrientationMask"]) {
        // bankRecoManager only
        UIInterfaceOrientationMask orientationMask = [RCTConvert UIInterfaceOrientationMask:args[@"OrientationMask"]];
        [self.bankRecoManger setRecoSupportOrientations:orientationMask];
    }
#endif
    if (args[@"ByPresent"]) {
        BOOL bByPresent = [RCTConvert BOOL:args[@"ByPresent"]];
#ifdef HAS_BANK_CARD
        [self.bankRecoManger displayScanViewControllerByPresent:bByPresent];
#endif
#ifdef HAS_DR_CARD
        [self.drCardRecoManager displayScanViewControllerByPresent:bByPresent];
#endif
#ifdef HAS_ID_CARD
        [self.idCardRecoManager displayScanViewControllerByPresent:bByPresent];
#endif
#ifdef HAS_VE_CARD
        [self.veCardRecoManager displayScanViewControllerByPresent:bByPresent];
#endif
    }
    
    if (args[@"NumberOfSpace"]) {
#ifdef HAS_BANK_CARD
        // bankRecoManager only
        BOOL bSpace = [RCTConvert BOOL:args[@"NumberOfSpace"]];
        [self.bankRecoManger setSpaceWithBANKCardNum:bSpace];
#endif
    }
    
    if (args[@"DisplayLogo"]) {
        BOOL bDisplayLogo = [RCTConvert BOOL:args[@"DisplayLogo"]];
#ifdef HAS_BANK_CARD
        [self.bankRecoManger setDisplayLogo:bDisplayLogo];
#endif
#ifdef HAS_DR_CARD
        [self.drCardRecoManager setDisplayLogo:bDisplayLogo];
#endif
#ifdef HAS_ID_CARD
        [self.idCardRecoManager setDisplayLogo:bDisplayLogo];
#endif
#ifdef HAS_VE_CARD
        [self.veCardRecoManager setDisplayLogo:bDisplayLogo];
#endif
    }
    
    if (args[@"EnablePhotoRec"]) {
        BOOL bEnablePhotoRec = [RCTConvert BOOL:args[@"EnablePhotoRec"]];
#ifdef HAS_BANK_CARD
        [self.bankRecoManger setEnablePhotoRec:bEnablePhotoRec];
#endif
#ifdef HAS_DR_CARD
        [self.drCardRecoManager setEnablePhotoRec:bEnablePhotoRec];
#endif
#ifdef HAS_ID_CARD
        [self.idCardRecoManager setEnablePhotoRec:bEnablePhotoRec];
#endif
#ifdef HAS_VE_CARD
        [self.veCardRecoManager setEnablePhotoRec:bEnablePhotoRec];
#endif
    }
    
    if (args[@"FrameColor"] && args[@"FrameAlpha"]) {
        NSInteger frameColor = [RCTConvert NSInteger:args[@"FrameColor"]];
        CGFloat frameAlpha = [RCTConvert CGFloat:args[@"FrameAlpha"]];
        
#ifdef HAS_BANK_CARD
        [self.bankRecoManger setScanFrameColorRGB:frameColor andAlpha:frameAlpha];
#endif
#ifdef HAS_DR_CARD
        [self.drCardRecoManager setScanFrameColorRGB:frameColor andAlpha:frameAlpha];
#endif
#ifdef HAS_ID_CARD
        [self.idCardRecoManager setScanFrameColorRGB:frameColor andAlpha:frameAlpha];
#endif
#ifdef HAS_VE_CARD
        [self.veCardRecoManager setScanFrameColorRGB:frameColor andAlpha:frameAlpha];
#endif
    }
    
    if (args[@"ScanTextColor"]) {
        NSInteger ScanTextColor = [RCTConvert NSInteger:args[@"ScanTextColor"]];
#ifdef HAS_BANK_CARD
        [self.bankRecoManger setScanTextColorRGB:ScanTextColor];
#endif
#ifdef HAS_DR_CARD
        [self.drCardRecoManager setScanTextColorRGB:ScanTextColor];
#endif
#ifdef HAS_VE_CARD
        [self.veCardRecoManager setScanTextColorRGB:ScanTextColor];
#endif
    }
    
    if (args[@"IDCardScanNormalTextColor"]) {
        NSInteger ScanTextColor = [RCTConvert NSInteger:args[@"IDCardScanNormalTextColor"]];
#ifdef HAS_ID_CARD
        [self.idCardRecoManager setScanNormalTextColorRGB:ScanTextColor];
#endif
    }
    
    if (args[@"IDCardScanErrorTextColor"]) {
        NSInteger ScanTextColor = [RCTConvert NSInteger:args[@"IDCardScanErrorTextColor"]];
#ifdef HAS_ID_CARD
        [self.idCardRecoManager setScanErrorTextColorRGB:ScanTextColor];
#endif
    }
    
    // 提示文字, 分开处理
    // 银行卡
    if (args[@"BankScanTips"]) {
#ifdef HAS_BANK_CARD
        NSString *ScanTips = [RCTConvert NSString:args[@"ScanTips"]];
        [self.bankRecoManger setScanTips:ScanTips];
#endif
    }
    
    // 驾驶证
    if (args[@"DRCardScanTips"]) {
#ifdef HAS_DR_CARD
        NSString *ScanTips = [RCTConvert NSString:args[@"DRCardScanTips"]];
        [self.drCardRecoManager setScanTips:ScanTips];
#endif
    }
    
#ifdef HAS_BANK_CARD
    // 身份证 正面 正常
    if (args[@"IDCardScanFrontNormalTips"]) {
        NSString *ScanTips = [RCTConvert NSString:args[@"IDCardScanFrontNormalTips"]];
        [self.idCardRecoManager setScanFrontNormalTips:ScanTips];
    }
    
    // 身份证 正面 错误
    if (args[@"IDCardScanFrontErrorTips"]) {
        NSString *ScanTips = [RCTConvert NSString:args[@"IDCardScanFrontErrorTips"]];
        [self.idCardRecoManager setScanFrontErrorTips:ScanTips];
    }
    
    // 身份证 正面 正常
    if (args[@"IDCardScanBackNormalTips"]) {
        NSString *ScanTips = [RCTConvert NSString:args[@"IDCardScanBackNormalTips"]];
        [self.idCardRecoManager setScanBackNormalTips:ScanTips];
    }
    
    // 身份证 正面 错误
    if (args[@"IDCardScanBackErrorTips"]) {
        NSString *ScanTips = [RCTConvert NSString:args[@"IDCardScanBackErrorTips"]];
        [self.idCardRecoManager setScanBackErrorTips:ScanTips];
    }

    // 身份证 正常状态
    if (args[@"IDCardNormalFontName"] && args[@"IDCardNormalFontSize"]) {
        NSString *fontName = [RCTConvert NSString:args[@"IDCardNormalFontName"]];
        CGFloat scanTipsSize = [RCTConvert CGFloat:args[@"IDCardNormalFontSize"]];
        [self.idCardRecoManager setScanNormalTipsFontName:fontName andFontSize:scanTipsSize];
    }
    
    // 身份证 错误状态
    if (args[@"IDCardErrorFontName"] && args[@"IDCardErrorFontSize"]) {
        NSString *fontName = [RCTConvert NSString:args[@"IDCardErrorFontName"]];
        CGFloat scanTipsSize = [RCTConvert CGFloat:args[@"IDCardErrorFontSize"]];
        [self.idCardRecoManager setScanErrorTipsFontName:fontName andFontSize:scanTipsSize];
    }
#endif
    
#ifdef HAS_VE_CARD
    // 行驶证
    if (args[@"VECardScanTips"]) {
        NSString *ScanTips = [RCTConvert NSString:args[@"VECardScanTips"]];
        [self.veCardRecoManager setScanTips:ScanTips];
    }
#endif
    
    if (args[@"fontName"] && args[@"ScanTipsFontSize"]) {
        NSString *fontName = [RCTConvert NSString:args[@"fontName"]];
        CGFloat scanTipsSize = [RCTConvert CGFloat:args[@"ScanTipsFontSize"]];
#ifdef HAS_BANK_CARD
        [self.bankRecoManger setScanTipsFontName:fontName andFontSize:scanTipsSize];
#endif
#ifdef HAS_DR_CARD
        [self.drCardRecoManager setScanTipsFontName:fontName andFontSize:scanTipsSize];
#endif
#ifdef HAS_VE_CARD
        [self.veCardRecoManager setScanTipsFontName:fontName andFontSize:scanTipsSize];
#endif
    }
}

#pragma mark - 银行卡
RCT_EXPORT_METHOD(recoBankFromStream:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
#ifdef HAS_BANK_CARD
    __weak __typeof(self) weakSelf = self;
    [self.bankRecoManger recoBankFromStreamOnCompleted:^(int statusCode, EXOCRBankCardInfo *bankInfo) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        NSString *fullImgPath = [strongSelf.excardUtils saveImage:bankInfo.fullImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        NSString *cardNumImgPath = [strongSelf.excardUtils saveImage:bankInfo.cardNumImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        
        resolve(@{
                  @"bankName": stringWithFormat(bankInfo.bankName),
                  @"cardName": stringWithFormat(bankInfo.cardName),
                  @"cardType": stringWithFormat(bankInfo.cardType),
                  @"cardNum": stringWithFormat(bankInfo.cardNum),
                  @"validDate": stringWithFormat(bankInfo.validDate),
                  @"fullImgPath": stringWithFormat(fullImgPath),
                  @"cardNumImgPath": stringWithFormat(cardNumImgPath)
                  });
    } OnCanceled:^(int statusCode) {
        NSLog(@"OnCanceled: %d", statusCode);
        reject(@"-1", @"OnCanceled", nil);
    } OnFailed:^(int statusCode, UIImage *recoImg) {
        NSLog(@"OnFailed: %d", statusCode);
        reject([NSString stringWithFormat:@"%d", statusCode], @"OnFailed", nil);
    }];
#else
    reject(@"0", @"OnFailed", nil);
#endif
}

RCT_EXPORT_METHOD(recoBankFromStillImage:(NSString *)src
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
#ifdef HAS_BANK_CARD
    UIImage *img = [RCTConvert UIImage:src];
    
    if (!img) {
        reject([NSString stringWithFormat:@"%d", -2], @"invalid image source", nil);
    }
    
    __weak __typeof(self) weakSelf = self;
    [self.bankRecoManger recoBankFromStillImage:img OnCompleted:^(int statusCode, EXOCRBankCardInfo *bankInfo) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        NSString *fullImgPath = [strongSelf.excardUtils saveImage:bankInfo.fullImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        NSString *cardNumImgPath = [strongSelf.excardUtils saveImage:bankInfo.cardNumImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        
        
        resolve(@{
                  @"bankName": stringWithFormat(bankInfo.bankName),
                  @"cardName": stringWithFormat(bankInfo.cardName),
                  @"cardType": stringWithFormat(bankInfo.cardType),
                  @"cardNum": stringWithFormat(bankInfo.cardNum),
                  @"validDate": stringWithFormat(bankInfo.validDate),
                  @"fullImgPath": stringWithFormat(fullImgPath),
                  @"cardNumImgPath": stringWithFormat(cardNumImgPath)
                  });
    } OnFailed:^(int statusCode, UIImage *recoImg) {
        NSLog(@"OnFailed: %d", statusCode);
        reject([NSString stringWithFormat:@"%d", statusCode], @"OnFailed", nil);
    }];
#else
    reject(@"0", @"OnFailed", nil);
#endif
}

#pragma mark - 驾驶证
RCT_EXPORT_METHOD(recoDRCardFromStream:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
#ifdef HAS_DR_CARD
    __weak __typeof(self) weakSelf = self;
    [self.drCardRecoManager recoDRCardFromStreamOnCompleted:^(int statusCode, EXOCRDRCardInfo *drInfo) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        NSString *fullImgPath = [strongSelf.excardUtils saveImage:drInfo.fullImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        
        resolve(@{
                  @"name": stringWithFormat(drInfo.name),
                  @"sex": stringWithFormat(drInfo.sex),
                  @"nation": stringWithFormat(drInfo.nation),
                  @"cardId": stringWithFormat(drInfo.cardId),
                  @"address": stringWithFormat(drInfo.address),
                  @"birth": stringWithFormat(drInfo.birth),
                  @"issueDate": stringWithFormat(drInfo.issueDate),
                  @"driveType": stringWithFormat(drInfo.driveType),
                  @"validDate": stringWithFormat(drInfo.validDate),
                  @"fullImgPath": stringWithFormat(fullImgPath)
                  });
    } OnCanceled:^(int statusCode) {
        NSLog(@"OnCanceled: %d", statusCode);
        reject(@"-1", @"OnCanceled", nil);
    } OnFailed:^(int statusCode, UIImage *recoImg) {
        NSLog(@"OnFailed: %d", statusCode);
        reject([NSString stringWithFormat:@"%d", statusCode], @"OnFailed", nil);
    }];
#else
    reject(@"0", @"OnFailed", nil);
#endif
}

RCT_EXPORT_METHOD(recoDRCardFromStillImage:(NSString *)src
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
#ifdef HAS_DR_CARD
    UIImage *img = [RCTConvert UIImage:src];
    
    if (!img) {
        reject([NSString stringWithFormat:@"%d", -2], @"invalid image source", nil);
    }
    
    __weak __typeof(self) weakSelf = self;
    [self.drCardRecoManager recoDRCardFromStillImage:img OnCompleted:^(int statusCode, EXOCRDRCardInfo *drInfo) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        NSString *fullImgPath = [strongSelf.excardUtils saveImage:drInfo.fullImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        
        resolve(@{
                  @"name": stringWithFormat(drInfo.name),
                  @"sex": stringWithFormat(drInfo.sex),
                  @"nation": stringWithFormat(drInfo.nation),
                  @"cardId": stringWithFormat(drInfo.cardId),
                  @"address": stringWithFormat(drInfo.address),
                  @"birth": stringWithFormat(drInfo.birth),
                  @"issueDate": stringWithFormat(drInfo.issueDate),
                  @"driveType": stringWithFormat(drInfo.driveType),
                  @"validDate": stringWithFormat(drInfo.validDate),
                  @"fullImgPath": stringWithFormat(fullImgPath)
                  });
    } OnFailed:^(int statusCode, UIImage *recoImg) {
        NSLog(@"OnFailed: %d", statusCode);
        reject([NSString stringWithFormat:@"%d", statusCode], @"OnFailed", nil);
    }];
#else
    reject(@"0", @"OnFailed", nil);
#endif
}

#pragma mark - 身份证
RCT_EXPORT_METHOD(recoIDCardFromStreamWithSide:(BOOL)bFront
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
#ifdef HAS_ID_CARD
    __weak __typeof(self) weakSelf = self;
    
    [self.idCardRecoManager recoIDCardFromStreamWithSide:bFront OnCompleted:^(int statusCode, EXOCRIDCardInfo *idInfo) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        NSString *faceImgPath = [strongSelf.excardUtils saveImage:idInfo.faceImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        NSString *frontFullImg = [strongSelf.excardUtils saveImage:idInfo.frontFullImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        NSString *backFullImg = [strongSelf.excardUtils saveImage:idInfo.backFullImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        
        resolve(
                @{@"type": stringWithFormat(@(idInfo.type)),
                  @"name": stringWithFormat(idInfo.name),
                  @"gender": stringWithFormat(idInfo.gender),
                  @"nation": stringWithFormat(idInfo.nation),
                  @"birth": stringWithFormat(idInfo.birth),
                  @"address": stringWithFormat(idInfo.address),
                  @"code": stringWithFormat(idInfo.code),
                  @"issue": stringWithFormat(idInfo.issue),
                  @"valid": stringWithFormat(idInfo.valid),
                  @"frontShadow": stringWithFormat(@(idInfo.frontShadow)),
                  @"backShadow": stringWithFormat(@(idInfo.backShadow)),
                  @"faceImgPath": stringWithFormat(faceImgPath),
                  @"frontFullImgPath": stringWithFormat(frontFullImg),
                  @"backFullImgPath": stringWithFormat(backFullImg)
                  });
    } OnCanceled:^(int statusCode) {
        NSLog(@"OnCanceled: %d", statusCode);
        reject(@"-1", @"OnCanceled", nil);
    } OnFailed:^(int statusCode, UIImage *recoImg) {
        NSLog(@"OnFailed: %d", statusCode);
        reject([NSString stringWithFormat:@"%d", statusCode], @"OnFailed", nil);
    }];
#else
    reject(@"0", @"OnFailed", nil);
#endif
}

RCT_EXPORT_METHOD(recoIDCardFromStillImage:(NSString *)src
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
#ifdef HAS_ID_CARD
    UIImage *img = [RCTConvert UIImage:src];
    
    if (!img) {
        reject([NSString stringWithFormat:@"%d", -2], @"invalid image source", nil);
    }
    
    __weak __typeof(self) weakSelf = self;
    [self.idCardRecoManager recoIDCardFromStillImage:img OnCompleted:^(int statusCode, EXOCRIDCardInfo *idInfo) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        NSString *faceImgPath = [strongSelf.excardUtils saveImage:idInfo.faceImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        NSString *frontFullImg = [strongSelf.excardUtils saveImage:idInfo.frontFullImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        NSString *backFullImg = [strongSelf.excardUtils saveImage:idInfo.backFullImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        
        resolve(
                @{@"type": stringWithFormat(@(idInfo.type)),
                  @"name": stringWithFormat(idInfo.name),
                  @"gender": stringWithFormat(idInfo.gender),
                  @"nation": stringWithFormat(idInfo.nation),
                  @"birth": stringWithFormat(idInfo.birth),
                  @"address": stringWithFormat(idInfo.address),
                  @"code": stringWithFormat(idInfo.code),
                  @"issue": stringWithFormat(idInfo.issue),
                  @"valid": stringWithFormat(idInfo.valid),
                  @"frontShadow": stringWithFormat(@(idInfo.frontShadow)),
                  @"backShadow": stringWithFormat(@(idInfo.backShadow)),
                  @"faceImgPath": stringWithFormat(faceImgPath),
                  @"frontFullImgPath": stringWithFormat(frontFullImg),
                  @"backFullImgPath": stringWithFormat(backFullImg)
                  });
    } OnFailed:^(int statusCode, UIImage *recoImg) {
        NSLog(@"OnFailed: %d", statusCode);
        reject([NSString stringWithFormat:@"%d", statusCode], @"OnFailed", nil);
    }];
#else
    reject(@"0", @"OnFailed", nil);
#endif
}

#pragma mark - 行驶证
RCT_EXPORT_METHOD(recoVECardFromStream:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
#ifdef HAS_VE_CARD
    __weak __typeof(self) weakSelf = self;
    
    [self.veCardRecoManager recoVECardFromStreamOnCompleted:^(int statusCode, EXOCRVECardInfo *veInfo) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        NSString *fullImgPath = [strongSelf.excardUtils saveImage:veInfo.fullImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        resolve(
                @{@"plateNo": stringWithFormat(veInfo.plateNo),
                  @"vehicleType": stringWithFormat(veInfo.vehicleType),
                  @"owner": stringWithFormat(veInfo.owner),
                  @"address": stringWithFormat(veInfo.address),
                  @"model": stringWithFormat(veInfo.model),
                  @"useCharacter": stringWithFormat(veInfo.useCharacter),
                  @"engineNo": stringWithFormat(veInfo.engineNo),
                  @"VIN": stringWithFormat(veInfo.VIN),
                  @"registerDate": stringWithFormat(veInfo.registerDate),
                  @"issueDate": stringWithFormat(veInfo.issueDate),
                  @"fullImgPath": stringWithFormat(fullImgPath)
                  });
    } OnCanceled:^(int statusCode) {
        NSLog(@"OnCanceled: %d", statusCode);
        reject(@"-1", @"OnCanceled", nil);
    } OnFailed:^(int statusCode, UIImage *recoImg) {
        NSLog(@"OnFailed: %d", statusCode);
        reject([NSString stringWithFormat:@"%d", statusCode], @"OnFailed", nil);
    }];
#else
    reject(@"0", @"OnFailed", nil);
#endif
}

RCT_EXPORT_METHOD(recoVECardFromStillImage:(NSString *)src
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
#ifdef HAS_VE_CARD
    UIImage *img = [RCTConvert UIImage:src];
    
    if (!img) {
        reject([NSString stringWithFormat:@"%d", -2], @"invalid image source", nil);
    }
    
    __weak __typeof(self) weakSelf = self;
    [self.veCardRecoManager recoVECardFromStillImage:img OnCompleted:^(int statusCode, EXOCRVECardInfo *veInfo) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        NSString *fullImgPath = [strongSelf.excardUtils saveImage:veInfo.fullImg quality:[RCTConvert CGFloat:self.options[@"quality"]]];
        resolve(
                @{@"plateNo": stringWithFormat(veInfo.plateNo),
                  @"vehicleType": stringWithFormat(veInfo.vehicleType),
                  @"owner": stringWithFormat(veInfo.owner),
                  @"address": stringWithFormat(veInfo.address),
                  @"model": stringWithFormat(veInfo.model),
                  @"useCharacter": stringWithFormat(veInfo.useCharacter),
                  @"engineNo": stringWithFormat(veInfo.engineNo),
                  @"VIN": stringWithFormat(veInfo.VIN),
                  @"registerDate": stringWithFormat(veInfo.registerDate),
                  @"issueDate": stringWithFormat(veInfo.issueDate),
                  @"fullImgPath": stringWithFormat(fullImgPath)
                  });
    } OnFailed:^(int statusCode, UIImage *recoImg) {
        NSLog(@"OnFailed: %d", statusCode);
        reject([NSString stringWithFormat:@"%d", statusCode], @"OnFailed", nil);
    }];
#else
    reject(@"0", @"OnFailed", nil);
#endif
}

#pragma mark constants
- (NSDictionary *)constantsToExport
{
#if __has_include(<ExCardSDK/EXOCRCardEngineManager.h>)
    return @{
             @"sdkVersion": EXOCRCardEngineManager.getSDKVersion,
             @"kernelVersion": EXOCRCardEngineManager.getKernelVersion
             };
#endif
    return @{
             @"sdkVersion": @"0.0.0",
             @"kernelVersion": @"0.0.0"
             };
    
}

RCT_REMAP_METHOD(clean, resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    if (![self.excardUtils cleanTmpDirectory]) {
        reject(ERROR_CLEANUP_ERROR_KEY, ERROR_CLEANUP_ERROR_MSG, nil);
    } else {
        resolve(nil);
    }
}

#pragma mark getter
#ifdef HAS_BANK_CARD
- (EXOCRBankRecoManager *) bankRecoManger {
    if (!_bankRecoManger) {
        UIViewController *presentingController = RCTPresentedViewController();
        if (presentingController == nil) {
            RCTLogError(@"Tried to display view but there is no application window.");
        }
        _bankRecoManger = [EXOCRBankRecoManager sharedManager:presentingController];
    }
    return _bankRecoManger;
}
#endif

#ifdef HAS_DR_CARD
- (EXOCRDRCardRecoManager *)drCardRecoManager
{
    if (!_drCardRecoManager) {
        UIViewController *presentingController = RCTPresentedViewController();
        if (presentingController == nil) {
            RCTLogError(@"Tried to display view but there is no application window.");
        }
        _drCardRecoManager = [EXOCRDRCardRecoManager sharedManager:presentingController];
    }
    return _drCardRecoManager;
}
#endif

#ifdef HAS_ID_CARD
- (EXOCRIDCardRecoManager *)idCardRecoManager
{
    if (!_idCardRecoManager) {
        UIViewController *presentingController = RCTPresentedViewController();
        if (presentingController == nil) {
            RCTLogError(@"Tried to display view but there is no application window.");
        }
        _idCardRecoManager = [EXOCRIDCardRecoManager sharedManager:presentingController];
    }
    return _idCardRecoManager;
}
#endif

#ifdef HAS_VE_CARD
-(EXOCRVECardRecoManager *)veCardRecoManager
{
    if (!_veCardRecoManager) {
        UIViewController *presentingController = RCTPresentedViewController();
        if (presentingController == nil) {
            RCTLogError(@"Tried to display view but there is no application window.");
        }
        _veCardRecoManager = [EXOCRVECardRecoManager sharedManager:presentingController];
    }
    return _veCardRecoManager;
}
#endif

- (RNKitExcardUtils *)excardUtils
{
    if (!_excardUtils) {
        _excardUtils = [RNKitExcardUtils new];
    }
    return _excardUtils;
}

@end
