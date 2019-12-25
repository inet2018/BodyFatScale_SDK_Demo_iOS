//
//  AIFit-Demo
//
//  Created by iot_wz on 2018/9/1.
//  Copyright © 2018年 iot_wz. All rights reserved.
//

#import "MainViewController.h"

#import "SearchDeviceVC.h"
#import <InetBleSDK/InetBleSDK.h>
#import "AppUser.h"
#import "SetUserViewController.h"

@interface MainViewController () <AnalysisBLEDataManagerDelegate, INBluetoothManagerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton               *connectedDevicesButton;
@property (weak, nonatomic) IBOutlet UILabel                *userInfoLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl     *unitSegmentedControl;

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (nonatomic, strong) NSArray               *itemNameArr;
@property (nonatomic, strong) NSMutableArray        *itemValueArr;

@property (weak, nonatomic) IBOutlet UILabel *tipLB;

@property (nonatomic, strong) UserInfoModel *currentInfoModel;
@property (nonatomic, strong) DeviceModel *targetDeviceModel;

@property (nonatomic, strong) AppUser *appUser;

@end

@implementation MainViewController

- (NSArray *)itemNameArr {
    if (_itemNameArr == nil) {
        _itemNameArr = @[
                         @"weight:",
                         @"BMI:",
                         @"fatRate:",
                         @"muscle:",
                         @"moisture:",
                         @"boneMass:",
                         @"BMR:",
                         @"visceralFat:",
                         @"subcutaneousFat:",
                         @"proteinRate:",
                         @"physicalAge:",
                         @"ADC:",
                         @"temperature:",
                         @"DID:",
                         @"standardWeight:",
                         @"weightControl:",
                         @"fatMass:",
                         @"weightWithoutFat:",
                         @"muscleMass:",
                         @"proteinMass:",
                         @"fatlevel:"
                         ];
    }
    return _itemNameArr;
}


- (NSMutableArray *)itemValueArr {
    if (_itemValueArr == nil) {
        _itemValueArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.itemNameArr.count; i++) {
            [_itemValueArr addObject:@"--.--"];
        }
    }
    return _itemValueArr;
}


#pragma mark ============ life circle ==============

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeViewEndEditing)];
    [self.view addGestureRecognizer:tap];
    
    //set default value
    _appUser = [[AppUser alloc] init];
    _appUser.sex = 1;
    _appUser.age = 25;
    _appUser.height = 175;
    _appUser.weightKg = 0.0;
    _appUser.adc = 0;
    _userInfoLabel.text = [NSString stringWithFormat:@" sex:%d\n age:%d\n height:%d\n weight:%.1f\n adc:%d",_appUser.sex,_appUser.age,_appUser.height,_appUser.weightKg,_appUser.adc];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //reset label
    [self resetLBText];
}

- (void)makeViewEndEditing {
    [self.view endEditing:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //setDelegate
    [AnalysisBLEDataManager shareManager].infoDelegate = self;
    [INBluetoothManager shareManager].delegate = self;
    [INBluetoothManager enableSDKLogs:YES]; //open log switch
    
    
}

-(void)resetLBText {
    self.itemValueArr = nil;
    self.tipLB.text   = @"--.--";
}


#pragma mark ============ click action ==============

- (IBAction)Click_Ble:(id)sender {
    
    SearchDeviceVC *searchVC = [[SearchDeviceVC alloc]init];
    __weak typeof(self) weakSelf = self;
    searchVC.didSelectDeviceBlock = ^(DeviceModel *device) {
        [weakSelf backFromSearchDeviceVC:device];
    };
    searchVC.gobackBlock = ^{
        [weakSelf.connectedDevicesButton setTitle:@"Connect Device" forState:UIControlStateNormal];
    };
    
    [self presentViewController:searchVC animated:YES completion:nil];
}

- (void)backFromSearchDeviceVC:(DeviceModel *)device {
    NSLog(@"---device:%@",device);

    _targetDeviceModel = device;
    
    [self.connectedDevicesButton setTitle:device.deviceAddress forState:UIControlStateNormal];
    
    if (device.acNumber.intValue < 2) { //0、1 is broadcast scale
        [[INBluetoothManager shareManager] handleDataForBroadScale:device];
    } else { //2、3 is Link scale
        [[INBluetoothManager shareManager] connectToLinkScale:device];
    }
    
}


- (IBAction)editUser:(id)sender {
    SetUserViewController *vc = [[SetUserViewController alloc] init];
    vc.user = _appUser;
    __weak typeof(self) weakSelf = self;
    vc.editUserCallBack = ^{
        weakSelf.userInfoLabel.text = [NSString stringWithFormat:@" sex:%d\n age:%d\n height:%d\n weight:%.1f\n adc:%d",weakSelf.appUser.sex,weakSelf.appUser.age,weakSelf.appUser.height,weakSelf.appUser.weightKg,weakSelf.appUser.adc];
        
        [weakSelf syncWeighingUserToBle];
        
        //If no need offline history function, do not call this method
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf syncOfflineUserListToBle];
        });
        
    };
    [self presentViewController:vc animated:YES completion:nil];
}


// click sync user button
- (void)syncWeighingUserToBle {
    
    if (_targetDeviceModel.acNumber.intValue < 2) {
        //broadcast scale do not need to sync user
    } else {
        //connect scale must input sex、weight、age
        
        BLEUser *user = [[BLEUser alloc] init];
        user.userSex = _appUser.sex;
        user.userAge = _appUser.age;
        user.userHeight = _appUser.height;
        [[WriteToBLEManager shareManager] syncWeighingUser:user];
        
    }
}


/// If no need offline history function, do not call this method
- (void)syncOfflineUserListToBle {
    
    if (_targetDeviceModel.acNumber.intValue < 2) {
        //broadcast scale can not receive write command
    } else {
        BLEUser *user = [[BLEUser alloc] init];
        user.userSex = _appUser.sex;
        user.userAge = _appUser.age;
        user.userHeight = _appUser.height;
        user.userWeight = _appUser.weightKg; //note
        user.userAdc = _appUser.adc;         //note
        [[WriteToBLEManager shareManager] sendOfflineUserListToBle:@[user]]; //you can add more than one user to array
    }
    
}

// click change unit segmentedControl
- (IBAction)ChooseUnit:(UISegmentedControl *)Segmented {
    
    if (_targetDeviceModel.acNumber.intValue < 2) {
        //broadcast scale can not receive write command
    } else {
        [[WriteToBLEManager shareManager] write_To_Unit:Segmented.selectedSegmentIndex];
        NSString *weightShow = [self getWeightShowStr:_currentInfoModel unit:_unitSegmentedControl.selectedSegmentIndex];
        [self.itemValueArr replaceObjectAtIndex:0 withObject:weightShow];
    }
}

#pragma mark ============ BluetoothManagerDelegate ==============
- (void)BluetoothManager:(INBluetoothManager *)manager updateCentralManagerState:(BluetoothManagerState)state {
    switch (state) {
        case BluetoothManagerState_PowerOn:
        {
            _tipLB.text = @"BLE open";
            break;
        }
        case BluetoothManagerState_PowerOff:
        {
            _tipLB.text = @"BLE closed";
            break;
        }
        case BluetoothManagerState_Disconnect:
        {
            _tipLB.text = @"BLE Disconnect";
            break;
        }
        default:
            break;
    }
}

//only used for link scale
- (void)BluetoothManager:(INBluetoothManager *)manager didConnectDevice:(DeviceModel *)deviceModel {
    _targetDeviceModel = deviceModel;
}

#pragma mark - AnalysisBLEDataManagerDelegate

- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager updateBleDataAnalysisStatus:(BleDataAnalysisStatus)bleDataAnalysisStatus {
    switch (bleDataAnalysisStatus) {
        case BleDataAnalysisStatus_SyncTimeSuccess:
        {
            _tipLB.text = @"sync time success";
            
            //set unit
            [self ChooseUnit:self.unitSegmentedControl];
            
            //then sync user to be weighing
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self syncWeighingUserToBle];
            });

            //sync offline userlist(If no need offline history function, do not call this method)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self syncOfflineUserListToBle];
            });
            
            //request history (If no need offline history function, do not call this method)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[WriteToBLEManager shareManager] requestOfflineHistory];
            });

            break;
        }
        case BleDataAnalysisStatus_SyncTimeFailed:
        {
            _tipLB.text = @"sync time failed";
            break;
        }
        case BleDataAnalysisStatus_SyncUserSuccess:
        {
            _tipLB.text = @"sync weighing user success";
            
            break;
        }
        case BleDataAnalysisStatus_SyncUserFailed:
        {
            _tipLB.text = @"sync weighing user failed";
            break;
        }
        case BleDataAnalysisStatus_UnstableWeight:
        {
            _tipLB.text = @"measuring...\nUnstable Weight";
            break;
        }
        case BleDataAnalysisStatus_StableWeight:
        {
            _tipLB.text = @"Stable Weight";
            break;
        }
        case BleDataAnalysisStatus_MeasureComplete:
        {
            _tipLB.text = @"measure complete";
            
            break;
        }
        case BleDataAnalysisStatus_AdcError:
        {
            _tipLB.text = @"adc measure failed";
            
            break;
        }
        case BleDataAnalysisStatus_LightOff:
        {
            _tipLB.text = @"your linkScale light off";
            
            break;
        }
        default:
            break;
    }
}

- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager updateMeasureUserInfo:(UserInfoModel *)infoModel {
    NSLog(@"---infoModel:%@",infoModel);
    
    _currentInfoModel = infoModel;
    [self refreshTableView];
    
    if (_currentInfoModel.measureStatus == MeasureStatus_Complete && _currentInfoModel.weightsum > 0 && _currentInfoModel.newAdc > 0) { //Measure Complete
        
        float weight = _currentInfoModel.weightsum/pow(10, _currentInfoModel.weightOriPoint);//6895->68.95
        float adc = _currentInfoModel.newAdc;
        _appUser.weightKg = weight;
        _appUser.adc = adc;
        _userInfoLabel.text = [NSString stringWithFormat:@" sex:%d\n age:%d\n height:%d\n weight:%.1f\n adc:%d",_appUser.sex,_appUser.age,_appUser.height,_appUser.weightKg,_appUser.adc];
        
        if (_targetDeviceModel.acNumber.intValue < 2) { //BroadScale BM15 mesure complete

            AlgorithmModel *algModel = [AlgorithmSDK getBodyfatWithWeight:weight adc:adc sex:_appUser.sex age:_appUser.age height:_appUser.height];
            NSLog(@"---BM15 AlgorithmModel: %@",algModel);
            _currentInfoModel.fatRate = algModel.bfr.floatValue;
            _currentInfoModel.BMI = algModel.bmi.floatValue;
            _currentInfoModel.moisture = algModel.vwc.floatValue;
            _currentInfoModel.muscle = algModel.rom.floatValue;
            _currentInfoModel.BMR = algModel.bmr.floatValue;
            _currentInfoModel.boneMass = algModel.bm.floatValue;
            _currentInfoModel.visceralFat = algModel.uvi.floatValue;
            _currentInfoModel.proteinRate = algModel.pp.floatValue;
            _currentInfoModel.physicalAge = algModel.physicalAge.floatValue;
            _currentInfoModel.subcutaneousFat = algModel.sfr.floatValue;
            
            //refresh
            [self refreshTableView];
            
        } else { //connect scale measure complete
            
            [self syncWeighingUserToBle];
            
            // If no need offline history function, do not call this method
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self syncOfflineUserListToBle];
            });
            
        }

    }
    
}


- (void)refreshTableView {
    
    NSString *weightShow = [self getWeightShowStr:_currentInfoModel unit:_unitSegmentedControl.selectedSegmentIndex];
    [self.itemValueArr replaceObjectAtIndex:0 withObject:weightShow];
    [self.itemValueArr replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"%.1f",_currentInfoModel.BMI]];
    [self.itemValueArr replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%.1f",_currentInfoModel.fatRate]];
    [self.itemValueArr replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%.1f％",_currentInfoModel.muscle]];
    [self.itemValueArr replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"%.1f％",_currentInfoModel.moisture]];
    [self.itemValueArr replaceObjectAtIndex:5 withObject:[NSString stringWithFormat:@"%.1f",_currentInfoModel.boneMass]];
    [self.itemValueArr replaceObjectAtIndex:6 withObject:[NSString stringWithFormat:@"%.1fkcal",_currentInfoModel.BMR]];
    [self.itemValueArr replaceObjectAtIndex:7 withObject:[NSString stringWithFormat:@"%.0f",_currentInfoModel.visceralFat]];
    [self.itemValueArr replaceObjectAtIndex:8 withObject:[NSString stringWithFormat:@"%.1f％",_currentInfoModel.subcutaneousFat]];
    [self.itemValueArr replaceObjectAtIndex:9 withObject:[NSString stringWithFormat:@"%.1f％",_currentInfoModel.proteinRate]];
    [self.itemValueArr replaceObjectAtIndex:10 withObject:[NSString stringWithFormat:@"%.1f",_currentInfoModel.physicalAge]];
    [self.itemValueArr replaceObjectAtIndex:11 withObject:[NSString stringWithFormat:@"%.0f",_currentInfoModel.newAdc]];
    [self.itemValueArr replaceObjectAtIndex:12 withObject:[NSString stringWithFormat:@"%.1f°C",_currentInfoModel.temperature]];
    [self.itemValueArr replaceObjectAtIndex:13 withObject:[NSString stringWithFormat:@"%zd",_targetDeviceModel.DID_number]];
    
    float weight = _currentInfoModel.weightsum/pow(10, _currentInfoModel.weightOriPoint);//6895->68.95
    int sex = _appUser.sex;
    int height = _appUser.height;
    NSString *bfr = [NSString stringWithFormat:@"%.1f",_currentInfoModel.fatRate];
    NSString *rom = [NSString stringWithFormat:@"%.1f％",_currentInfoModel.muscle];
    NSString *pp = [NSString stringWithFormat:@"%.1f％",_currentInfoModel.proteinRate];
    BfsCalculateItem *item = [BfsCalculateSDK getBodyfatItemWithSex:sex height:height weight:weight bfr:bfr rom:rom pp:pp];

    [self.itemValueArr replaceObjectAtIndex:14 withObject:[NSString stringWithFormat:@"%.1fkg",item.standardWeight]];
    [self.itemValueArr replaceObjectAtIndex:15 withObject:[NSString stringWithFormat:@"%.1fkg",item.weightControl]];
    [self.itemValueArr replaceObjectAtIndex:16 withObject:[NSString stringWithFormat:@"%.1fkg",item.fatMass]];
    [self.itemValueArr replaceObjectAtIndex:17 withObject:[NSString stringWithFormat:@"%.1fkg",item.weightWithoutFat]];
    [self.itemValueArr replaceObjectAtIndex:18 withObject:[NSString stringWithFormat:@"%.1fkg",item.muscleMass]];
    [self.itemValueArr replaceObjectAtIndex:19 withObject:[NSString stringWithFormat:@"%.1fkg",item.proteinMass]];
    [self.itemValueArr replaceObjectAtIndex:20 withObject:[NSString stringWithFormat:@"%zd",item.fatlevel]];
    
    [self.tableView reloadData];
}

//If no need offline history function, do not implement this callback
- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager backOfflineHistorys:(NSMutableArray <UserInfoModel *> *)historysMutableArr {
    
    _tipLB.text = [NSString stringWithFormat:@"Got %zd offline historys! check sdk log.",historysMutableArr.count];
    
    for (UserInfoModel *info in historysMutableArr) {
        NSLog(@"---get offline history:\n %@",info);
    }

}

#pragma mark ============ tableView datasource ==============
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemNameArr.count;
}

static NSString * const CellID = @"CellID";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellID];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blueColor];
    }
    
    //赋值
    cell.textLabel.text = self.itemNameArr[indexPath.row];
    cell.detailTextLabel.text = self.itemValueArr[indexPath.row];
    
    return cell;
}


#pragma mark ============ handle weight point ==============

// change weight unit
- (NSString *)getWeightShowStr:(UserInfoModel *)infoModel unit:(NSInteger)unit {
    
    float weight = infoModel.weightsum/pow(10, infoModel.weightOriPoint);//6895->68.95
    NSString *formatStr = [NSString stringWithFormat:@"%%.%df",infoModel.weightKgPoint]; //@"%.1f"
    NSString *showWeight = @"";
    if (unit == 0) {
        formatStr = [formatStr stringByAppendingString:@"kg"]; //@"%.1fkg"
        showWeight = [NSString stringWithFormat:formatStr,weight];
    } else if (unit == 1) {
        formatStr = [formatStr stringByAppendingString:@"lb"]; //@"%.1flb"
        showWeight = [NSString stringWithFormat:formatStr,weight*2.2046226f];
    } else if (unit == 2) {
        showWeight = [self kg2St:weight]; //st(lb/14): **lb:**st
    } else if (unit == 3) {
        formatStr = [formatStr stringByAppendingString:@"斤"]; //@"%.1f斤"
        showWeight = [NSString stringWithFormat:formatStr,weight*2];
    }else {
        formatStr = [formatStr stringByAppendingString:@"kg"]; //@"%.1fkg"
        showWeight = [NSString stringWithFormat:formatStr,weight];
    }
    
    
    return showWeight;
}


- (NSString *)kg2St:(float)kgWeight {
    NSString *oneString = [NSString stringWithFormat:@"%d",(int)(kgWeight*2.2046226f)/14];
    NSString *twoString = [NSString stringWithFormat:@"%d",((int)(kgWeight*2.2046226f)%14)];
    return [NSString stringWithFormat:@"%@:%@st",oneString,twoString];
}



@end





