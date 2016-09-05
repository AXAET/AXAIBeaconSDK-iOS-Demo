//
//  DetailViewController.h
//  AXABeaconSDK
//
//  Created by AXAET_APPLE on 16/8/31.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconModel.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface DetailViewController : UIViewController

@property (nonatomic,strong) BeaconModel *beaconModel;

@property (nonatomic,strong) CBCentralManager *centralManager;

@end
