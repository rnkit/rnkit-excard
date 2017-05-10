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
#else
#import "RCTConvert.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTEventDispatcher.h"
#endif

#import <ExCardSDK/ExCardSDK.h>
#import <ExBankCardSDK/ExBankCardSDK.h>
#import "RNKitExcardUtils.h"

#define ERROR_CLEANUP_ERROR_KEY @"E_ERROR_WHILE_CLEANING_FILES"
#define ERROR_CLEANUP_ERROR_MSG @"Error while cleaning up tmp files"

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
        
        resolve(@[
                  @{@"bankName": bankInfo.bankName},
                  @{@"cardName": bankInfo.cardName},
                  @{@"cardType": bankInfo.cardType},
                  @{@"cardNum": bankInfo.cardNum},
                  @{@"validDate": bankInfo.validDate},
                  @{@"fullImgPath": fullImgPath},
                  @{@"cardNumImgPath": cardNumImgPath},
                  ]);
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
        
        resolve(@[
                  @{@"bankName": bankInfo.bankName},
                  @{@"cardName": bankInfo.cardName},
                  @{@"cardType": bankInfo.cardType},
                  @{@"cardNum": bankInfo.cardNum},
                  @{@"validDate": bankInfo.validDate},
                  @{@"fullImgPath": fullImgPath},
                  @{@"cardNumImgPath": cardNumImgPath},
                  ]);
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
        
        resolve(@[
                  @{@"name": drInfo.name},
                  @{@"sex": drInfo.sex},
                  @{@"nation": drInfo.nation},
                  @{@"cardId": drInfo.cardId},
                  @{@"address": drInfo.address},
                  @{@"birth": drInfo.birth},
                  @{@"issueDate": drInfo.issueDate},
                  @{@"driveType": drInfo.driveType},
                  @{@"validDate": drInfo.validDate},
                  @{@"fullImgPath": fullImgPath}
                  ]);
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
        
        resolve(@[
                  @{@"name": drInfo.name},
                  @{@"sex": drInfo.sex},
                  @{@"nation": drInfo.nation},
                  @{@"cardId": drInfo.cardId},
                  @{@"address": drInfo.address},
                  @{@"birth": drInfo.birth},
                  @{@"issueDate": drInfo.issueDate},
                  @{@"driveType": drInfo.driveType},
                  @{@"validDate": drInfo.validDate},
                  @{@"fullImgPath": fullImgPath}
                  ]);
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
        
        resolve(@[
                  @{@"type": @(idInfo.type)},
                  @{@"name": idInfo.name},
                  @{@"gender": idInfo.gender},
                  @{@"nation": idInfo.nation},
                  @{@"birth": idInfo.birth},
                  @{@"address": idInfo.address},
                  @{@"code": idInfo.code},
                  @{@"issue": idInfo.issue},
                  @{@"valid": idInfo.valid},
                  @{@"frontShadow": @(idInfo.frontShadow)},
                  @{@"backShadow": @(idInfo.backShadow)},
                  @{@"faceImgPath": faceImgPath},
                  @{@"frontFullImgPath": frontFullImg},
                  @{@"backFullImgPath": backFullImg}
                  ]);
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
        
        resolve(@[
                  @{@"type": @(idInfo.type)},
                  @{@"name": idInfo.name},
                  @{@"gender": idInfo.gender},
                  @{@"nation": idInfo.nation},
                  @{@"birth": idInfo.birth},
                  @{@"address": idInfo.address},
                  @{@"code": idInfo.code},
                  @{@"issue": idInfo.issue},
                  @{@"valid": idInfo.valid},
                  @{@"frontShadow": @(idInfo.frontShadow)},
                  @{@"backShadow": @(idInfo.backShadow)},
                  @{@"faceImgPath": faceImgPath},
                  @{@"frontFullImgPath": frontFullImg},
                  @{@"backFullImgPath": backFullImg}
                  ]);
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
        resolve(@[
                  @{@"plateNo": veInfo.plateNo},
                  @{@"vehicleType": veInfo.vehicleType},
                  @{@"owner": veInfo.owner},
                  @{@"address": veInfo.address},
                  @{@"model": veInfo.model},
                  @{@"useCharacter": veInfo.useCharacter},
                  @{@"engineNo": veInfo.engineNo},
                  @{@"VIN": veInfo.VIN},
                  @{@"registerDate": veInfo.registerDate},
                  @{@"issueDate": veInfo.issueDate},
                  @{@"fullImgPath": fullImgPath}
                  ]);
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
        resolve(@[
                  @{@"plateNo": veInfo.plateNo},
                  @{@"vehicleType": veInfo.vehicleType},
                  @{@"owner": veInfo.owner},
                  @{@"address": veInfo.address},
                  @{@"model": veInfo.model},
                  @{@"useCharacter": veInfo.useCharacter},
                  @{@"engineNo": veInfo.engineNo},
                  @{@"VIN": veInfo.VIN},
                  @{@"registerDate": veInfo.registerDate},
                  @{@"issueDate": veInfo.issueDate},
                  @{@"fullImgPath": fullImgPath}
                  ]);
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
            RCTLogError(@"Tried to display action sheet picker view but there is no application window.");
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
            RCTLogError(@"Tried to display action sheet picker view but there is no application window.");
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
            RCTLogError(@"Tried to display action sheet picker view but there is no application window.");
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
            RCTLogError(@"Tried to display action sheet picker view but there is no application window.");
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


- (void)dealloc
{
    [EXOCRCardEngineManager finishEngine];
}

@end
