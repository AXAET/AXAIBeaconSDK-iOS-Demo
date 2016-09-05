//
//  BLEViewController.m
//  AXABeaconSDK
//
//  Created by AXAET_APPLE on 16/8/31.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import "BLEViewController.h"
#import <AXAIBeaconSDK/AXAIBeaconSDK.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BeaconModel.h"
#import "DetailViewController.h"

@interface BLEViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource>
{
    DetailViewController *detailViewController;
}

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) AXABeaconDataManager *beaconDataManager;

@property (nonatomic, strong) NSMutableArray *saveScanedBeacons;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation BLEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.beaconDataManager = [AXABeaconDataManager sharedManager];

    [self setUpUI];
}

- (void)setUpUI {
    self.navigationItem.title = @"Tag List";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithTitle:@"update" style:UIBarButtonItemStylePlain target:self action:@selector(pressLeftBar)];
    self.navigationItem.leftBarButtonItem = leftBar;

    [self.view addSubview:self.tableView];

    detailViewController = [DetailViewController new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.centralManager.delegate = nil;
}

- (void)pressLeftBar {
    [self.centralManager stopScan];
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @NO}];
    [self.saveScanedBeacons removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @NO}];
    } else {
        NSLog(@"centralManager state powered off");
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([RSSI intValue] == 127) {
        return;
    }

    // if the beacon advertise battery level, temperature level, humidity level, you can use these method to get them from the advertisementData. not all beacons can advertise them.

    NSNumber *batteryLevel = [self.beaconDataManager getBatteryLevelFromAdvertisementData:advertisementData];
    NSNumber *temperatureLevel = [self.beaconDataManager getTemperatureLevelFromAdvertisementData:advertisementData];
    NSNumber *humidityLevel = [self.beaconDataManager getHumidityLevelFromAdvertisementData:advertisementData];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"peripheral == %@", peripheral];
    NSArray *arr = [self.saveScanedBeacons filteredArrayUsingPredicate:predicate];
    if (arr.count > 0) {
        BeaconModel *model = arr.lastObject;
        model.name = advertisementData[CBAdvertisementDataLocalNameKey];
        model.rssi = RSSI;
        model.isConnectable = [advertisementData[CBAdvertisementDataIsConnectable] boolValue];
        model.batteryLevel = batteryLevel;
        model.temperatureLevel = temperatureLevel;
        model.humidityLevel = humidityLevel;
    } else {
        BeaconModel *model = [[BeaconModel alloc] init];
        model.peripheral = peripheral;
        model.name = advertisementData[CBAdvertisementDataLocalNameKey];
        model.rssi = RSSI;
        model.isConnectable = [advertisementData[CBAdvertisementDataIsConnectable] boolValue];
        model.batteryLevel = batteryLevel;
        model.temperatureLevel = temperatureLevel;
        model.humidityLevel = humidityLevel;
        [self.saveScanedBeacons addObject:model];
    }

    // sort 
    NSArray *sortedArray = [self.saveScanedBeacons sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        BeaconModel *model1 = obj1;
        BeaconModel *model2 = obj2;
        return [model2.rssi compare:model1.rssi];
    }];
    self.saveScanedBeacons = [NSMutableArray arrayWithArray:sortedArray];

    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.saveScanedBeacons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"BLEViewControllCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    } else {
        while (cell.contentView.subviews.lastObject != nil) {
            [cell.contentView.subviews.lastObject removeFromSuperview];
        }
    }

    BeaconModel *model = self.saveScanedBeacons[indexPath.row];
    cell.textLabel.text = model.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (model.batteryLevel) {
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"rssi:%@ BL:%@ TL:%@ HL:%@", model.rssi, model.batteryLevel, model.temperatureLevel, model.humidityLevel];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"rssi:%@", model.rssi];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    BeaconModel *model = self.saveScanedBeacons[indexPath.row];
    detailViewController.beaconModel = model;
    detailViewController.centralManager = self.centralManager;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (UITableView *)tableView {
    if (!_tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSMutableArray *)saveScanedBeacons {
    if (!_saveScanedBeacons) {
        self.saveScanedBeacons = [NSMutableArray array];
    }
    return _saveScanedBeacons;
}

@end
