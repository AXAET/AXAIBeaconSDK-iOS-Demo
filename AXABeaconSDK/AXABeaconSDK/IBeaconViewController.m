//
//  IBeaconViewController.m
//  AXABeaconSDK
//
//  Created by AXAET_APPLE on 16/8/31.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import "IBeaconViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface IBeaconViewController ()<UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *beacons;

@property (nonatomic, strong) NSMutableDictionary *rangeRegions;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) UITableView *tableview;

@end

@implementation IBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.beacons = [[NSMutableDictionary alloc] init];
    [self.view addSubview:self.tableview];

    [self initLocationManager];
    self.rangeRegions = [[NSMutableDictionary alloc] init];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"] identifier:@"com.axaet.www"];
    self.rangeRegions[region] = [NSArray array];
}

- (void)initLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];

    // set delegate to current Controller
    self.locationManager.delegate = self;

    // If the NSLocationAlwaysUsageDescription key is not specified in your Info.plist, this method will do nothing, as your app will be assumed not to support Always authorization.
    [self.locationManager requestAlwaysAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        for (CLBeaconRegion *region in self.rangeRegions) {
            [self.locationManager startRangingBeaconsInRegion:region];
            // also you can use -startMonitoringForRegion: method to monitor the region
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    self.rangeRegions[region] = beacons;
    [self.beacons removeAllObjects];

    NSMutableArray *allBeacons = [NSMutableArray array];
    for (NSArray *regionResult in [self.rangeRegions allValues]) {
        [allBeacons addObjectsFromArray:regionResult];
    }

    for (NSNumber *range in @[@(CLProximityUnknown), @(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)]) {
        NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
        if ([proximityBeacons count]) {
            self.beacons[range] = proximityBeacons;
        }
    }

    [self.tableview reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.beacons.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionValues = [self.beacons allValues];
    return [sectionValues[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    NSArray *sectionKeys = [self.beacons allKeys];

    NSNumber *sectionKey = sectionKeys[section];

    switch([sectionKey integerValue])
    {
        case CLProximityImmediate:
            title = NSLocalizedString(@"Immediate", @"Immediate section header title");
            break;

        case CLProximityNear:
            title = NSLocalizedString(@"Near", @"Near section header title");
            break;

        case CLProximityFar:
            title = NSLocalizedString(@"Far", @"Far section header title");
            break;

        default:
            title = NSLocalizedString(@"Unknown", @"Unknown section header title");
            break;
    }

    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }

    NSNumber *sectionKey = [self.beacons allKeys][indexPath.section];
    CLBeacon *beacon = self.beacons[sectionKey][indexPath.row];
    cell.textLabel.text = [beacon.proximityUUID UUIDString];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    NSString *str;
    switch (beacon.proximity) {
        case CLProximityNear:
            str = @"Near";
            break;
        case CLProximityFar:
            str = @"Far";
            break;
        case CLProximityUnknown:
            str = @"Unknown";
            break;
        case CLProximityImmediate:
            str = @"Immediate";
            break;

        default:
            break;
    }

    // if beacon.rssi is 0, it means it's unable to get the signal strength.
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Proximity:%@ RSSI:%ld Major:%@ Minor:%@ Acc:%.2fm", str, beacon.rssi, beacon.major, beacon.minor, beacon.accuracy];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableView *)tableview {
    if (!_tableview) {
        self.tableview = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.tableFooterView = [UIView new];
    }
    return _tableview;
}
@end
