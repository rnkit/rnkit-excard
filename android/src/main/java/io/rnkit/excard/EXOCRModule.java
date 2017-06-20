
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

import exocr.engine.DataCallBack;
import exocr.engine.EngineManager;
import exocr.exocrengine.EXIDCardResult;
import exocr.idcard.IDCardManager;

public class EXOCRModule extends ReactContextBaseJavaModule implements DataCallBack { // implements DataCallBack

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

        if (options.hasKey("DisplayLogo") && !options.isNull("DisplayLogo")) {
            IDCardManager.getInstance().setShowLogo(options.getBoolean("DisplayLogo"));
        }

        if (options.hasKey("EnablePhotoRec") && !options.isNull("EnablePhotoRec")) {
            IDCardManager.getInstance().setShowPhoto(options.getBoolean("EnablePhotoRec"));
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

    @Override
    public void onCardDetected(boolean b) {
        if (b) {
            try {
                if (this.exocrType == EXOCRType.EXOCRIDCard) {

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
