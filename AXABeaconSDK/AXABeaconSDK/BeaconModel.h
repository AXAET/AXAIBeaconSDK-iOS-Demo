//
//  BeaconModel.h
//  AXABeaconSDK
//
//  Created by AXAET_APPLE on 16/8/31.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BeaconModel : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;

/**
 *  beacon name
 */
@property (nonatomic, strong) NSString *name;

/**
 *  connectable
 */
@property (nonatomic, assign) BOOL isConnectable;

/**
 *  signal strength
 */
@property (nonatomic, strong) NSNumber *rssi;

/**
 *  beacon's proximityUUID
 */
@property (nonatomic, strong) NSString *proximityUUID;

/**
 *  beacon's major
 */
@property (nonatomic, strong) NSString *major;

/**
 *  beacon's minor
 */
@property (nonatomic, strong) NSString *minor;

/**
 *  beacon's power
 */
@property (nonatomic, strong) NSString *power;

/**
 *  period
 */
@property (nonatomic, strong) NSString *advInterval;

/**
 *  battery (optional)
 */
@property (nonatomic, strong) NSNumber *batteryLevel;

/**
 *  temperature (optional)
 */
@property (nonatomic, strong) NSNumber *temperatureLevel;

/**
 *  humidity (optional)
 */
@property (nonatomic, strong) NSNumber *humidityLevel;

@end
