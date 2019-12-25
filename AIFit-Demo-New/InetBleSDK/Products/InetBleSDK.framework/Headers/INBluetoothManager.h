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


@class INBluetoothManager;
@protocol INBluetoothManagerDelegate <NSObject>

@optional
- (void)BluetoothManager:(INBluetoothManager *)manager didDiscoverDevice:(DeviceModel *)deviceModel;

@optional
- (void)BluetoothManager:(INBluetoothManager *)manager didConnectDevice:(DeviceModel *)deviceModel;

@optional
- (void)BluetoothManager:(INBluetoothManager *)manager updateCentralManagerState:(BluetoothManagerState)state;

@end



@interface INBluetoothManager : NSObject

+ (NSString *)sdkVersion;

+ (instancetype)shareManager;

@property (nonatomic, weak) id <INBluetoothManagerDelegate> delegate;
@property (nonatomic, assign, readonly) CBCentralManagerState bleState;

- (void)startBleScan;
- (void)stopBleScan;
- (void)closeBleAndDisconnect;

- (void)connectToLinkScale:(DeviceModel *)linkScaleDeviceModel;
- (void)handleDataForBroadScale:(DeviceModel *)broadScaleDeviceModel;

- (void)sendDataToBle:(NSData *)data;

+ (void)enableSDKLogs:(BOOL)enable;
@end
