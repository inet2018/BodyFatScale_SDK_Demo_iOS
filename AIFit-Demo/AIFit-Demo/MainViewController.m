//
//  AIFit-Demo
//
//  Created by iot_wz on 2018/9/1.
//  Copyright © 2018年 iot_wz. All rights reserved.
//

#import "MainViewController.h"

#import "SearchDeviceVC.h"
#import <InetBleSDK/InetBleSDK.h>


@interface MainViewController () <AnalysisBLEDataManagerDelegate, BluetoothManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *connectedDevicesButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sexSegmentedC;
@property (weak, nonatomic) IBOutlet UITextField *ageTextF;
@property (weak, nonatomic) IBOutlet UITextField *heightTextF;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitSegmentedControl;

/**
 * body data show labels
 */
@property (weak, nonatomic) IBOutlet UILabel *weightsumValue;
@property (weak, nonatomic) IBOutlet UILabel *BMIValue;
@property (weak, nonatomic) IBOutlet UILabel *fatRateValue;
@property (weak, nonatomic) IBOutlet UILabel *muscleValue;
@property (weak, nonatomic) IBOutlet UILabel *moistureValue;
@property (weak, nonatomic) IBOutlet UILabel *boneMassValue;
@property (weak, nonatomic) IBOutlet UILabel *BMRValue;
@property (weak, nonatomic) IBOutlet UILabel *visceralFatValue;
@property (weak, nonatomic) IBOutlet UILabel *subcutaneousFatValue;
@property (weak, nonatomic) IBOutlet UILabel *proteinRateValue;
@property (weak, nonatomic) IBOutlet UILabel *physicalAgeValue;
@property (weak, nonatomic) IBOutlet UILabel *AdcValue;
@property (weak, nonatomic) IBOutlet UILabel *tempValue;
@property (weak, nonatomic) IBOutlet UILabel *tipLB;


//@property (nonatomic, assign) float weightFloat;
@property (nonatomic, strong) UserInfoModel *currentInfoModel;
@property (nonatomic, strong) DeviceModel *currentDeviceModel;


@end

@implementation MainViewController

#pragma mark ============ life circle ==============

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeViewEndEditing)];
    [self.view addGestureRecognizer:tap];
}

- (void)makeViewEndEditing {
    [self.view endEditing:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //setDelegate
    [AnalysisBLEDataManager shareManager].infoDelegate = self;
    [BluetoothManager shareManager].delegate = self;
    [BluetoothManager enableSDKLogs:YES]; //open log switch
    
    //reset
    [self resetLBText];
}

-(void)resetLBText {
    self.weightsumValue.text            = @"--.--";
    self.BMIValue.text                  = @"--.--";
    self.fatRateValue.text              = @"--.--";
    self.muscleValue.text               = @"--.--";
    self.moistureValue.text             = @"--.--";
    self.boneMassValue.text             = @"--.--";
    self.subcutaneousFatValue.text      = @"--.--";
    self.BMRValue.text                  = @"--.--";
    self.proteinRateValue.text          = @"--.--";
    self.visceralFatValue.text          = @"--.--";
    self.physicalAgeValue.text          = @"--.--";
    self.AdcValue.text                  = @"--.--";
    self.tempValue.text                 = @"--.--";
    self.tipLB.text                     = @"--.--";
}


#pragma mark ============ click action ==============

- (IBAction)Click_Ble:(id)sender {
    
    SearchDeviceVC *searchVC = [[SearchDeviceVC alloc]init];
    __weak typeof(self) weakSelf = self;
    searchVC.didSelectDeviceBlock = ^(DeviceModel *device) {
        [weakSelf backFromSearchDeviceVC:device];
    };
    [self presentViewController:searchVC animated:YES completion:nil];
}

- (void)backFromSearchDeviceVC:(DeviceModel *)device {
    NSLog(@"---device:%@",device);

    _currentDeviceModel = device;
    
    [self.connectedDevicesButton setTitle:device.deviceAddress forState:UIControlStateNormal];
    
    if (device.acNumber.intValue < 2) { //0、1 is broadcast scale
        [[BluetoothManager shareManager] handleDataForBroadScale:device];
    } else { //2、3 is Link scale
        [[BluetoothManager shareManager] connectToLinkScale:device];
    }
    
}


// click sync user button
- (IBAction)SyncUserInformation:(id)sender {
    
    if (_currentDeviceModel.acNumber.intValue < 2) {
        //broadcast scale do not need to sync user
    } else {
        // must input sex、weight、age
        NSInteger sex = _sexSegmentedC.selectedSegmentIndex == 0 ? 1 : 2;
        [[WriteToBLEManager shareManager] synchronousUserWithSex:sex withHeight:_heightTextF.text withAge:_ageTextF.text];
    }
}



// click change unit segmentedControl
- (IBAction)ChooseUnit:(UISegmentedControl *)Segmented {
    
    if (_currentDeviceModel.acNumber.intValue < 2) {
        //broadcast scale can not receive write command
    } else {
        [[WriteToBLEManager shareManager] write_To_Unit:Segmented.selectedSegmentIndex];
        self.weightsumValue.text = [self getWeightShowStr:_currentInfoModel unit:_unitSegmentedControl.selectedSegmentIndex];
    }
}

#pragma mark ============ BluetoothManagerDelegate ==============
- (void)BluetoothManager:(BluetoothManager *)manager updateCentralManagerState:(BluetoothManagerState)state {
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
- (void)BluetoothManager:(BluetoothManager *)manager didConnectDevice:(DeviceModel *)deviceModel {
    _currentDeviceModel = deviceModel;
}

#pragma mark - AnalysisBLEDataManagerDelegate

- (void)AnalysisBLEDataManager:(AnalysisBLEDataManager *)analysisManager updateBleDataAnalysisStatus:(BleDataAnalysisStatus)bleDataAnalysisStatus {
    switch (bleDataAnalysisStatus) {
        case BleDataAnalysisStatus_SyncTimeSuccess:
        {
            _tipLB.text = @"sync time success";
            
            //then sync user
            [self SyncUserInformation:nil];
            
            break;
        }
        case BleDataAnalysisStatus_SyncTimeFailed:
        {
            _tipLB.text = @"sync time failed";
            break;
        }
        case BleDataAnalysisStatus_SyncUserSuccess:
        {
            _tipLB.text = @"sync current user success";
            break;
        }
        case BleDataAnalysisStatus_SyncUserFailed:
        {
            _tipLB.text = @"sync current user failed";
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

    if (_currentDeviceModel.acNumber.intValue < 2) {//BroadScale
        [self updateLabelsForBroadScale:infoModel];
    } else {
        [self updateLabelsForLinkScale:infoModel]; //link scale
    }
}

- (void)updateLabelsForBroadScale:(UserInfoModel *)infoModel {
    
    _currentInfoModel                   = infoModel;
    self.weightsumValue.text            = [self getWeightShowStr:infoModel unit:_unitSegmentedControl.selectedSegmentIndex];
    self.AdcValue.text                  = [NSString stringWithFormat:@"%.0f",infoModel.newAdc];
    self.tempValue.text                 = [NSString stringWithFormat:@"%.1f°C",infoModel.temperature];
    
#pragma mark ============ test bm15 broadcast scale AlgorithmSDK ==============
    if (_currentInfoModel.newAdc > 0) {
        float weight = _currentInfoModel.weightsum/pow(10, _currentInfoModel.weightOriPoint);//6895->68.95
        float adc = _currentInfoModel.newAdc;
        int sex = _sexSegmentedC.selectedSegmentIndex == 0 ? 1 : 2;
        int age = _ageTextF.text.intValue;
        int height = _heightTextF.text.intValue;
        
        AlgorithmModel *algModel = [AlgorithmSDK getBodyDataFromAlgorithm_1WithWeight:weight adc:adc sex:sex age:age height:height];
        NSLog(@"BM15 AlgorithmModel: %@",algModel);
        _currentInfoModel.fatRate = algModel.BM_BFR.floatValue;
        _currentInfoModel.BMI = algModel.BM_BMI.floatValue;
        _currentInfoModel.moisture = algModel.BM_Water.floatValue;
        _currentInfoModel.muscle = algModel.BM_MuscleRate.floatValue;
        _currentInfoModel.BMR = algModel.BM_BMR.floatValue;
        _currentInfoModel.boneMass = algModel.BM_BoneMass.floatValue;
        _currentInfoModel.visceralFat = algModel.BM_VisFat.floatValue;
        _currentInfoModel.proteinRate = algModel.BM_ProteinRate.floatValue;
        _currentInfoModel.physicalAge = algModel.BM_BodyAge.floatValue;
        _currentInfoModel.subcutaneousFat = algModel.BM_SubFat.floatValue;
        //show this data
        [self updateLabelsForLinkScale:_currentInfoModel];
    }

}

- (void)updateLabelsForLinkScale:(UserInfoModel *)infoModel {

    _currentInfoModel                   = infoModel;
    self.weightsumValue.text            = [self getWeightShowStr:infoModel unit:_unitSegmentedControl.selectedSegmentIndex];
    self.BMIValue.text                  = [NSString stringWithFormat:@"%.1f",infoModel.BMI];
    self.fatRateValue.text              = [NSString stringWithFormat:@"%.1f％",infoModel.fatRate];
    self.muscleValue.text               = [NSString stringWithFormat:@"%.1f％",infoModel.muscle];
    self.moistureValue.text             = [NSString stringWithFormat:@"%.1f％",infoModel.moisture];
    self.boneMassValue.text             = [NSString stringWithFormat:@"%.1f",infoModel.boneMass];
    self.subcutaneousFatValue.text      = [NSString stringWithFormat:@"%.1f％",infoModel.subcutaneousFat];
    self.BMRValue.text                  = [NSString stringWithFormat:@"%.1fkcal",infoModel.BMR];
    self.proteinRateValue.text          = [NSString stringWithFormat:@"%.1f％",infoModel.proteinRate];
    self.visceralFatValue.text          = [NSString stringWithFormat:@"%.0f",infoModel.visceralFat];
    self.physicalAgeValue.text          = [NSString stringWithFormat:@"%.1f",infoModel.physicalAge];
    self.AdcValue.text                  = [NSString stringWithFormat:@"%.0f",infoModel.newAdc];
    self.tempValue.text                 = [NSString stringWithFormat:@"%.1f°C",infoModel.temperature];
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





