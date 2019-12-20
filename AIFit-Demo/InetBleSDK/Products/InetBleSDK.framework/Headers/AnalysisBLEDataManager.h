//
//  InetBleSDK
//
//  Created by iot_wz on 2018/9/1.
//  Copyright © 2018年 iot_wz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class UserInfoModel;


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

@class AnalysisBLEDataManager;

@protocol AnalysisBLEDataManagerDelegate <NSObject>
@optional

- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager updateBleDataAnalysisStatus:(BleDataAnalysisStatus)bleDataAnalysisStatus;

- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager updateMeasureUserInfo:(UserInfoModel *)infoModel;

- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager backOfflineHistorys:(NSMutableArray <UserInfoModel *> *)historysMutableArr;

@end




@interface AnalysisBLEDataManager : NSObject

+ (instancetype)shareManager;
@property (nonatomic, weak) id<AnalysisBLEDataManagerDelegate> infoDelegate;

@end
