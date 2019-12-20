//
//  SetUserViewController.h
//  AIFit-Demo
//
//  Created by steven wu on 2019/12/20.
//  Copyright © 2019 wujia121. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppUser;
NS_ASSUME_NONNULL_BEGIN

@interface SetUserViewController : UIViewController

@property (nonatomic, strong)  AppUser *user;

@property (nonatomic, copy) void(^editUserCallBack)(void);

@end

NS_ASSUME_NONNULL_END
