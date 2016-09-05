# AXAIBeaconSDK-iOS-Demo
AXAIBeaconSDK-iOS-Demo

- The SDK provides some interfaces:
    - analyze advertisementData of iBeacon.(if the iBeacon advertise battery, temperature, humity data in advertisementData, it can get these data from advertisementData).
    - write data to characteristic (service's UUID is @"FFF0", characteristic's UUID is @"FFF1"). (sometimes you want to modify the uuid, or major, or minor, or power, or period, or name, or password and so on, you can use these interfaces to meet your ideas).
    - receive data from characteristic(notify, service's UUID is @"FFF0", characteristic's UUID is @"FFF2"). (when you have discover this characteristic, you can set notify for it and then, it will update value from callback method. you can get some data like uuid, major, minor, power, period. also when you have write data like send password, you will receive data validate passwrod is correct or not from this characteristic).
