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
@property (nonatomic,copy)        NSString *BM_BFR; //body fat
@property (nonatomic,copy)        NSString *BM_Water; //water
@property (nonatomic,copy)        NSString *BM_MuscleRate; //muscle rate
@property (nonatomic,copy)        NSString *BM_BoneMass; //bone weight
@property (nonatomic,copy)        NSString *BM_ProteinRate; //protein rate
@property (nonatomic,copy)        NSString *BM_BMR; //bmr
@property (nonatomic,copy)        NSString *BM_VisFat; //Visceral fat index
@property (nonatomic,copy)        NSString *BM_SubFat; //Subcutaneous fat index
@property (nonatomic,copy)         NSString *BM_BodyAge;//body age

@property (nonatomic,copy)        NSString *BM_StanWeight; //standard weight
@property (nonatomic,copy)        NSString *BM_WeightControl; //weight control
@property (nonatomic,copy)        NSString *BM_Fat; //body fat mass
@property (nonatomic,copy)        NSString *BM_OutFat; //weight without fat
@property (nonatomic,copy)        NSString *BM_Muscle; //muscle mass
@property (nonatomic,copy)        NSString *BM_Protein; //protein mass



@end
