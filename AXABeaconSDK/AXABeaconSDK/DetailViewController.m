//
//  DetailViewController.m
//  AXABeaconSDK
//
//  Created by AXAET_APPLE on 16/8/31.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import "DetailViewController.h"
#import <AXAIBeaconSDK/AXAIBeaconSDK.h>


@interface DetailViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *uuidTextField;
@property (nonatomic, strong) UITextField *majorTextField;
@property (nonatomic, strong) UITextField *minorTextField;
@property (nonatomic, strong) UITextField *powerTextField;
@property (nonatomic, strong) UITextField *advInteralTextField;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *pswTextField;
@property (nonatomic, strong) UIButton *resetBtn;
@property (nonatomic, strong) UIButton *modifyBtn;

@property (nonatomic, strong) AXABeaconDataManager *beaconDataManager;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.tableView];

    self.beaconDataManager = [AXABeaconDataManager sharedManager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"connecting";
    self.centralManager.delegate = self;
    [self.centralManager connectPeripheral:self.beaconModel.peripheral options:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.centralManager.delegate = nil;
}

- (void)handleWriteAndReset:(UIButton *)sender {
    if (sender.tag) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"modify password" message:@"password will change password 123456 to 456789" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView show];
    } else {
        if ([self.resetBtn.backgroundColor isEqual:[UIColor blueColor]]) {
            self.resetBtn.backgroundColor = [UIColor greenColor];
        } else {
            self.resetBtn.backgroundColor = [UIColor blueColor];
        }

        // before you modify proximityUUId, major, minor and so on , you must write password to beacon to validate you authorision 
        [self.beaconDataManager writePassword:self.pswTextField.text ToPeripheral:self.beaconModel.peripheral];
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // modify password of beacon
        [self.beaconDataManager writeModifyPassword:@"123456" newPassword:@"456789" toPeripheral:self.beaconModel.peripheral];
    }
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}


#pragma mark - CoreBluetooth
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {

}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"%s", __func__);
    self.navigationItem.title = @"connected";
    if ([self.beaconModel.peripheral isEqual:peripheral]) {
        self.beaconModel.peripheral.delegate = self;
        [self.beaconModel.peripheral discoverServices:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%s", __func__);
    self.navigationItem.title = @"disconnected";
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"%s", __func__);
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"%s", __func__);
    [self.beaconDataManager setNotifyForPeripheral:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%@", characteristic.value);

    // you can get some data from the characteristic by our SDK API, note: not all beacons have these data
    if ([self.beaconDataManager getUUIDFromCharacteristic:characteristic]) {
        self.beaconModel.proximityUUID = [self.beaconDataManager getUUIDFromCharacteristic:characteristic];
    }
    if ([self.beaconDataManager getMajorFromCharacteristic:characteristic]) {
        self.beaconModel.major = [self.beaconDataManager getMajorFromCharacteristic:characteristic];
    }
    if ([self.beaconDataManager getMinorFromCharacteristic:characteristic]) {
        self.beaconModel.minor = [self.beaconDataManager getMinorFromCharacteristic:characteristic];
    }
    if ([self.beaconDataManager getPowerFromCharacteristic:characteristic]) {
        self.beaconModel.power = [self.beaconDataManager getPowerFromCharacteristic:characteristic];
    }
    if ([self.beaconDataManager getPeriodFromCharacteristic:characteristic]) {
        self.beaconModel.advInterval = [self.beaconDataManager getPeriodFromCharacteristic:characteristic];
    }

    // after you receive device password message, you can modify proximityUUID or major, minor, power, period... of the beacon. then reset device.
    if ([self.beaconDataManager receiveDevicePasswordRightFromCharacteristic:characteristic]) {
        [self.beaconDataManager writeProximityUUID:self.uuidTextField.text toPeripheral:self.beaconModel.peripheral];
        [self.beaconDataManager writeMajor:self.majorTextField.text withMinor:self.minorTextField.text withPower:self.powerTextField.text withAdvInterval:self.advInteralTextField.text toPeripheral:self.beaconModel.peripheral];
        [self.beaconDataManager resetDevice:self.beaconModel.peripheral];
    }


    if ([self.beaconDataManager receiveDevicePasswordWrongFromCharacteristic:characteristic]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"password is wrong" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [self.centralManager cancelPeripheralConnection:self.beaconModel.peripheral];
    }
    if ([self.beaconDataManager receiveDevicePasswordModifySuccessFromCharacteristic:characteristic]) {
        [self.beaconDataManager resetDevice:self.beaconModel.peripheral];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"DetailViewControllCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    } else {
        while (cell.contentView.subviews.lastObject != nil) {
            [cell.contentView.subviews.lastObject removeFromSuperview];
        }
    }

    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(cell.contentView.frame) - 40, CGRectGetHeight(cell.contentView.frame))];
    switch (indexPath.section) {
        case 0:
            [cell.contentView addSubview:textField];
            textField.text = self.beaconModel.proximityUUID;
            self.uuidTextField = textField;
            self.uuidTextField.delegate = self;

            break;
        case 1:
            [cell.contentView addSubview:textField];
            textField.text = self.beaconModel.major;
            self.majorTextField = textField;
            self.majorTextField.delegate = self;

            break;
        case 2:
            [cell.contentView addSubview:textField];
            textField.text = self.beaconModel.minor;
            self.minorTextField = textField;
            self.minorTextField.delegate = self;

            break;
        case 3:
            [cell.contentView addSubview:textField];
            textField.text = self.beaconModel.power;
            self.powerTextField = textField;
            self.powerTextField.delegate = self;

            break;
        case 4:
            [cell.contentView addSubview:textField];
            textField.text = self.beaconModel.advInterval;
            self.advInteralTextField = textField;
            self.advInteralTextField.delegate = self;

            break;
        case 5:
            [cell.contentView addSubview:textField];
            textField.text = self.beaconModel.name;
            self.nameTextField = textField;
            self.nameTextField.delegate = self;

            break;
        case 6:
            [cell.contentView addSubview:textField];
            self.pswTextField = textField;
            self.pswTextField.delegate = self;

            break;
        case 7:
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(cell.contentView.frame) - 40, CGRectGetHeight(cell.contentView.frame))];
            button.tag = 0;
            [button addTarget:self action:@selector(handleWriteAndReset:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor blueColor];
            [button setTitle:@"reset device" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:button];
            self.resetBtn = button;
        }

            break;
        case 8:
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(cell.contentView.frame) - 40, CGRectGetHeight(cell.contentView.frame))];
            button.tag = 1;
            [button addTarget:self action:@selector(handleWriteAndReset:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor blueColor];
            [button setTitle:@"modify password" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:button];
            self.modifyBtn = button;
        }

            break;

        default:
            break;
    }

    cell.textLabel.adjustsFontSizeToFitWidth = YES;


    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"proximityUUID";
            break;
        case 1:
            return @"major (0 ~ 65565)";
            break;
        case 2:
            return @"minor (0 ~ 65565)";
            break;
        case 3:
            return @"power (can be 0(0dbm) 1(-6dbm) 2(-23dbm))";
            break;
        case 4:
            return @"advInterval (100 ~ 10000)";
            break;
        case 5:
            return @"name";
            break;
        case 6:
            return @"password(pBeacon_n must add password, ibeacon not need)";
            break;
        case 7:
            return @"write value and reset";
            break;
        case 8:
            return @"modify password 123456 to 456789";
            break;


        default:
            return @"write value and reset";
            break;
    }
    return nil;
}

- (UITableView *)tableView {
    if (!_tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

@end
