//
//  InetBleSDK
//
//  Created by iot_wz on 2018/9/1.
//  Copyright © 2018年 iot_wz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEUser : NSObject


/**
 eg:  male:1, femail: 2
 */
@property (nonatomic, assign) int userSex;


/**
 eg: 26
 */
@property (nonatomic, assign) int userAge;

/**
 eg: 175
 */
@property (nonatomic, assign) int userHeight;

/**
 eg: 56.5kg
 */
@property (nonatomic, assign) float userWeight;

/**
 eg: 560
 */
@property (nonatomic, assign) int userAdc;

@end
