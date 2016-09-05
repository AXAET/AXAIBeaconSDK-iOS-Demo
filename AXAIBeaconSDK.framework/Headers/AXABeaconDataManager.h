//
//  AXABeaconDataManager.h
//  AXABeaconSDK
//
//  Created by AXAET_APPLE on 16/8/31.
//  Copyright © 2016年 axaet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define ServiceUUID     @"FFF0"
#define WriteUUID       @"FFF1"
#define NotifyUUID      @"FFF2"

@interface AXABeaconDataManager : NSObject

/**
 *  singleton method
 *
 *  @return singleton instance
 */
+ (instancetype)sharedManager;

/**
 *  @link - (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
 *  Get battery level from the advertisementData if the advertisementData have the battery level data.
 *
 *  @param advertisementData advertisement data
 *
 *  @return battery level
 */
- (NSNumber *)getBatteryLevelFromAdvertisementData:(NSDictionary *)advertisementData;

/**
 *  @link - (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
 *  Get temperature level from the advertisementData if the advertisementData have the temperature level data.
 *
 *  @param advertisementData advertisement data
 *
 *  @return temperature level
 */
- (NSNumber *)getTemperatureLevelFromAdvertisementData:(NSDictionary *)advertisementData;

/**
 *  @link - (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
 *
 *  Get humidity level from the advertisementData if the advertisementData have the humidity level data.
 *  @param advertisementData advertisement data
 *
 *  @return humidity level
 */
- (NSNumber *)getHumidityLevelFromAdvertisementData:(NSDictionary *)advertisementData;

/**
 *  @link -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
 *
 *  Get proximityUUID from the characteristic which serviceUUID is FFF0 and characteristicUUID is FFF2 after set notify value for peripheral.
 *  @param characteristic characteristic(UUID:FFF2)
 *
 *  @return UUIDString
 */
- (NSString *)getUUIDFromCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  @link -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
 *
 *  Get major from the characteristic which serviceUUID is FFF0 and characteristicUUID is FFF2 after set notify value for peripheral.
 *  @param characteristic characteristic(UUID:FFF2)
 *
 *  @return Major string
 */
- (NSString *)getMajorFromCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  @link -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error 
 *
 *  Get minor from the characteristic which serviceUUID is FFF0 and characteristicUUID is FFF2 after set notify value for peripheral.
 *  @param characteristic characteristic(UUID:FFF2)
 *
 *  @return Minor string
 */
- (NSString *)getMinorFromCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  @link -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
 *
 *  Get power from the characteristic which serviceUUID is FFF0 and characteristicUUID is FFF2 after set notify value for peripheral.
 *  @param characteristic characteristic(UUID:FFF2)
 *
 *  @return power string
 */
- (NSString *)getPowerFromCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  @link -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
 *
 *  Get period(AdvInterval) from the characteristic which serviceUUID is FFF0 and characteristicUUID is FFF2 after set notify value for peripheral.
 *  @param characteristic characteristic(UUID:FFF2)
 *
 *  @return Period string
 */
- (NSString *)getPeriodFromCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  @link -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
 *
 *  receive device password right from the characteristic which serviceUUID is FFF0 and characteristicUUID is FFF2 after valide device password
 *  @param characteristic characteristic(UUID:FFF2)
 *
 *  @return BOOL value
 */
- (BOOL)receiveDevicePasswordRightFromCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  @link -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
 *
 *  Receive device password wrong from the characteristic which serviceUUID is FFF0 and characteristicUUID is FFF2 after valid device password
 *  @param characteristic characteristic
 *
 *  @return BOOL value
 */
- (BOOL)receiveDevicePasswordWrongFromCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  @link -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
 *
 *  Receive device password request from the characteristic which serviceUUID is FFF0 and characteristicUUID is FFF2
 *  @param characteristic characteristic
 *
 *  @return BOOL value
 */
- (BOOL)receiveDevicePasswordRequestFromCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  @link -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
 *  Receive device modify success from the characteristic which serviceUUID is FFF0 and characteristicUUID is FFF2 after this you can reset device
 *  @param characteristic characteristic
 *
 *  @return BOOL value
 */
- (BOOL)receiveDeviceModifySuccessFromCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  @link -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error 
 *
 *  Receive device password modify success from the characteristic which serviceUUID is FFF0 and characteristicUUID is FFF2 when you have modify device password
 *  @param characteristic characteristic
 *
 *  @return BOOL value
 */
- (BOOL)receiveDevicePasswordModifySuccessFromCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  @link -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error 
 *
 *  get device electricity level from the characteristic which serviceUUID is FFF0 and characteristicUUID is FFF2 if the device have notify electricity level by the characteristic, but if the device have not notify electricity level by the characteristic, you will get nothing by this method.
 *  @param characteristic characteristic
 *
 *  @return BOOL value
 */
- (NSString *)getDeviceElectricityLevelFromCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  modify ProximityUUID of beacon which has been connected. it should be call after receive device password right message.
 *
 *  @param proximityUUID beacon's proximityUUID
 *  @param peripheral    peripheral
 */
- (void)writeProximityUUID:(NSString *)proximityUUID toPeripheral:(CBPeripheral *)peripheral;

/**
 *  modify major, minor, power, period of beacon which has been connected. it should be call after receive device password right message.
 *
 *  @param major       beacon's major
 *  @param minor       beacon's minor
 *  @param power       beacon's power
 *  @param advInterval beacon's period
 *  @param peripheral  peripheral
 */
- (void)writeMajor:(NSString *)major withMinor:(NSString *)minor withPower:(NSString *)power withAdvInterval:(NSString *)advInterval toPeripheral:(CBPeripheral *)peripheral;

/**
 *  modify name of beacon which has been connected. it should be call after receive device password right message.
 *
 *  @param name       beacon's name
 *  @param peripheral peripheral
 */
- (void)writeName:(NSString *)name toPeripheral:(CBPeripheral *)peripheral;

/**
 *  when you want to modify parameter of beacon, you should write password before modify parameter of beacon to validate.
 *
 *  @param pwd        beacon's password. the default password is 123456
 *  @param peripheral peripheral
 */
- (void)writePassword:(NSString *)pwd ToPeripheral:(CBPeripheral *)peripheral;

/**
 *  when you have modify parameter you should call this method to reset device. it should be call after receive device password right message.
 *
 *  @param peripheral peripheral
 */
- (void)resetDevice:(CBPeripheral *)peripheral;

/**
 *  you can call this method to modify device password
 *
 *  @param originPassword old password
 *  @param newPassword    new password
 *  @param peripheral     peripheral
 */
- (void)writeModifyPassword:(NSString *)originPassword newPassword:(NSString *)newPassword toPeripheral:(CBPeripheral *)peripheral;

/**
 *  when you have callback - (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error method, you should set notify for peripheral.
 *
 *  @param peripheral peripheral
 */
- (void)setNotifyForPeripheral:(CBPeripheral *)peripheral;

@end


