//
//  InetBleSDK
//
//  Created by iot_wz on 2018/9/1.
//  Copyright © 2018年 iot_wz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DeviceModel : NSObject

@property(nonatomic, copy) NSString *deviceUUIDString;

@property(nonatomic, copy) NSString *deviceName;


/**
 ble scale type:
 0: broadcast
 1: broadcast(temperature)
 2: linkScale
 3: linkScale(temperature)
 */
@property(nonatomic, strong) NSNumber *acNumber;

@property(nonatomic, copy) NSString *deviceAddress;

@property(nonatomic, assign) BOOL deviceIsLight;

//algorithm(so far only used for BM15)
//@property (nonatomic,assign)    NSInteger Algorithm_number;

//DID
@property (nonatomic,assign)    NSInteger DID_number;

/**
 -centralManager:didDiscoverPeripheral:advertisementData:RSSI
 this DeviceModel created base on this peripheral
 */
@property (strong, nonatomic)   CBPeripheral *peripheral;

@end

/*
 deviceUUIDString : CA2A7E77-D709-4F29-1552-AE69BC4A3752;
 deviceName : SWAN;
 acNumber : 2;
 deviceAddress : 03:B3:EC:8F:70:76;
 deviceIsLight : 0;
 Algorithm_number : 0;
 DID_number : 0;
 */
