//
//  ConfigViewController.m
//  AXABeaconSDK
//
//  Created by AXAET_APPLE on 16/8/31.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import "ConfigViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define ProximityUUID           @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"
#define Major                   @"1111"
#define Minor                   @"2222"

@interface ConfigViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLBeaconRegion *region;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UITextField *uuidTextField;
@property (nonatomic, strong) UITextField *majorTextField;
@property (nonatomic, strong) UITextField *minorTextField;
@property (nonatomic, strong) UIButton *advBtn;

@end

@implementation ConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.peripheralManager) {
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    else {
        self.peripheralManager.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.peripheralManager.delegate = nil;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ConfigViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(cell.contentView.frame) - 40, CGRectGetHeight(cell.contentView.frame))];
    switch (indexPath.section) {
        case 0:
            [cell.contentView addSubview:textField];
            textField.text = ProximityUUID;
            textField.adjustsFontSizeToFitWidth = YES;
            self.uuidTextField = textField;
            self.uuidTextField.delegate = self;

            break;
        case 1:
            [cell.contentView addSubview:textField];
            textField.text = Major;
            self.majorTextField = textField;
            self.majorTextField.delegate = self;

            break;
        case 2:
            [cell.contentView addSubview:textField];
            textField.text = Minor;
            self.minorTextField = textField;
            self.minorTextField.delegate = self;

            break;
        case 3:
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(cell.contentView.frame) - 40, CGRectGetHeight(cell.contentView.frame))];
            [button addTarget:self action:@selector(handleStartAdv) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor blueColor];
            [button setTitle:@"start advertisement" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:button];
            self.advBtn = button;
        }

            break;

        default:
            break;
    }

    textField.adjustsFontSizeToFitWidth = YES;

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

        default:
            return @"start advertisement";
            break;
    }
    return nil;
}

- (void)handleStartAdv {
    if ([self.advBtn.backgroundColor isEqual:[UIColor blueColor]]) {
        self.advBtn.backgroundColor = [UIColor greenColor];
        [self.advBtn setTitle:@"stop advertisement" forState:UIControlStateNormal];
    } else {
        self.advBtn.backgroundColor = [UIColor blueColor];
        [self.advBtn setTitle:@"start advertisement" forState:UIControlStateNormal];
    }
    NSLog(@"%@", self.uuidTextField.text);
    [self updateAdvertisedRegion];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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

- (void)updateAdvertisedRegion
{
    if(self.peripheralManager.state < CBPeripheralManagerStatePoweredOn)
    {
        NSString *title = NSLocalizedString(@"Bluetooth must be enabled", @"");
        NSString *message = NSLocalizedString(@"To configure your device as a beacon", @"");
        NSString *cancelButtonTitle = NSLocalizedString(@"OK", @"Cancel button title in configuration Save Changes");
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
        [errorAlert show];

        return;
    }

    [self.peripheralManager stopAdvertising];



        // We must construct a CLBeaconRegion that represents the payload we want the device to beacon.
        NSDictionary *peripheralData = nil;

        self.region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.uuidTextField.text] major:[self.majorTextField.text intValue] minor:[self.minorTextField.text intValue] identifier:@"identifier"];
        peripheralData = [self.region peripheralDataWithMeasuredPower:nil];

        // The region's peripheral data contains the CoreBluetooth-specific data we need to advertise.
        if(peripheralData)
        {
            [self.peripheralManager startAdvertising:peripheralData];
        }

}


@end
