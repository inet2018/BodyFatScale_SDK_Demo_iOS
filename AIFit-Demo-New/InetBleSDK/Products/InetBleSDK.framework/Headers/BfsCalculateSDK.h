//
//  FRK_fatScalesSDK.h
//  FRK_fatScalesSDK
//
//  Created by zhang on 17/2/24.
//  Copyright © 2017年 taolei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BfsUserSex) {
    BfsUserSex_Male = 1,
    BfsUserSex_Female = 2,
};


@interface BfsCalculateItem : NSObject

/**
 *  标准体重 standardWeight
 */
@property (nonatomic, assign) double standardWeight;
/**
 * 体重控制量 weightControl
 */
@property (nonatomic, assign) double weightControl;
/**
 *  脂肪量 fatMass
 */
@property (nonatomic, assign) double fatMass;
/**
 *  去脂体重 weightWithoutFat
 */
@property (nonatomic, assign) double weightWithoutFat;
/**
 *  肌肉量  muscleMass
 */
@property (nonatomic, assign) double muscleMass;
/**
 *  蛋白量 proteinMass
 */
@property (nonatomic, assign) double proteinMass;
/**
 *  肥胖等级  fatlevel
 *  1.标准   standard
 *  2.偏瘦   thin
 *  3.偏重   over weight
 *  4.体重不足 insufficient
 *  5.超重    Severely overweight
 */
@property (nonatomic, assign) NSInteger fatlevel;


/** For example
 (double) _standardWeight = 66.5
 (double) _weightControl = 6.1999998092651367
 (double) _fatMass = 16.100000381469727
 (double) _weightWithoutFat = 56.599998474121094
 (double) _muscleMass = 37.099998474121094
 (double) _proteinMass = 12.100000381469727
 (NSInteger) _fatlevel = 1
 */
@end



@interface BfsCalculateSDK : NSObject


/**
 *  According to the bfr / rom / pp in the basic parameters returned by the scale, calculate 7 additional items that the App needs to display 根据秤返回的基本参数中的bfr/rom/pp，计算出App需要额外显示的7个项目
 *@param sex
 *            性别： 男：1 女 2
 * @param height
 *            身高：1~270（CM）
 * @param weight
 *            体重：1~220（KG）
 * @param bfr
 *            体脂率 43.6
 * @param rom
 *            肌肉率 55.2
 * @param pp
 *            蛋白率 25.9
 * @return  BfsCalculateItem
 */
+ (BfsCalculateItem *)getBodyfatItemWithSex:(BfsUserSex)sex height:(NSInteger)height weight:(double)weight bfr:(NSString *)bfr rom:(NSString *)rom pp:(NSString *)pp;


@end
