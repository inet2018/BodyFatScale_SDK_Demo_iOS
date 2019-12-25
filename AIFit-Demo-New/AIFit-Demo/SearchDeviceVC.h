//
//  AIFit-Demo
//
//  Created by iot_wz on 2018/9/1.
//  Copyright © 2018年 iot_wz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceModel;
@interface SearchDeviceVC : UIViewController

@property (nonatomic, copy) void(^didSelectDeviceBlock)(DeviceModel *device);

@property (nonatomic, copy) void(^gobackBlock)(void);

@end
