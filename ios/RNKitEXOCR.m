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
#import <ExBankCardSDK/ExBankCardSDK.h>
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
@property (nonatomic, strong) EXOCRBankRecoManager *bankRecoManger;      // 银行卡
@property (nonatomic, strong) EXOCRDRCardRecoManager *drCardRecoManager; // 驾驶证
@property (nonatomic, strong) EXOCRIDCardRecoManager *idCardRecoManager; // 身份证
@property (nonatomic, strong) EXOCRVECardRecoManager *veCardRecoManager; // 行驶证
@property (nonatomic, strong) RNKitExcardUtils *excardUtils;
@property (nonatomic, retain) NSMutableDictionary *options;
@end

@implementation RNKitEXOCR

- (instancetype)init
{
    self = [super init];
    if (self) {
        [EXOCRCardEngineManager initEngine];
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
    
    if (args[@"OrientationMask"]) {
        // bankRecoManager only
        UIInterfaceOrientationMask orientationMask = [RCTConvert UIInterfaceOrientationMask:args[@"OrientationMask"]];
        [self.bankRecoManger setRecoSupportOrientations:orientationMask];
    }
    
    if (args[@"ByPresent"]) {
        BOOL bByPresent = [RCTConvert BOOL:args[@"ByPresent"]];
        [self.bankRecoManger displayScanViewControllerByPresent:bByPresent];
        [self.drCardRecoManager displayScanViewControllerByPresent:bByPresent];
        [self.idCardRecoManager displayScanViewControllerByPresent:bByPresent];
        [self.veCardRecoManager displayScanViewControllerByPresent:bByPresent];
    }
    
    if (args[@"NumberOfSpace"]) {
        // bankRecoManager only
        BOOL bSpace = [RCTConvert BOOL:args[@"NumberOfSpace"]];
        [self.bankRecoManger setSpaceWithBANKCardNum:bSpace];
    }
    
    if (args[@"DisplayLogo"]) {
        BOOL bDisplayLogo = [RCTConvert BOOL:args[@"DisplayLogo"]];
        [self.bankRecoManger setDisplayLogo:bDisplayLogo];
        [self.drCardRecoManager setDisplayLogo:bDisplayLogo];
        [self.idCardRecoManager setDisplayLogo:bDisplayLogo];
        [self.veCardRecoManager setDisplayLogo:bDisplayLogo];
    }
    
    if (args[@"EnablePhotoRec"]) {
        BOOL bEnablePhotoRec = [RCTConvert BOOL:args[@"EnablePhotoRec"]];
        [self.bankRecoManger setEnablePhotoRec:bEnablePhotoRec];
        [self.drCardRecoManager setEnablePhotoRec:bEnablePhotoRec];
        [self.idCardRecoManager setEnablePhotoRec:bEnablePhotoRec];
        [self.veCardRecoManager setEnablePhotoRec:bEnablePhotoRec];
    }
    
    if (args[@"FrameColor"] && args[@"FrameAlpha"]) {
        NSInteger frameColor = [RCTConvert NSInteger:args[@"FrameColor"]];
        CGFloat frameAlpha = [RCTConvert CGFloat:args[@"FrameAlpha"]];
        [self.bankRecoManger setScanFrameColorRGB:frameColor andAlpha:frameAlpha];
        [self.drCardRecoManager setScanFrameColorRGB:frameColor andAlpha:frameAlpha];
        [self.idCardRecoManager setScanFrameColorRGB:frameColor andAlpha:frameAlpha];
        [self.veCardRecoManager setScanFrameColorRGB:frameColor andAlpha:frameAlpha];
    }
    
    if (args[@"ScanTextColor"]) {
        NSInteger ScanTextColor = [RCTConvert NSInteger:args[@"ScanTextColor"]];
        [self.bankRecoManger setScanTextColorRGB:ScanTextColor];
        [self.drCardRecoManager setScanTextColorRGB:ScanTextColor];
        [self.veCardRecoManager setScanTextColorRGB:ScanTextColor];
    }
    
    if (args[@"IDCardScanNormalTextColor"]) {
        NSInteger ScanTextColor = [RCTConvert NSInteger:args[@"IDCardScanNormalTextColor"]];
        [self.idCardRecoManager setScanNormalTextColorRGB:ScanTextColor];
    }
    
    if (args[@"IDCardScanErrorTextColor"]) {
        NSInteger ScanTextColor = [RCTConvert NSInteger:args[@"IDCardScanErrorTextColor"]];
        [self.idCardRecoManager setScanErrorTextColorRGB:ScanTextColor];
    }
    
    // 提示文字, 分开处理
    // 银行卡
    if (args[@"BankScanTips"]) {
        NSString *ScanTips = [RCTConvert NSString:args[@"ScanTips"]];
        [self.bankRecoManger setScanTips:ScanTips];
    }
    
    // 驾驶证
    if (args[@"DRCardScanTips"]) {
        NSString *ScanTips = [RCTConvert NSString:args[@"DRCardScanTips"]];
        [self.drCardRecoManager setScanTips:ScanTips];
    }
    
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
    
    // 行驶证
    if (args[@"VECardScanTips"]) {
        NSString *ScanTips = [RCTConvert NSString:args[@"VECardScanTips"]];
        [self.veCardRecoManager setScanTips:ScanTips];
    }
    
    if (args[@"fontName"] && args[@"ScanTipsFontSize"]) {
        NSString *fontName = [RCTConvert NSString:args[@"fontName"]];
        CGFloat scanTipsSize = [RCTConvert CGFloat:args[@"ScanTipsFontSize"]];
        [self.bankRecoManger setScanTipsFontName:fontName andFontSize:scanTipsSize];
        [self.drCardRecoManager setScanTipsFontName:fontName andFontSize:scanTipsSize];
        [self.veCardRecoManager setScanTipsFontName:fontName andFontSize:scanTipsSize];
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
}

#pragma mark - 银行卡
RCT_EXPORT_METHOD(recoBankFromStream:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
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
}

RCT_EXPORT_METHOD(recoBankFromStillImage:(NSString *)src
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
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
}

#pragma mark - 驾驶证
RCT_EXPORT_METHOD(recoDRCardFromStream:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
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
}

RCT_EXPORT_METHOD(recoDRCardFromStillImage:(NSString *)src
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
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
}

#pragma mark - 身份证
RCT_EXPORT_METHOD(recoIDCardFromStreamWithSide:(BOOL)bFront
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
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
}

RCT_EXPORT_METHOD(recoIDCardFromStillImage:(NSString *)src
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
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
}

#pragma mark - 行驶证
RCT_EXPORT_METHOD(recoVECardFromStream:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
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
}

RCT_EXPORT_METHOD(recoVECardFromStillImage:(NSString *)src
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
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
}

#pragma mark constants
- (NSDictionary *)constantsToExport
{
    return @{
             @"sdkVersion": EXOCRCardEngineManager.getSDKVersion,
             @"kernelVersion": EXOCRCardEngineManager.getKernelVersion
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

- (RNKitExcardUtils *)excardUtils
{
    if (!_excardUtils) {
        _excardUtils = [RNKitExcardUtils new];
    }
    return _excardUtils;
}

@end
