 [中文文档](README_CN.md)

<font color = #000000 size = 6> Inet Body Fat Scale SDK Instructions </font>

<font color = #0000ff size = 2> Note: This SDK upgrade to version 2.0 (AIFit-Demo-New) is a major version upgrade with new features and improved stability. Some class names and method names have changed. Not compatible with previous versions. The old version of AIFit-Demo is no longer maintained, please use the new version as much as possible. </font>

<font color = #000000 size = 5> Contents </font>

[toc]


## Overview

* What is the Inet Body Fat Scale SDK?

> Inet Body Fat Scale SDK is a Bluetooth development tool provided to Inet partners. This SDK implements and encapsulates the Inet Bluetooth protocol and is responsible for the communication between the mobile phone App and the Bluetooth body fat scale device. It is designed to facilitate partners to customize themselves. Bluetooth Body Fat Scale Application.


* Scope

> Partners who need to personalize their own iOS Bluetooth Body Fat Scale App.


## Conditions of Use

* 1. Minimum version of iOS 8.0
* 2. The Bluetooth version used by the device needs 4.0 and above
* 3. Support armv7 / i386 / x86_64 / arm64 instruction set;

## SDK integration

* 1. Import InetBleSDK.framework into Xcode project. <br><br>
* 2. Set the following privacy permission usage description in the project's `Info.plist`, and the actual description content is set by each project.

```
	<key> NSBluetoothAlwaysUsageDescription </key>
	<string> Use bluetooth to connect body fat scale </string>
```

* 3. Import `#import <InetBleSDK/InetBleSDK.h>` in the xxx.m file that needs to use the SDK, and follow the `<INBluetoothManagerDelegate, AnalysisBLEDataManagerDelegate>` protocol, set the proxy, and implement the proxy method.


## Get SDK version

The SDK version number can be obtained by calling the method [INBluetoothManager sdkVersion], and the SDK version number will be automatically printed on the console after the app starts. Example: v2.0-20191225


## Get the Bluetooth status of the IOS system

You can get the Bluetooth state of the system through [BluetoothManagershareManager].bleState 
<br>Refer to the CBCentralManagerState enumeration definition for the obtained state.

```
typedef NS_ENUM (NSInteger, CBCentralManagerState) {
CBCentralManagerStateUnknown = CBManagerStateUnknown,
CBCentralManagerStateResetting = CBManagerStateResetting,
CBCentralManagerStateUnsupported = CBManagerStateUnsupported,
CBCentralManagerStateUnauthorized = CBManagerStateUnauthorized,
CBCentralManagerStatePoweredOff = CBManagerStatePoweredOff,
CBCentralManagerStatePoweredOn = CBManagerStatePoweredOn,
}
```

## Get INBluetoothManager working status

Set the agent of the SDK Bluetooth management class [INBluetoothManager shareManager] .delegate = self; and implement the following proxy method to monitor the working status of the Bluetooth management class INBluetoothManager.

```
-(void) BluetoothManager: (INBluetoothManager *) manager updateCentralManagerState: (BluetoothManagerState) state {
}

// BluetoothManagerState enumeration is as follows:
typedef NS_ENUM (NSInteger, BluetoothManagerState) {
    BluetoothManagerState_PowerOn,
    BluetoothManagerState_PowerOff,
    BluetoothManagerState_UnknowErr,
    BluetoothManagerState_StartScan,
    BluetoothManagerState_StopScan,
    BluetoothManagerState_ConnectSuccess,
    BluetoothManagerState_ConnectFailed,
    BluetoothManagerState_Disconnect
};

```

## Get AnalysisBLEDataManager working status

Set the proxy of the data analysis class [AnalysisBLEDataManager shareManager] .infoDelegate = self; and implement the following proxy method to get the working status of the data analysis class AnalysisBLEDataManager

```
-(void) AnalysisBLEDataManager: (AnalysisBLEDataManager *) analysisManager updateBleDataAnalysisStatus: (BleDataAnalysisStatus) bleDataAnalysisStatus {
}

// BleDataAnalysisStatus enumeration is as follows:

/ **
 Note:
 linkScale has all below status, but broadcastScale just has // b1, b2, b3
 * /
typedef NS_ENUM (NSInteger, BleDataAnalysisStatus) {
    
    BleDataAnalysisStatus_SyncTimeSuccess,
    BleDataAnalysisStatus_SyncTimeFailed, // lead to error measureTime
    BleDataAnalysisStatus_SyncUserSuccess,
    BleDataAnalysisStatus_SyncUserFailed, // lead to no bodydata, just weight
    
    BleDataAnalysisStatus_UnstableWeight, // b1
    BleDataAnalysisStatus_StableWeight, // b2
    BleDataAnalysisStatus_MeasureComplete, // b3
    BleDataAnalysisStatus_AdcError,
    
    BleDataAnalysisStatus_LightOff,
};

```


## Device Type

Devices are mainly divided into the following two categories, and the device type can be obtained according to the acNumber attribute of deviceModel called by -BluetoothManager:didDiscoverDevice: proxy method callback.

1. Broadcast scale: acNumber = 0 or acNumber = 1
> * The broadcast scale uses Bluetooth broadcast to transmit data to the outside world and cannot be connected. The broadcast scale is only responsible for determining the user's weight and impedance, and does not calculate any body fat data.<br><br>
> * After the app parses the weight and impedance via Bluetooth broadcast, it calls the corresponding method in the SDK algorithm class AlgorithmSDK to calculate 10 items of body fat data.<br><br>
> * acNumber = 0 is a broadcast scale without temperature, acNumber = 1 is a broadcast scale with temperature. Currently the SDK only supports BM15 broadcast scales.


2. Link scale: acNumber = 2 or acNumber = 3
> * The connection scale is responsible for measuring the user's weight and impedance, and calculating 10 items of body fat data according to the user information issued by the App, and transmitting it to the App via Bluetooth.<br><br>
> * acNumber = 2 is the connected scale without temperature, acNumber = 3 is the connected scale with temperature. At present, the SDK only supports scales with 1 decimal place, and does not support protocols with 2 decimal places and 0xAE.

## Scan device list

```
// SearchDeviceVC.m

@interface SearchDeviceVC () <INBluetoothManagerDelegate>
@end

@implementation SearchDeviceVC

-(void) viewDidLoad
{
    [super viewDidLoad];

    if ([INBluetoothManager shareManager] .bleState == CBCentralManagerStatePoweredOn) {
        [INBluetoothManager shareManager] .delegate = self;
        [[INBluetoothManager shareManager] startBleScan];
    } else {
        NSLog (@ "--- Error: BLE not avalible, pls check.");
    }
}


#pragma mark-BluetoothManagerDelegate

-(void) BluetoothManager: (INBluetoothManager *) manager didDiscoverDevice: (DeviceModel *) deviceModel
{

    if (self.isAddPeripheraling == YES) return;
    
    self.isAddPeripheraling = YES;
    
    BOOL willAdd = YES;
    for (DeviceModel * model in self.peripheralArray) // avoid add the same device
    {
        if ([model.deviceAddress isEqualToString: deviceModel.deviceAddress] 
        && [model.deviceName isEqualToString: deviceModel.deviceName])
        {
            willAdd = NO;
        }
    }
    
    if (willAdd) {
        [self.peripheralArray addObject: deviceModel];
        [self.BleTableView reloadData];
    }
    
    self.isAddPeripheraling = NO;
    
}


```

## Broadcast scale interactive process

1. Scan the device list (refer to the “Scan Device List” operation), filter out the broadcast scale model according to acNumber = 0 or acNumber = 1

2. Set the proxy of the data analysis class AnalysisBLEDataManager, follow the data analysis protocol AnalysisBLEDataManagerDelegate, and listen to the corresponding proxy method
```
-(void) AnalysisBLEDataManager: (AnalysisBLEDataManager *) analysisManager updateMeasureUserInfo: (UserInfoModel *) infoModel;
```
3. Call the SDK method [[INBluetoothManager shareManager] handleDataForBroadScale: device]; and start processing broadcast scale data.

4. After performing step 3, the proxy method in step 2 starts to call back infoModel (broadcast scale only measures weight and impedance), plus the user information obtained by the App, calls the algorithm provided by AlgorithmSDK + (AlgorithmModel *) getBodyfatWithWeight: (double ) kgWeight adc: (int) adc sex: (AlgUserSex) sex age: (int) age height: (int) height; Calculate 10 items of body fat data

```
-(void) AnalysisBLEDataManager: (AnalysisBLEDataManager *) analysisManager updateMeasureUserInfo: (UserInfoModel *) infoModel {
    NSLog (@ "--- infoModel:% @", infoModel);
    
    _currentInfoModel = infoModel;
    [self refreshTableView];
    
    if (_currentInfoModel.measureStatus == MeasureStatus_Complete && _currentInfoModel.weightsum> 0 && _currentInfoModel.newAdc> 0) {// Measure Complete
        
        float weight = _currentInfoModel.weightsum / pow (10, _currentInfoModel.weightOriPoint); // 6895-> 68.95
        float adc = _currentInfoModel.newAdc;
        _appUser.weightKg = weight;
        _appUser.adc = adc;
        _userInfoLabel.text = [NSString stringWithFormat: @ "sex:% d \ n age:% d \ n height:% d \ n weight:%. 1f \ n adc:% d", _ appUser.sex, _appUser.age, _appUser .height, _appUser.weightKg, _appUser.adc];
        
        if (_targetDeviceModel.acNumber.intValue <2) {// BroadScale BM15 mesure complete

            AlgorithmModel * algModel = [AlgorithmSDK getBodyfatWithWeight: weight adc: adc sex: _appUser.sex age: _appUser.age height: _appUser.height];
            NSLog (@ "--- BM15 AlgorithmModel:% @", algModel);
            _currentInfoModel.fatRate = algModel.bfr.floatValue;
            _currentInfoModel.BMI = algModel.bmi.floatValue;
            _currentInfoModel.moisture = algModel.vwc.floatValue;
            _currentInfoModel.muscle = algModel.rom.floatValue;
            _currentInfoModel.BMR = algModel.bmr.floatValue;
            _currentInfoModel.boneMass = algModel.bm.floatValue;
            _currentInfoModel.visceralFat = algModel.uvi.floatValue;
            _currentInfoModel.proteinRate = algModel.pp.floatValue;
            _currentInfoModel.physicalAge = algModel.physicalAge.floatValue;
            _currentInfoModel.subcutaneousFat = algModel.sfr.floatValue;
            
            // refresh
            [self refreshTableView];
            
        } else {// connect scale measure complete
            
        }

    }
    
}
```

* 5. If you need to obtain 6 additional physical indicators such as fat-free weight and weight control, please call another algorithm provided by the SDK, BfsCalculateSDK to calculate.

```
    float weight = _currentInfoModel.weightsum / pow (10, _currentInfoModel.weightOriPoint); // 6895-> 68.95
    int sex = _appUser.sex;
    int height = _appUser.height;
    NSString * bfr = [NSString stringWithFormat: @ "%. 1f", _ currentInfoModel.fatRate];
    NSString * rom = [NSString stringWithFormat: @ "%. 1f%", _ currentInfoModel.muscle];
    NSString * pp = [NSString stringWithFormat: @ "%. 1f%", _ currentInfoModel.proteinRate];
    BfsCalculateItem * item = [BfsCalculateSDK getBodyfatItemWithSex: sex height: height weight: weight bfr: bfr rom: rom pp: pp];
    
```


## Connection scale interactive process

`1`. Scan the device list (refer to “Scan Device List” operation), and select the connected scale model according to acNumber = 2 or acNumber = 3

`2`. Set the proxy of the data analysis class AnalysisBLEDataManager, follow the data analysis protocol AnalysisBLEDataManagerDelegate, and listen to the corresponding proxy method

```
-(void) AnalysisBLEDataManager: (AnalysisBLEDataManager *) analysisManager
updateBleDataAnalysisStatus: (BleDataAnalysisStatus) bleDataAnalysisStatus;

-(void) AnalysisBLEDataManager: (AnalysisBLEDataManager *) analysisManager
updateMeasureUserInfo: (UserInfoModel *) infoModel;

/// If no need offline history function, do not implement this callback
-(void) AnalysisBLEDataManager: (AnalysisBLEDataManager *) analysisManager backOfflineHistorys: (NSMutableArray <UserInfoModel *> *) historysMutableArr;

```

`3`. Invoke SDK method [[INBluetoothManager shareManager] connectToLinkScale: device]; try to connect the connected scale device.

`4`. Monitor the working status of the data analysis class BleDataAnalysisStatus_SyncTimeSuccess callback, which means that the connection to the scale is successfully connected, the initialization is completed, and the app can receive interactive instructions. At this time, you need to switch the scale unit to keep in sync with the App, synchronize the information of the user who is about to be weighed, synchronize the offline user list, and request offline history (if you don't need offline function, you can ignore it).



```
- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager 
updateBleDataAnalysisStatus:(BleDataAnalysisStatus)bleDataAnalysisStatus {
    switch (bleDataAnalysisStatus) {
        case BleDataAnalysisStatus_SyncTimeSuccess:
        {
            _tipLB.text = @"sync time success";
            
            //set unit
            [self ChooseUnit:self.unitSegmentedControl];
            
            //then sync user to be weighing
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 
            (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self syncWeighingUserToBle];
            });

            //sync offline userlist(If no need offline history function, do not call this method)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 
            (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self syncOfflineUserListToBle];
            });
            
            //request history (If no need offline history function, do not call this method)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 
            (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[WriteToBLEManager shareManager] requestOfflineHistory];
            });

            break;
        }
        case BleDataAnalysisStatus_SyncTimeFailed:
        {
            _tipLB.text = @"sync time failed";
            break;
        }
        case BleDataAnalysisStatus_SyncUserSuccess:
        {
            _tipLB.text = @"sync weighing user success";
            
            break;
        }
        case BleDataAnalysisStatus_SyncUserFailed:
        {
            _tipLB.text = @"sync weighing user failed";
            break;
        }
        case BleDataAnalysisStatus_UnstableWeight:
        {
            _tipLB.text = @"measuring...\nUnstable Weight";
            break;
        }
        case BleDataAnalysisStatus_StableWeight:
        {
            _tipLB.text = @"Stable Weight";
            break;
        }
        case BleDataAnalysisStatus_MeasureComplete:
        {
            _tipLB.text = @"measure complete";
            
            break;
        }
        case BleDataAnalysisStatus_AdcError:
        {
            _tipLB.text = @"adc measure failed";
            
            break;
        }
        case BleDataAnalysisStatus_LightOff:
        {
            _tipLB.text = @"your linkScale light off";
            
            break;
        }
        default:
            break;
    }
}

```

`5`. After executing step 3, the proxy method set in step 2 starts to call back the weight information model infoModel. The App performs secondary processing on the received data and refreshes the UI interface. At the same time, it is necessary to determine the end of the measurement, and send instructions to update the current and offline user list information.

```
- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager updateMeasureUserInfo:(UserInfoModel *)infoModel {
    NSLog(@"---infoModel:%@",infoModel);
    
    _currentInfoModel = infoModel;
    [self refreshTableView];
    
    if (_currentInfoModel.measureStatus == MeasureStatus_Complete && _currentInfoModel.weightsum > 0 && _currentInfoModel.newAdc > 0) { //Measure Complete
        
        float weight = _currentInfoModel.weightsum/pow(10, _currentInfoModel.weightOriPoint);//6895->68.95
        float adc = _currentInfoModel.newAdc;
        _appUser.weightKg = weight;
        _appUser.adc = adc;
        _userInfoLabel.text = [NSString stringWithFormat:@" sex:%d\n age:%d\n height:%d\n weight:%.1f\n adc:%d",_appUser.sex,_appUser.age,_appUser.height,_appUser.weightKg,_appUser.adc];
        
        if (_targetDeviceModel.acNumber.intValue < 2) { //BroadScale BM15 mesure complete
            
        } else { //connect scale measure complete
            
            [self syncWeighingUserToBle];
            
            // If no need offline history function, do not call this method
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self syncOfflineUserListToBle];
            });
            
        }

    }
    
}

```

`6`. If you need to obtain 6 additional physical indicators such as fat-free weight and weight control, please call another algorithm provided by the SDK, BfsCalculateSDK to calculate.

```
    float weight = _currentInfoModel.weightsum/pow(10, _currentInfoModel.weightOriPoint);//6895->68.95
    int sex = _appUser.sex;
    int height = _appUser.height;
    NSString *bfr = [NSString stringWithFormat:@"%.1f",_currentInfoModel.fatRate];
    NSString *rom = [NSString stringWithFormat:@"%.1f％",_currentInfoModel.muscle];
    NSString *pp = [NSString stringWithFormat:@"%.1f％",_currentInfoModel.proteinRate];
    BfsCalculateItem *item = [BfsCalculateSDK getBodyfatItemWithSex:sex height:height 
    weight:weight bfr:bfr rom:rom pp:pp];
    
```


## Version history

Version number | Update time | Author | Update information |
| --- | --- | --- | --- |
| v1.0 | 9/10 2018 | wz | Preliminary version |
v1.1 | 2019/02/27 | wz | Add impedance measurement failure callback and Log switch |
| v1.2 | 2019/04/25 | wz | Added BM15 algorithm interface |
| v1.3 | 2019/08/12 | wz | Optimize Bluetooth connection |
V1.4 | 2019/10/29 | wz | IOS13 compatible system |
V1.5 | 2019/12/20 | wz | Add offline history function |
V2.0 | 2019/12/25 | wz | Feature update: <br> 1. Modify the BluetoothManager class name to INBluetoothManager to avoid conflicts with the system's private APIs. <br> 2. Standardize methods and properties in AlgorithmSDK and AlgorithmModel classes. br> 3. Added BfsCalculateSDK algorithm, which can obtain additional data for calculating body fat data <br> 4. Automatically read the DID of the scale <br> 5. Fix bugs found during testing |


## FAQ

> Q: How to tell whether the currently scanned DeviceModel is a broadcast scale or a connected scale?

> A: According to the acNumber property value of DeviceModel: acNumber = 0 is a broadcast scale without temperature, acNumber = 1 is a broadcast scale with temperature. acNumber = 2 is the connected scale without temperature, acNumber = 3 is the connected scale with temperature.

> Q: How to judge the end of the measurement?

> A: According to the UserInfoModel * infoModel property.measureStatus of the data analysis class proxy method callback.
>
```
typedef NS_ENUM (NSInteger, MeasureStatus) {
    MeasureStatus_Unstable = 0,
    MeasureStatus_Stable,
    MeasureStatus_Complete,
    MeasureStatus_OfflineHistory,
};
```

> Q: Which units does the Bluetooth protocol support?
>
> A: The unit only supports up to 4 types (kg, lb, st, catty). For details about what units are supported, please refer to the factory settings of the scale.



## Technical Support

Wuz

Inet App Manager

inet_support@163.com
