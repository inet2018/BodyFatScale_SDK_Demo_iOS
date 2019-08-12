//
//  FRK_fatScalesSDK.h
//  FRK_fatScalesSDK
//
//  Created by zhang on 17/2/24.
//  Copyright © 2017年 taolei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlgorithmModel.h"

@interface AlgorithmSDK : NSObject


/**
 BM15算法Algorithm
 */
+ (AlgorithmModel *)getBodyDataFromAlgorithm_1WithWeight:(double)originKgWeight adc:(int)adc sex:(int)sex age:(int)age height:(int)height;




@end
