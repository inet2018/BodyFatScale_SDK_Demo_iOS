//
//  AIFit-Demo
//
//  Created by iot_wz on 2018/9/1.
//  Copyright © 2018年 iot_wz. All rights reserved.
//

#import "SearchDeviceVC.h"
#import <InetBleSDK/InetBleSDK.h>
#import "MainViewController.h"

@interface SearchDeviceVC () <UITableViewDelegate,UITableViewDataSource,BluetoothManagerDelegate>
{
    CGFloat topDis;
}

@property (nonatomic, strong)UITableView *BleTableView;
@property (nonatomic, strong) NSMutableArray *peripheralArray;   
@property (nonatomic, assign) BOOL isAddPeripheraling;



@end

@implementation SearchDeviceVC

#pragma mark - ================= 视图 ==========================
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
    
    [self setupBackButton];
    [self setupStartScanBtn];
    [self setupStopScanBtn];
    
    [self setupTableView];
    
    
  
    if ([BluetoothManager shareManager].bleState == CBCentralManagerStatePoweredOn) {
        [BluetoothManager shareManager].delegate = self;
        [[BluetoothManager shareManager] startBleScan];
    } else {
        NSLog(@"---Error: BLE not avalible, pls check.");
    }
}


-(void)setupBackButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    topDis = (UIScreen.mainScreen.bounds.size.height == 812) ? (34+10) : (20+10);
    btn.frame = CGRectMake(25, topDis, 250, 40);
    [btn setTitle:@"<< BackAndCloseBLE" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
}
-(void)goBack
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[BluetoothManager shareManager] closeBleAndDisconnect];
    }];
}


- (void)setupStartScanBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(25, topDis+40+10, 100, 40);
    [btn setTitle:@"start scan" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(scanPeripheral) forControlEvents:UIControlEventTouchUpInside];
}


- (void)setupStopScanBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(self.view.bounds.size.width-25-100, topDis+40+10, 100, 40);
    [btn setTitle:@"stop scan" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(stopScan) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupTableView {
    _BleTableView = [[UITableView alloc]init];
    _BleTableView.frame = CGRectMake(25, topDis+50+50, self.view.bounds.size.width-50, self.view.bounds.size.height-(topDis+50+50)-20);
    _BleTableView.dataSource = self;
    _BleTableView.delegate = self;
    [self.view addSubview:_BleTableView];
}

- (void)scanPeripheral
{
    [[BluetoothManager shareManager] startBleScan];
}

- (void)stopScan
{
    [[BluetoothManager shareManager] stopBleScan];
}


#pragma mark - BluetoothManagerDelegate

- (void)BluetoothManager:(BluetoothManager *)manager didDiscoverDevice:(DeviceModel *)deviceModel
{

    if (self.isAddPeripheraling == YES) return;
    
    self.isAddPeripheraling = YES;
    
    BOOL willAdd = YES;
    for (DeviceModel *model in self.peripheralArray) //avoid add the same device
    {
        if ([model.deviceAddress isEqualToString:deviceModel.deviceAddress] && [model.deviceName isEqualToString:deviceModel.deviceName])
        {
            willAdd = NO;
        }
    }
    
    if (willAdd) {
        [self.peripheralArray addObject:deviceModel];
        [self.BleTableView reloadData];
    }
    
    self.isAddPeripheraling = NO;
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.peripheralArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AIFitCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AIFitCell"];
    }
    
    DeviceModel *peripheralModel = self.peripheralArray[indexPath.row];
    cell.textLabel.text = peripheralModel.deviceName;
    cell.detailTextLabel.text = peripheralModel.deviceAddress;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DeviceModel *peripheralModel = self.peripheralArray[indexPath.row];

    if (_didSelectDeviceBlock) {
        _didSelectDeviceBlock(peripheralModel);
        //note: just go back, keep ble scan all the time
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}


#pragma mark - Setter and Getter

- (NSMutableArray *)peripheralArray
{
    if (_peripheralArray == nil) {
        _peripheralArray = [[NSMutableArray alloc] init];
    }
    return _peripheralArray;
}

- (void)dealloc
{
    NSLog(@"---class:%@ instance:%p  already dealloc!",self.class,self);
}

@end
