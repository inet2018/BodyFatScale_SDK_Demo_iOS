
<font color=#000000 size=6> Inet体脂秤SDK使用说明 </font>

<font color=#0000ff size=2> 注意：本次SDK升级为2.0(AIFit-Demo-New)，是大版本升级，新增功能，提升稳定性，部分类名和方法名发生了变化，将不再兼容之前的版本。旧版本AIFit-Demo不再维护，请尽量使用新版本。</font>


<font color=#000000 size=5> 目录 </font>

[toc]


## 概述

* 什么是Inet体脂秤SDK ?

  > Inet体脂秤SDK 是提供给Inet合作伙伴的蓝牙开发工具，该SDK对Inet蓝牙协议进行了实现和封装，负责手机App与蓝牙体脂秤设备之间的通信，旨在方便合作伙伴定制自己的蓝牙体脂秤应用。       


* 适用范围

  > 需要个性化定制自己的 iOS 蓝牙体脂秤 APP 的合作伙伴。


## 使用条件

1. 最低版本iOS 8.0
2. 设备所使用的蓝牙版本需要4.0及以上
3. 支持armv7/i386/x86_64/arm64指令集；

## SDK集成

1. 将InetBleSDK.framework导入Xcode工程。
2. 在项目的`Info.plist`中设置以下隐私权限使用描述，实际描述内容各项目自行设置

	```
	<key>NSBluetoothAlwaysUsageDescription</key>
	<string>Use bluetooth to connect body fat scale</string>
	
	```
3. 在需要使用SDK的类.m文件中导入#import \<InetBleSDK/InetBleSDK.h>，并遵守\<INBluetoothManagerDelegate,AnalysisBLEDataManagerDelegate>协议，设置代理，实现代理方法。


## 获取SDK版本号
通过调用方法[INBluetoothManager sdkVersion]可获取SDK版本号，同时App启动后会自动在控制台打印SDK版本号。例如：v2.0-20191225


## 获取IOS系统蓝牙状态
通过[BluetoothManagershareManager].bleState可以获取系统蓝牙状态，获取的状态参考CBCentralManagerState枚举定义。

```
typedef NS_ENUM(NSInteger, CBCentralManagerState) {
	CBCentralManagerStateUnknown = CBManagerStateUnknown,
	CBCentralManagerStateResetting = CBManagerStateResetting,
	CBCentralManagerStateUnsupported = CBManagerStateUnsupported,
	CBCentralManagerStateUnauthorized = CBManagerStateUnauthorized,
	CBCentralManagerStatePoweredOff = CBManagerStatePoweredOff,
	CBCentralManagerStatePoweredOn = CBManagerStatePoweredOn,
}
```

## 获取INBluetoothManager工作状态

设置SDK蓝牙管理类的代理[INBluetoothManager shareManager].delegate = self; 并实现如下代理方法，，即可监听蓝牙管理类INBluetoothManager的工作状态。

```
- (void)BluetoothManager:(INBluetoothManager *)manager updateCentralManagerState:(BluetoothManagerState)state {
}

//BluetoothManagerState枚举如下：
typedef NS_ENUM(NSInteger,BluetoothManagerState) {
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

## 获取AnalysisBLEDataManager工作状态
设置数据解析类的代理[AnalysisBLEDataManager shareManager].infoDelegate = self; 并实现如下代理方法，即可获取数据解析类AnalysisBLEDataManager的工作状态

```
- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager updateBleDataAnalysisStatus:(BleDataAnalysisStatus)bleDataAnalysisStatus {
}

//BleDataAnalysisStatus枚举如下：

/**
 Note:
 linkScale has all below status, but broadcastScale just has //b1,b2,b3
 */
typedef NS_ENUM(NSInteger, BleDataAnalysisStatus) {
    
    BleDataAnalysisStatus_SyncTimeSuccess,
    BleDataAnalysisStatus_SyncTimeFailed,  //lead to error measureTime
    BleDataAnalysisStatus_SyncUserSuccess,
    BleDataAnalysisStatus_SyncUserFailed,  //lead to no bodydata, just weight
    
    BleDataAnalysisStatus_UnstableWeight,  //b1
    BleDataAnalysisStatus_StableWeight,    //b2
    BleDataAnalysisStatus_MeasureComplete, //b3
    BleDataAnalysisStatus_AdcError,        
    
    BleDataAnalysisStatus_LightOff,
};

```


## 设备类型

设备主要分为以下两大类，可根据-BluetoothManager:didDiscoverDevice:代理方法回调的deviceModel的属性acNumber来获取设备类型。

1. 广播秤(broadcast scale)：acNumber=0 或 acNumber=1
> * 广播秤使用蓝牙广播对外界传输数据，不可以被连接。广播秤仅负责测定用户的体重和阻抗，不会计算任何体脂数据。
> * App通过蓝牙广播解析到体重和阻抗后，调用SDK算法类AlgorithmSDK中的对应方法，计算出10项体脂数据。。
> * acNumber=0是不带温度的广播秤，acNumber=1是有温度的广播秤。目前SDK仅支持BM15广播秤。


2. 连接秤(link scale)：acNumber=2 或 acNumber=3
> * 连接秤负责测定用户的体重和阻抗，并根据App下发的用户信息计算出10项体脂数据，通过蓝牙传输给App。
> * acNumber=2是不带温度的连接秤，acNumber=3是有温度的连接秤。 目前SDK仅支持1位小数的连接秤，不支持2位小数及0xAE开头的协议。

## 扫描设备列表

```
// SearchDeviceVC.m

@interface SearchDeviceVC () <INBluetoothManagerDelegate>
@end

@implementation SearchDeviceVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([INBluetoothManager shareManager].bleState == CBCentralManagerStatePoweredOn) {
        [INBluetoothManager shareManager].delegate = self;
        [[INBluetoothManager shareManager] startBleScan];
    } else {
        NSLog(@"---Error: BLE not avalible, pls check.");
    }
}


#pragma mark - BluetoothManagerDelegate

- (void)BluetoothManager:(INBluetoothManager *)manager didDiscoverDevice:(DeviceModel *)deviceModel
{

    if (self.isAddPeripheraling == YES) return;
    
    self.isAddPeripheraling = YES;
    
    BOOL willAdd = YES;
    for (DeviceModel *model in self.peripheralArray) //avoid add the same device
    {
        if ([model.deviceAddress isEqualToString:deviceModel.deviceAddress] && [model.deviceName isEqualToString:deviceModel.deviceName])
        {
            willAdd = NO;
        }
    }
    
    if (willAdd) {
        [self.peripheralArray addObject:deviceModel];
        [self.BleTableView reloadData];
    }
    
    self.isAddPeripheraling = NO;
    
}


```


## 广播秤交互流程
* 1.扫描设备列表(参考“扫描设备列表”操作)，根据acNumber=0或acNumber=1筛选出广播秤模型

* 2.设置数据解析类AnalysisBLEDataManager的代理，遵守数据解析协议AnalysisBLEDataManagerDelegate，监听相应的代理方法

```
- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager 
updateMeasureUserInfo:(UserInfoModel *)infoModel;
```

* 3.调用SDK方法[[INBluetoothManager shareManager] handleDataForBroadScale:device];开始处理广播秤数据。

* 4.执行完步骤3操作后，步骤2中代理方法开始回调infoModel(广播秤仅测定体重和阻抗)，加上App获取的用户信息，调用AlgorithmSDK提供的算法 + (AlgorithmModel *)getBodyfatWithWeight:(double)kgWeight adc:(int)adc sex:(AlgUserSex)sex age:(int)age height:(int)height; 计算出10项体脂数据

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

            AlgorithmModel *algModel = [AlgorithmSDK getBodyfatWithWeight:weight adc:adc sex:_appUser.sex age:_appUser.age height:_appUser.height];
            NSLog(@"---BM15 AlgorithmModel: %@",algModel);
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
            
            //refresh
            [self refreshTableView];
            
        } else { //connect scale measure complete
            
        }

    }
    
}
```

* 5.如需要获取 去脂体重、体重控制量等额外的6项身体指标，请调用SDK提供的另外一个算法BfsCalculateSDK中方法计算。

```
    float weight = _currentInfoModel.weightsum/pow(10, _currentInfoModel.weightOriPoint);//6895->68.95
    int sex = _appUser.sex;
    int height = _appUser.height;
    NSString *bfr = [NSString stringWithFormat:@"%.1f",_currentInfoModel.fatRate];
    NSString *rom = [NSString stringWithFormat:@"%.1f％",_currentInfoModel.muscle];
    NSString *pp = [NSString stringWithFormat:@"%.1f％",_currentInfoModel.proteinRate];
    BfsCalculateItem *item = [BfsCalculateSDK getBodyfatItemWithSex:sex height:height weight:weight bfr:bfr rom:rom pp:pp];
    
```


## 连接秤交互流程

* 1.扫描设备列表(参考“扫描设备列表”操作)，根据acNumber=2或acNumber=3筛选出连接秤模型

* 2.设置数据解析类AnalysisBLEDataManager的代理，遵守数据解析协议AnalysisBLEDataManagerDelegate，监听相应的代理方法

```
- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager 
updateBleDataAnalysisStatus:(BleDataAnalysisStatus)bleDataAnalysisStatus;

- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager 
updateMeasureUserInfo:(UserInfoModel *)infoModel;

///If no need offline history function, do not implement this callback
- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager backOfflineHistorys:(NSMutableArray <UserInfoModel *> *)historysMutableArr;

```

* 3.调用SDK方法[[INBluetoothManager shareManager] connectToLinkScale:device];尝试连接该连接秤设备。

* 4.监听数据解析类的工作状态BleDataAnalysisStatus_SyncTimeSuccess回调，即代表连接秤连接成功，完成初始化设置，可接收App交互指令。此时需要切换秤的单位与App保持同步，同步当前即将称重那个用户的信息，同步离线用户列表和请求离线历史记录(如无需离线功能，可忽略)。

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

* 5.执行完步骤3操作后，步骤2中设置的代理方法开始回调体重信息模型infoModel，App对接收的数据进行二次加工，并刷新UI界面。同时需判定测量结束，发送指令更新当前用户及离线用户列表信息。

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

* 6.如需要获取 去脂体重、体重控制量等额外的6项身体指标，请调用SDK提供的另外一个算法BfsCalculateSDK中方法计算。

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


## 版本历史

| 版本号 | 更新时间 | 作者 | 更新信息 |
| --- | --- | --- | --- |
| v1.0 | 2018/9/10 | wz | 初步版本 |
| v1.1 | 2019/02/27 | wz | 新增阻抗测量失败回调及Log开关 |
| v1.2 | 2019/04/25 | wz | 新增BM15算法接口 |
| v1.3 | 2019/08/12 | wz | 优化蓝牙连接 |
| V1.4 | 2019/10/29 | wz | 兼容IOS13系统 |
| V1.5 | 2019/12/20 | wz | 添加离线历史记录功能 |
| V1.5 | 2019/12/20 | wz | 功能更新：<br>1.修改BluetoothManager类名为INBluetoothManager，避免与系统私有API冲突 <br>2.规范AlgorithmSDK和AlgorithmModel类中方法及属性命名 <br>3.新增BfsCalculateSDK算法，可获取额外的计算体脂数据数据 <br>4.自动读取秤的DID <br>5.修复测试发现的bug |


## FAQ

>Q: 如何判断区分当前扫描到的DeviceModel是广播秤还是连接秤？

>A: 根据DeviceModel的acNumber属性值区分：acNumber=0是不带温度的广播秤，acNumber=1是有温度的广播秤。acNumber=2是不带温度的连接秤，acNumber=3是有温度的连接秤。

>Q: 如何判定测量结束？

>A: 根据数据解析类代理方法回调的 UserInfoModel *infoModel属性.measureStatus来判定
>
```
typedef NS_ENUM(NSInteger, MeasureStatus) {
    MeasureStatus_Unstable = 0,
    MeasureStatus_Stable,
    MeasureStatus_Complete,
    MeasureStatus_OfflineHistory,
};
```

>Q: 蓝牙协议支持哪些单位？
>
>A: 单位最多只支持4种（kg，lb，st，斤），具体支持什么单位请参照秤的出厂设置。 



## 技术支持

Wuz

Inet App Manager

inet_support@163.com
