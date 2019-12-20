//
//  AppUser.h
//  AIFit-Demo
//
//  Created by steven wu on 2019/12/19.
//  Copyright © 2019 wujia121. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppUser : NSObject


@property (nonatomic, assign) float weightKg;
/**Be Noted:
 male: 1 female: 2
 */
@property (nonatomic, assign) int sex;
@property (nonatomic, assign) int age;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int adc;

@end

NS_ASSUME_NONNULL_END
