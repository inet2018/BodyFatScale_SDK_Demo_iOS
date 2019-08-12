//
//  FatScalesModel.h
//  FRK_fatScalesSDK
//
//  Created by zhang on 17/2/24.
//  Copyright © 2017年 taolei. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 BM15算法AlgorithmModel
 */
@interface AlgorithmModel : NSObject

@property (nonatomic,copy)        NSString *BM_BMI; //bmi
@property (nonatomic,copy)        NSString *BM_BFR; //体脂率
@property (nonatomic,copy)        NSString *BM_Water; //水份
@property (nonatomic,copy)        NSString *BM_MuscleRate; //肌肉率
@property (nonatomic,copy)        NSString *BM_BoneMass; //骨量
@property (nonatomic,copy)        NSString *BM_ProteinRate; //蛋白率
@property (nonatomic,copy)        NSString *BM_BMR; //基础代谢率
@property (nonatomic,copy)        NSString *BM_VisFat; //内脏脂肪指数
@property (nonatomic,copy)        NSString *BM_SubFat; //皮下脂肪
@property (nonatomic,copy)         NSString *BM_BodyAge;//身体年龄

@property (nonatomic,copy)        NSString *BM_StanWeight; //标准体重
@property (nonatomic,copy)        NSString *BM_WeightControl; //体重控制量
@property (nonatomic,copy)        NSString *BM_Fat; //脂肪量
@property (nonatomic,copy)        NSString *BM_OutFat; //去脂体重
@property (nonatomic,copy)        NSString *BM_Muscle; //肌肉量
@property (nonatomic,copy)        NSString *BM_Protein; //蛋白量



@end
