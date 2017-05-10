
package io.rnkit.excard;

import android.app.Activity;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import exocr.bankcard.BankManager;
import exocr.bankcard.EXBankCardInfo;
import exocr.drcard.DRManager;
import exocr.engine.DataCallBack;
import exocr.engine.EngineManager;
import exocr.exocrengine.EXDRCardResult;
import exocr.exocrengine.EXIDCardResult;
import exocr.exocrengine.EXVECardResult;
import exocr.idcard.IDCardManager;
import exocr.vecard.VEManager;


public class EXOCRModule extends ReactContextBaseJavaModule implements DataCallBack, exocr.bankcard.DataCallBack { // implements DataCallBack

    EXOCRContext exocrContext;
    private final ReactApplicationContext reactContext;
    private static Promise promise;
    private static ReadableMap options;
    private static EXOCRType exocrType;
    private static Boolean front;

    public EXOCRModule(ReactApplicationContext reactContext, EXOCRContext exocrContext) {
        super(reactContext);
        this.reactContext = reactContext;
        this.exocrContext = exocrContext;
    }

    public EXOCRModule(ReactApplicationContext reactContext) {
        this(reactContext, new EXOCRContext(reactContext.getApplicationContext()));
    }

    @Override
    public String getName() {
        return "RNKitEXOCR";
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("sdkVersion", EngineManager.getInstance().getSDKVersion());
        constants.put("kernelVersion", "0");
        return constants;
    }

    public double getQuality () {
        double quality;
        if (this.options != null && this.options.hasKey("quality") && !this.options.isNull("quality")) {
            quality = this.options.getDouble("quality");
        } else {
            quality = .8;
        }
        return quality;
    }

    @ReactMethod
    public void config(@Nullable final ReadableMap options) {
        this.options = options;
        final Bundle args = new Bundle();

        if (options.hasKey("OrientationMask") && !options.isNull("OrientationMask")) {
            BankManager.getInstance().setRecoSupportOrientation(BankManager.supportOrientations.allSupport);
        }

        if (options.hasKey("NumberOfSpace") && !options.isNull("NumberOfSpace")) {

        }

        if (options.hasKey("DisplayLogo") && !options.isNull("DisplayLogo")) {
            BankManager.getInstance().showLogo(options.getBoolean("DisplayLogo"));
            DRManager.getInstance().setShowLogo(options.getBoolean("DisplayLogo"));
            VEManager.getInstance().setShowLogo(options.getBoolean("DisplayLogo"));
            IDCardManager.getInstance().setShowLogo(options.getBoolean("DisplayLogo"));
        }

        if (options.hasKey("EnablePhotoRec") && !options.isNull("EnablePhotoRec")) {
            BankManager.getInstance().setShowPhoto(options.getBoolean("EnablePhotoRec"));
            DRManager.getInstance().setShowPhoto(options.getBoolean("EnablePhotoRec"));
            IDCardManager.getInstance().setShowPhoto(options.getBoolean("EnablePhotoRec"));
            VEManager.getInstance().setShowPhoto(options.getBoolean("EnablePhotoRec"));
        }

        if (options.hasKey("BankScanTips") && !options.isNull("BankScanTips")) {
            BankManager.getInstance().setScanTipText(options.getString("BankScanTips"));
        }

        if (options.hasKey("DRCardScanTips") && !options.isNull("DRCardScanTips")) {
            DRManager.getInstance().setTipText(options.getString("DRCardScanTips"));
        }

        if (options.hasKey("VECardScanTips") && !options.isNull("VECardScanTips")) {
            VEManager.getInstance().setTipText(options.getString("VECardScanTips"));
        }

        if (options.hasKey("IDCardScanFrontNormalTips") && !options.isNull("IDCardScanFrontNormalTips")) {
            IDCardManager.getInstance().setTipFrontRightText(options.getString("IDCardScanFrontNormalTips"));
        }

        if (options.hasKey("IDCardScanFrontErrorTips") && !options.isNull("IDCardScanFrontErrorTips")) {
            IDCardManager.getInstance().setTipFrontErrorText(options.getString("IDCardScanFrontErrorTips"));
        }

        if (options.hasKey("IDCardScanBackNormalTips") && !options.isNull("IDCardScanBackNormalTips")) {
            IDCardManager.getInstance().setTipBackRightText(options.getString("IDCardScanBackNormalTips"));
        }

        if (options.hasKey("IDCardScanBackErrorTips") && !options.isNull("IDCardScanBackErrorTips")) {
            IDCardManager.getInstance().setTipBackErrorText(options.getString("IDCardScanBackErrorTips"));
        }
    }

    // --- 身份证
    @ReactMethod
    public void recoBankFromStream(@Nullable final Promise promise) {
        this.promise = promise;
        Activity activity = getCurrentActivity();
        BankManager.getInstance().recognize(this, activity);
    }

    @ReactMethod
    public void recoBankFromStillImage(String src, @Nullable final Promise promise) {
        this.promise = promise;
        try {
            Bitmap bitmap = this.exocrContext.getBitmap(src);
            BankManager.getInstance().recPhoto(bitmap);
        } catch (Exception e) {

        }
    }

    // --- 驾驶证
    @ReactMethod
    public void recoDRCardFromStream(@Nullable final Promise promise) {
        this.promise = promise;
        this.exocrType = EXOCRType.EXOCRDRCard;
        Activity activity = getCurrentActivity();
        EngineManager.getInstance().initEngine(activity);
        DRManager.getInstance().recognize(this, activity);
    }

    @ReactMethod
    public void recoDRCardFromStillImage(String src, @Nullable final Promise promise) {
        this.promise = promise;
        this.exocrType = EXOCRType.EXOCRDRCard;
        try {
            Bitmap bitmap = this.exocrContext.getBitmap(src);
            DRManager.getInstance().recPhoto(bitmap);
        } catch (Exception e) {

        }
    }

    // --- 身份证
    @ReactMethod
    public void recoIDCardFromStreamWithSide(Boolean front, @Nullable final Promise promise) {

        this.promise = promise;
        this.exocrType = EXOCRType.EXOCRIDCard;
        this.front = front;

        Activity activity = getCurrentActivity();
        EngineManager.getInstance().initEngine(activity);
        IDCardManager.getInstance().setFront(front);
        IDCardManager.getInstance().recognize(this, activity);
    }

    @ReactMethod
    public void recoIDCardFromStillImage(String src, @Nullable final Promise promise) {
        this.promise = promise;
        this.exocrType = EXOCRType.EXOCRIDCard;
        try {
            Bitmap bitmap = this.exocrContext.getBitmap(src);
            IDCardManager.getInstance().recPhoto(bitmap);
        } catch (Exception e) {

        }
    }


    // --- 行驶证
    @ReactMethod
    public void recoVECardFromStream(@Nullable final Promise promise) {
        this.promise = promise;
        this.exocrType = EXOCRType.EXOCRVECard;
        Activity activity = getCurrentActivity();
        EngineManager.getInstance().initEngine(activity);
        VEManager.getInstance().recognize(this, activity);
    }

    @ReactMethod
    public void recoVECardFromStillImage(String src, @Nullable final Promise promise) {
        this.promise = promise;
        this.exocrType = EXOCRType.EXOCRVECard;
        try {
            Bitmap bitmap = this.exocrContext.getBitmap(src);
            VEManager.getInstance().recPhoto(bitmap);
        } catch (Exception e) {

        }
    }

    @Override
    public void onBankCardDetected(boolean b) {
        if (b) {
            try {
                EXBankCardInfo result = BankManager.getInstance().getCardInfo();
                String fullImagePath = this.exocrContext.saveImage(result.fullImage, this.getQuality());

                WritableMap map = Arguments.createMap();
                map.putString("bankName", result.strBankName);
                map.putString("cardName", result.strCardName);
                map.putString("cardType", result.strCardType);
                map.putString("cardNum", result.strNumbers);
                map.putString("validDate", result.strValid);
                map.putString("cardName", result.strCardName);
                map.putString("cardName", result.strCardName);
                map.putString("fullImgPath", fullImagePath);
                map.putString("cardNumImgPath", "");
                Log.d("onBankCardDetected", map.toString());

                this.promise.resolve(map);
            } catch (IOException e) {
                this.promise.reject("-1", "");
            }
        } else {
            Log.d("onBankCardDetected", "-1");
            this.promise.reject("-1", "");
        }
    }

    @Override
    public void onCardDetected(boolean b) {
        if (b) {
            try {
                // 驾驶证
                if (this.exocrType == EXOCRType.EXOCRDRCard) {

                    EXDRCardResult result = DRManager.getInstance().getResult();
                    String fullImagePath = this.exocrContext.saveImage(result.stdCardIm, this.getQuality());

                    WritableMap map = Arguments.createMap();
                    map.putString("name", result.szName);
                    map.putString("sex", result.szSex);
                    map.putString("nation", result.szNation);
                    map.putString("cardId", result.szCardID);
                    map.putString("address", result.szAddress);
                    map.putString("birth", result.szBirth);
                    map.putString("issueDate", result.szIssue);
                    map.putString("driveType", result.szClass);
                    map.putString("validDate", result.szValid);
                    map.putString("fullImgPath", fullImagePath);
                    Log.d("onCardDetected", map.toString());

                    EngineManager.getInstance().finishEngine();
                    this.promise.resolve(map);

                // 身份证
                } else if (this.exocrType == EXOCRType.EXOCRIDCard) {

                    EXIDCardResult result = IDCardManager.getInstance().getResult();
                    String fullImagePath = this.exocrContext.saveImage(result.stdCardIm, this.getQuality());

                    WritableMap map = Arguments.createMap();

                    map.putInt("type", this.front ? 1 : 2);
                    map.putString("name", result.name);
                    map.putString("gender", result.sex);
                    map.putString("nation", result.nation);
                    map.putString("birth", result.birth);
                    map.putString("address", result.address);
                    map.putString("code", result.cardnum);
                    map.putString("issue", result.office);
                    map.putString("valid", result.validdate);
                    map.putInt("frontShadow", -1);
                    map.putInt("backShadow", -1);

                    // 正面
                    if (this.front) {
                        map.putString("frontFullImgPath", fullImagePath);
                        String faceImgPath = this.exocrContext.saveImage(result.GetFaceBitmap(), this.getQuality());
                        map.putString("faceImgPath", faceImgPath);
                    } else {
                        map.putString("backFullImgPath", fullImagePath);
                    }

                    Log.d("onCardDetected", map.toString());

                    EngineManager.getInstance().finishEngine();
                    this.promise.resolve(map);

                } else if (this.exocrType == EXOCRType.EXOCRVECard) {
                    EXVECardResult result = VEManager.getInstance().getResult();
                    String fullImagePath = this.exocrContext.saveImage(result.stdCardIm, this.getQuality());

                    WritableMap map = Arguments.createMap();
                    map.putString("plateNo", result.szPlateNo);
                    map.putString("vehicleType", result.szVehicleType);
                    map.putString("owner", result.szOwner);
                    map.putString("address", result.szAddress);
                    map.putString("model", result.szModel);
                    map.putString("useCharacter", result.szUseCharacter);
                    map.putString("engineNo", result.szEngineNo);
                    map.putString("VIN", result.szVIN);
                    map.putString("registerDate", result.szRegisterDate);
                    map.putString("issueDate", result.szIssueDate);
                    map.putString("fullImgPath", fullImagePath);
                    Log.d("onCardDetected", map.toString());

                    EngineManager.getInstance().finishEngine();
                    this.promise.resolve(map);
                } else {
                    this.promise.reject("-1", "");
                }
            } catch (IOException e) {
                this.promise.reject("-1", "");
            }
        } else {
            Log.d("onBankCardDetected", "-1");
            this.promise.reject("-1", "");
        }
    }

    @Override
    public void onCameraDenied() {

    }

    public static enum EXOCRType {
        EXOCRDRCard,  // 驾驶证
        EXOCRIDCard,  // 身份证
        EXOCRVECard   // 行驶证
    }
}