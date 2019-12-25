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

///only used for offline history, other it is empty
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

/*  For example
 date : 2019-12-23;
 time : 17:22:28;
 bleUser : <BLEUser: 0x2808e0840>;
 weightsum : 727;
 temperature : 24.5;
 BMI : 23.7;
 fatRate : 22.2;
 muscle : 51;
 moisture : 57;
 boneMass : 2.8;
 subcutaneousFat : 19.9;
 BMR : 1549;
 proteinRate : 16.6;
 visceralFat : 7;
 physicalAge : 26;
 newAdc : 580;
 weightOriPoint : 1;
 weightKgPoint : 1;
 weightLbPoint : 1;
 weightStPoint : 1;
 KGgraduation : 1;
 LBgradution : 1;
 Algorithm_number : 1;
 bm15ScaleUnit : 0;
 measureStatus : 2;
 */
