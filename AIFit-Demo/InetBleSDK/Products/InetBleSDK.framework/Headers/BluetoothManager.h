//
//  InetBleSDK
//
//  Created by iot_wz on 2018/9/1.
//  Copyright © 2018年 iot_wz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class UserInfoModel,DeviceModel;

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


@class BluetoothManager;
@protocol BluetoothManagerDelegate <NSObject>

@optional
- (void)BluetoothManager:(BluetoothManager *)manager didDiscoverDevice:(DeviceModel *)deviceModel;

@optional
- (void)BluetoothManager:(BluetoothManager *)manager didConnectDevice:(DeviceModel *)deviceModel;

@optional
- (void)BluetoothManager:(BluetoothManager *)manager updateCentralManagerState:(BluetoothManagerState)state;

@end



@interface BluetoothManager : NSObject


+ (instancetype)shareManager;

@property (nonatomic, weak) id <BluetoothManagerDelegate> delegate;
@property (nonatomic, assign, readonly) CBCentralManagerState bleState;

- (void)startBleScan;
- (void)stopBleScan;
- (void)closeBleAndDisconnect;

- (void)connectToLinkScale:(DeviceModel *)linkScaleDeviceModel;
- (void)handleDataForBroadScale:(DeviceModel *)broadScaleDeviceModel;

- (void)sendDataToBle:(NSData *)data;

+ (void)enableSDKLogs:(BOOL)enable;
@end
