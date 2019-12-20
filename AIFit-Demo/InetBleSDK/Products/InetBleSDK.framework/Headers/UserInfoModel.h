//
//  InetBleSDK
//
//  Created by iot_wz on 2018/9/1.
//  Copyright © 2018年 iot_wz. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BLEUser;


typedef NS_ENUM(NSInteger, WeightUnitType) {
    WeightUnitType_KG = 0,
    WeightUnitType_LB,
    WeightUnitType_ST,
    WeightUnitType_JIN,
};

typedef NS_ENUM(NSInteger, MeasureStatus) {
    MeasureStatus_Unstable = 0,
    MeasureStatus_Stable,
    MeasureStatus_Complete,
    MeasureStatus_OfflineHistory,
};

@interface UserInfoModel : NSObject<NSCopying>

//@property (nonatomic, assign) double weightTimeStamp;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, strong) BLEUser *bleUser;


/// weight
@property (nonatomic, assign) float weightsum;

/// TEMP
@property (nonatomic, assign) float temperature;

/// BMI
@property (nonatomic, assign) float BMI;

/// bfr
@property (nonatomic, assign) float fatRate;

/// rom
@property (nonatomic, assign) float muscle;

/// vwc
@property (nonatomic, assign) float moisture;

/// bm
@property (nonatomic, assign) float boneMass;

/// sfr
@property (nonatomic, assign) float subcutaneousFat;

/// bmr
@property (nonatomic, assign) float BMR;

/// pp
@property (nonatomic, assign) float proteinRate;

/// uvi
@property (nonatomic, assign) float visceralFat;

/// bodyAge
@property (nonatomic, assign) float physicalAge;

/// adc
@property (nonatomic, assign) float newAdc;

/// kg origin point
@property (nonatomic, assign) int weightOriPoint;

/// kg show point
@property (nonatomic, assign) int weightKgPoint;

/// lb show point
@property (nonatomic, assign) int weightLbPoint;

/// st show point
@property (nonatomic, assign) int weightStPoint;

/// kg show graduation
@property (nonatomic, assign) int KGgraduation;

/// lb show graduation
@property (nonatomic, assign) int LBgradution;

//algorithm(so far only used for BM15)
@property (nonatomic, assign)    NSInteger Algorithm_number;

/// bm15 broad scale now showing unit
@property (nonatomic, assign) WeightUnitType bm15ScaleUnit;

@property (nonatomic, assign) MeasureStatus measureStatus;

@end

/*
 weightTimeStamp : 1536658457224.777;
 weightsum : 710;
 temperature : 0;
 BMI : 25.2;
 fatRate : 24.9;
 muscle : 40.1;
 moisture : 51.6;
 boneMass : 2.9;
 subcutaneousFat : 16.6;
 BMR : 1842;
 proteinRate : 15.4;
 visceralFat : 9;
 physicalAge : 12;
 newAdc : 480;
 weightOriPoint : 1;
 weightKgPoint : 1;
 weightLbPoint : 1;
 weightStPoint : 0;
 KGgraduation : 1;
 LBgradution : 1;
 */
