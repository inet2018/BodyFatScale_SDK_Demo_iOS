//
//  InetBleSDK
//
//  Created by iot_wz on 2018/9/1.
//  Copyright © 2018年 iot_wz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WriteToBLEManager : NSObject


+ (instancetype)shareManager;


/**
 send user info to ble scale

 @param sex         1:Male  2:Female
 @param height      @"177"
 @param age         @"18"
 */
- (void)synchronousUserWithSex:(NSInteger)sex withHeight:(NSString *)height withAge:(NSString *)age;


/**
 set Unit for ble scale

 @param unitNumber  kg:0 lb:1 st:2 斤:3
 */
- (void)write_To_Unit:(NSInteger)unitNumber;


@end

