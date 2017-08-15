[![npm][npm-badge]][npm]
[![react-native][rn-badge]][rn]
[![MIT][license-badge]][license]
[![bitHound Score][bithound-badge]][bithound]
[![Downloads](https://img.shields.io/npm/dm/rnkit-excard.svg)](https://www.npmjs.com/package/rnkit-excard)

易道博识-图像识别 for [React Native][rn].

[**Support me with a Follow**](https://github.com/simman/followers)

[npm-badge]: https://img.shields.io/npm/v/rnkit-excard.svg
[npm]: https://www.npmjs.com/package/rnkit-excard
[rn-badge]: https://img.shields.io/badge/react--native-v0.40-05A5D1.svg
[rn]: https://facebook.github.io/react-native
[license-badge]: https://img.shields.io/dub/l/vibe-d.svg
[license]: https://raw.githubusercontent.com/rnkit/rnkit-excard/master/LICENSE
[bithound-badge]: https://www.bithound.io/github/rnkit/rnkit-excard/badges/score.svg
[bithound]: https://www.bithound.io/github/rnkit/rnkit-excard

## Getting Started

First, `cd` to your RN project directory, and install RNMK through [rnpm](https://github.com/rnpm/rnpm) . If you don't have rnpm, you can install RNMK from npm with the command `npm i -S rnkit-excard` and link it manually (see below).

### iOS

* #### React Native < 0.29 (Using rnpm)

  `rnpm install rnkit-excard`

* #### React Native >= 0.29
  `$npm install -S rnkit-excard`

  `$react-native link rnkit-excard`

#### Manually
1. Add `node_modules/rnkit-excard/ios/RNKitExcard.xcodeproj` to your xcode project, usually under the `Libraries` group
1. Add `libRNKitExcard.a` (from `Products` under `RNKitExcard.xcodeproj`) to build target's `Linked Frameworks and Libraries` list
1. Add ocr framework to `$(PROJECT_DIR)/Frameworks.`

### Android

* #### React Native < 0.29 (Using rnpm)

  `rnpm install rnkit-excard`

* #### React Native >= 0.29
  `$npm install -S rnkit-excard`

  `$react-native link rnkit-excard`

#### Manually
1. JDK 7+ is required
1. Add the following snippet to your `android/settings.gradle`:

  ```gradle
include ':rnkit-excard'
project(':rnkit-excard').projectDir = new File(rootProject.projectDir, '../node_modules/rnkit-excard/android/app')
  ```
  
1. Declare the dependency in your `android/app/build.gradle`
  
  ```gradle
  dependencies {
      ...
      compile project(':rnkit-excard')
  }
  ```
  
1. Import `import io.rnkit.excard.EXOCRPackage;` and register it in your `MainActivity` (or equivalent, RN >= 0.32 MainApplication.java):

  ```java
  @Override
  protected List<ReactPackage> getPackages() {
      return Arrays.asList(
              new MainReactPackage(),
              new EXOCRPackage()
      );
  }
  ```
1. Add Module `ExBankCardSDK` And `ExCardSDK` In Your Main Project.

Finally, you're good to go, feel free to require `rnkit-excard` in your JS files.

Have fun! :metal:

## Basic Usage

Import library

```
import RNKitExcard from 'rnkit-excard';
```

### Init

```jsx
RNKitExcard.config({
  DisplayLogo: false
  ....
})
```

#### Init Params

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| OrientationMask | string | 'MaskAll' | 方向设置，设置扫描页面支持的识别方向 |
| ByPresent | BOOL | NO | 扫描页面调用方式设置,是否以present方式调用，默认为NO，YES-以present方式调用，NO-以sdk默认方式调用(push或present) |
| NumberOfSpace | BOOL | YES | 结果设置，银行卡号是否包含空格 |
| DisplayLogo | BOOL | YES | 是否显示logo |
| EnablePhotoRec | BOOL | YES | EnablePhotoRec |
| FrameColor | int |  | 扫描框颜色, 必须与FrameAlpha共同设置 |
| FrameAlpha | float |  | 扫描框透明度, 必须与FrameColor共同设置 |
| ScanTextColor | int |  | 扫描字体颜色 |
| IDCardScanNormalTextColor | int |  | 正常状态扫描字体颜色 (身份证) |
| IDCardScanErrorTextColor | int |  | 错误状态扫描字体颜色 (身份证) |
| BankScanTips | string | | 银行卡扫描提示文字 |
| DRCardScanTips | string | | 驾驶证扫描提示文字 |
| VECardScanTips | string | | 行驶证扫描提示文字 |
| BankScanTips | string | | 银行卡扫描提示文字 |
| IDCardScanFrontNormalTips | string | | 身份证正常状态正面扫描提示文字 |
| IDCardScanFrontErrorTips | string | | 身份证错误状态正面扫描提示文字 |
| IDCardScanBackNormalTips | string | | 身份证正常状态背面扫描提示文字 |
| IDCardScanBackErrorTips | string | | 身份证错误状态背面扫描提示文字 |
| fontName | string | | 扫描提示文字字体名称 |
| ScanTipsFontSize | float | | 扫描提示文字字体大小 |
| IDCardNormalFontName | string | | 正常状态扫描提示文字字体名称 |
| IDCardNormalFontSize | float | | 正常状态扫描提示文字字体大小 |
| IDCardErrorFontName | string | | 错误状态扫描提示文字字体名称 |
| IDCardErrorFontSize | float | | 错误状态扫描提示文字字体大小 |
| quality | float | | 图片清晰度, 范围(0-1) |

##### OrientationMask

- Portrait
- LandscapeLeft
- LandscapeRight
- PortraitUpsideDown
- Landscape
- MaskAll
- AllButUpsideDown

### 一、银行卡识别

#### 1. 使用摄像头、相册识别

```jsx
try {
	const result = await RNKitExcard.recoBankFromStream();
} catch (error) {
	if (error.code === -1) {
		console.log('on cancel')
	} else {
		console.log(error)
	}
}
```

#### 2. 使用远程或本地图片识别

```jsx
try {
	const imagePath = '...';
	const result = await RNKitExcard.recoBankFromStillImage(imagePath);
} catch (error) {
	if (error.code === -1) {
		console.log('on cancel')
	} else {
		console.log(error)
	}
}
```

返回值

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| bankName | string |  | 银行名称 |
| cardName | string |  | 卡名称 |
| cardType | string |  | 卡类型 |
| cardNum | string |  | 卡号 |
| validDate | string |  | 有限期 |
| fullImgPath | string |  | 银行卡全图 |
| cardNumImgPath | string |  | 银行卡号截图 |

### 二、驾驶证识别

#### 1. 使用摄像头、相册识别

```jsx
try {
	const result = await RNKitExcard.recoDRCardFromStream();
} catch (error) {
	if (error.code === -1) {
		console.log('on cancel')
	} else {
		console.log(error)
	}
}
```

#### 2. 使用远程或本地图片识别

```jsx
try {
	const imagePath = '...';
	const result = await RNKitExcard.recoDRCardFromStillImage(imagePath);
} catch (error) {
	if (error.code === -1) {
		console.log('on cancel')
	} else {
		console.log(error)
	}
}
```

返回值

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| name | string |  | 姓名 |
| sex | string |  | 性别 |
| nation | string |  | 国籍 |
| cardId | string |  | 身份证号码 |
| address | string |  | 住址 |
| birth | string |  | 出生日期 |
| issueDate | string |  | 初次领证时间 |
| driveType | string |  | 准驾车型 |
| validDate | string |  | 有效期至日期 |
| fullImgPath | string |  | 驾驶证全图 |

### 三、行驶证识别

#### 1. 使用摄像头、相册识别

```jsx
try {
	const result = await RNKitExcard.recoVECardFromStream();
} catch (error) {
	if (error.code === -1) {
		console.log('on cancel')
	} else {
		console.log(error)
	}
}
```

#### 2. 使用远程或本地图片识别

```jsx
try {
	const imagePath = '...';
	const result = await RNKitExcard.recoVECardFromStillImage(imagePath);
} catch (error) {
	if (error.code === -1) {
		console.log('on cancel')
	} else {
		console.log(error)
	}
}
```

返回值

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| plateNo | string |  | 号牌号码 |
| vehicleType | string |  | 车辆类型 |
| owner | string |  | 所有人 |
| address | string |  | 住址 |
| model | string |  | 品牌型号 |
| useCharacter | string |  | 使用性质 |
| engineNo | string |  | 发动机号 |
| VIN | string |  | 车辆识别代码 |
| registerDate | string |  | 注册日期 |
| issueDate | string |  | 发证日期 |
| fullImgPath | string |  | 行驶证全图 |

### 四、身份证识别

#### 1. 使用摄像头、相册识别

```jsx
try {
	const bFront = true  // 身份证方向，true-正面，false-背面
	const result = await RNKitExcard.recoIDCardFromStreamWithSide(bFront);
} catch (error) {
	if (error.code === -1) {
		console.log('on cancel')
	} else {
		console.log(error)
	}
}
```

#### 2. 使用远程或本地图片识别

```jsx
try {
	const imagePath = '...';
	const result = await RNKitExcard.recoIDCardFromStillImage(imagePath);
} catch (error) {
	if (error.code === -1) {
		console.log('on cancel')
	} else {
		console.log(error)
	}
}
```

返回值

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| type | int |  | 1:正面  2:反面 |
| name | string |  | 姓名 |
| gender | string |  | 性别 |
| nation | string |  | 名族 |
| birth | string |  | 出生 |
| address | string |  | 地址 |
| code | string |  | 身份证 |
| issue | string |  | 签发机关 |
| valid | string |  | 有效期 |
| frontShadow | int |  | 1:正面图像有遮挡 0:正面图像无遮挡 |
| backShadow | int |  | 1:背面图像有遮挡 0:背面图像无遮挡 |
| faceImgPath | string |  | 人脸截图 |
| frontFullImgPath | string |  | 身份证正面全图 |
| backFullImgPath | string | | 身份证背面全图 |

### 五、常量

```jsx
const sdkVersion = RNKitExcard.sdkVersion;
const kernelVersion = RNKitExcard.kernelVersion;
```

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| sdkVersion | string |  | sdk版本号 |
| kernelVersion | string |  | 识别核心版本号 |

### 六、clean 清理图片临时目录

```jsx
try {
	const result = await RNKitExcard.clean();
} catch (error) {
	console.log(error)
}
```

## Contribution

- [@simamn](mailto:liwei0990@gmail.com) The main author.

## Questions

Feel free to [contact me](mailto:liwei0990@gmail.com) or [create an issue](https://github.com/rnkit/rnkit-excard/issues/new)

> made with ♥
