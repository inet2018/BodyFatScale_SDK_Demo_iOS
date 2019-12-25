//
//  SetUserViewController.m
//  AIFit-Demo
//
//  Created by steven wu on 2019/12/20.
//  Copyright © 2019 wujia121. All rights reserved.
//

#import "SetUserViewController.h"
#import "AppUser.h"
#import <InetBleSDK/InetBleSDK.h>

@interface SetUserViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl     *sexSegmentedC;
@property (weak, nonatomic) IBOutlet UITextField            *ageTextF;
@property (weak, nonatomic) IBOutlet UITextField            *heightTextF;

@end

@implementation SetUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sexSegmentedC.selectedSegmentIndex = self.user.sex == 1 ? 0 : 1;
    _ageTextF.text = [NSString stringWithFormat:@"%d",self.user.age];
    _heightTextF.text = [NSString stringWithFormat:@"%d",self.user.height];
    
}


- (IBAction)saveUserInfo:(id)sender {
    _user.sex = _sexSegmentedC.selectedSegmentIndex == 0 ? 1 : 2; //male:1 female:2
    _user.age = _ageTextF.text.intValue;
    _user.height = _heightTextF.text.intValue;
    if (_editUserCallBack) {
        _editUserCallBack();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
