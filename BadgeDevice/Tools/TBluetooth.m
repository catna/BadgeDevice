//
//  TBluetooth.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBluetooth.h"
#import <BabyBluetooth.h>
#import <SVProgressHUD.h>

#import "TBluetoothTools.h"
#import "BluetoothReadWriteHelper.h"

@interface TBluetoothDevice ()

@end
@implementation TBluetoothDevice

@end

NSString *const kTBluetoothConnectSuccess = @"kTBluetoothConnectSuccess";
NSString *const kTBluetoothDisConnect = @"kTBluetoothDisConnect";

@interface TBluetooth ()
@property (nonatomic ,strong) BabyBluetooth *babyBluetooth;
@end

@implementation TBluetooth {
    void(^blockUpdateHandler)(struct DeviceData);
    BOOL isNotify;
    struct DeviceData deviceData;
}
@synthesize device = _device;

#pragma mark - life cycle
- (id)init {
    if (self = [super init]) {
        self.babyBluetooth = [BabyBluetooth shareBabyBluetooth];
    }
    return self;
}

#pragma mark - Public methods
+ (instancetype)sharedBluetooth {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (void)connect {
    [self cancelBluetoothConnectingAndConfigConnectSetting];
    [self setupBluetoothWorkFlow];
    [self bluetoothStartConnect];
}

- (void)cancelConnecting {
    [self cancelBluetoothConnectingAndConfigConnectSetting];
}

- (void)readDataWithUpdateHandler:(void (^)(struct DeviceData))handler notify:(BOOL)notify {
    blockUpdateHandler = handler;
    isNotify = notify;
    [self bluetoothStartRead];
}

#pragma mark - private methods
- (void)cancelBluetoothConnectingAndConfigConnectSetting {
    [_babyBluetooth cancelAllPeripheralsConnection];
    // 扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@NO};
    [_babyBluetooth setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}

- (void)setupBluetoothWorkFlow {
    __block typeof(self) weakSelf = self;
    
    // 蓝牙设备开启状态的委托
    [_babyBluetooth setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        switch (central.state) {
            case CBCentralManagerStateUnknown:
                [SVProgressHUD showInfoWithStatus:@"CBCentralManagerStateUnknown"];
                break;
            case CBCentralManagerStateResetting:
                [SVProgressHUD showInfoWithStatus:@"CBCentralManagerStateResetting"];
                break;
            case CBCentralManagerStateUnsupported:
                [SVProgressHUD showInfoWithStatus:@"CBCentralManagerStateUnsupported"];
                break;
            case CBCentralManagerStateUnauthorized:
                [SVProgressHUD showInfoWithStatus:@"CBCentralManagerStateUnauthorized"];
                break;
            case CBCentralManagerStatePoweredOff:
                [SVProgressHUD showInfoWithStatus:@"蓝牙已关闭"];
                break;
            case CBCentralManagerStatePoweredOn:
                [SVProgressHUD showInfoWithStatus:@"蓝牙已打开，开始扫描设备"];
                break;
            default:
                break;
        }
    }];
    
    // 扫描到设备的委托
    [_babyBluetooth setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        NSLog(@"已扫描的设备:%@",peripheral.name);
    }];
    
    // 设置连接设备的过滤器，只连接设备
    [_babyBluetooth setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        if ([peripheralName isEqualToString:@"TI BLE Sensor Tag"] || [peripheralName isEqualToString:@"SensorTag"]) {
            return YES;
        }
        return NO;
    }];
    
    // 连接到设备成功的委托
    [_babyBluetooth setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"连接成功");
        strongSelf.device.name = peripheral.name;
        strongSelf.device.peripheral = peripheral;
        [strongSelf.babyBluetooth AutoReconnect:peripheral];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTBluetoothConnectSuccess object:nil userInfo:nil];
    }];
//    
    // 设备断开连接的委托
    [_babyBluetooth setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开%@连接", peripheral.name);
//        __strong typeof(self) strongSelf = weakSelf;
        [[NSNotificationCenter defaultCenter] postNotificationName:kTBluetoothDisConnect object:nil userInfo:nil];
    }];
//
    // 扫描到设备的 service 的委托
    [_babyBluetooth setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
//        for (CBService *service in peripheral.services) {
//            NSLog(@"CBService, UUID:%@", service.UUID.UUIDString);
//        }
    }];
//
    // 扫描到设备某个 characteristic 的值的委托
    [_babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//        __strong typeof(self) strongSelf = weakSelf;
        // 不需要不断通知时，只读取一次数据
//        if (!strongSelf.notify) {
//            [strongSelf invocateMethodWithCharacterastic:characteristic strongSelf:strongSelf];
//        }
    }];
    
    __block CBCharacteristic *uvDataChara;
    __block CBCharacteristic *thDataChara;
    __block CBCharacteristic *prDataChara;
    
//     扫描到设备某个 service 下的 characteristic 的委托
    [_babyBluetooth setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:@"2A23"]) {
                //                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                //                [peripheral readValueForCharacteristic:characteristic];
                // 找到 UV 的 service
            }
        }
        if ([service.UUID.UUIDString isEqualToString:uvServiceUUID]) {
            for (CBCharacteristic *chara in service.characteristics) {
                // 找到 UV Config 的 characteristic，这里写入 0x01，启动传感器的自动通知
                if ([chara.UUID.UUIDString isEqualToString:uvConfigUUID]) {	                    [strongSelf writeValueForCBPeripheral:peripheral CBCharacteristic:chara];
                }
                
                if ([chara.UUID.UUIDString isEqualToString:uvDataUUID]) {
                    // 找到 UV Data 的 characteristic
                    uvDataChara = chara;
                    if (strongSelf->isNotify) {	// 需要不断通知
                        // 注册 UV 值的通知，获取回调值
                        [strongSelf.babyBluetooth notify:peripheral characteristic:chara block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                            if (strongSelf->blockUpdateHandler) {
                                int v = [BabyToy ConvertDataToInt:characteristics.value];
//                                NSString *str = [NSString stringWithFormat:@"原始data:%@\n设备返回的值是:%x",characteristics.value,v];
                                NSString *uv = [BluetoothReadWriteHelper stringUVWithValue:characteristics.value];
                                NSString *uvLe = [BluetoothReadWriteHelper stringUVLevelWithValue:characteristics.value];
                                strongSelf->deviceData.UVNu = (__bridge CFTypeRef)(uv);
                                strongSelf->deviceData.UVLe = (__bridge CFTypeRef)(uvLe);
                                strongSelf->blockUpdateHandler(strongSelf->deviceData);
                            }
                            
                        }];
                    }
                }
            }
        }
        // 温湿度
        if ([service.UUID.UUIDString isEqualToString:thServiceUUID]) {
            for (CBCharacteristic *chara in service.characteristics) {
                if ([chara.UUID.UUIDString isEqualToString:thConfigUUID]) {
                    [strongSelf writeValueForCBPeripheral:peripheral CBCharacteristic:chara];
                }
                
                if ([chara.UUID.UUIDString isEqualToString:thDataUUID]) {
                    thDataChara = chara;
                    if (strongSelf->isNotify) {	// 需要不断通知
                        // 注册温湿度值的通知，获取回调值
                        [strongSelf.babyBluetooth notify:peripheral characteristic:chara block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                            NSString *temp = [BluetoothReadWriteHelper stringTempWithValue:characteristics.value];
                            NSString *humi = [BluetoothReadWriteHelper stringHumiWithValue:characteristics.value];
                            strongSelf->deviceData.temp = (__bridge CFTypeRef)(temp);
                            strongSelf->deviceData.humi = (__bridge CFTypeRef)(humi);
                            if (strongSelf->blockUpdateHandler) {
                                strongSelf->blockUpdateHandler(strongSelf->deviceData);
                            }
                        }];
                    }
                }
            }
        }
        // 气压
        if ([service.UUID.UUIDString isEqualToString:prServiceUUID]) {
            for (CBCharacteristic *chara in service.characteristics) {
                if ([chara.UUID.UUIDString isEqualToString:prConfigUUID]) {
                    [strongSelf writeValueForCBPeripheral:peripheral CBCharacteristic:chara];
                }
                
                if ([chara.UUID.UUIDString isEqualToString:prDataUUID]) {
                    prDataChara = chara;
                    // 需要不断通知
                    if (strongSelf->isNotify) {
                        // 注册气压值的通知，获取回调值
                        [strongSelf.babyBluetooth notify:peripheral characteristic:chara block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                            
                            
                            if (strongSelf->blockUpdateHandler) {
                                NSString *pres = [BluetoothReadWriteHelper stringPressureWithValue:characteristics.value];
                                NSLog(@"设备的气压值为:%@",pres);
                                strongSelf->deviceData.pres = (__bridge CFTypeRef)(pres);
                                strongSelf->blockUpdateHandler(strongSelf->deviceData);
                            }
                        }];
                    }
                }
            }
        }
    }];
    
    [_babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if ([characteristic.UUID.UUIDString isEqualToString:@"2A23"]) {
            // 只取 System ID
            NSString *macAddress = [TBluetoothTools macWithCharacteristic:characteristic];
            NSLog(@"设备mac地址是:%@",macAddress);
            strongSelf.device.macAddress = macAddress;
        }
    }];
}

- (void)bluetoothStartConnect {
    _babyBluetooth.scanForPeripherals().then.connectToPeripherals().begin();
}

- (void)bluetoothStartRead {
    if (self.device.peripheral) {
        _babyBluetooth.having(self.device.peripheral).connectToPeripherals().discoverServices().then.discoverCharacteristics().and.readValueForCharacteristic().begin();
    } else {
        [self cancelBluetoothConnectingAndConfigConnectSetting];
        [self setupBluetoothWorkFlow];
        _babyBluetooth.scanForPeripherals().connectToPeripherals().discoverServices().then.discoverCharacteristics().and.readValueForCharacteristic().begin();
    }
    
}

/** 先写入 0x01 到 config 的 characteristic 中，之后再去 data 的 characteristic 去读取数据 */
- (void)writeValueForCBPeripheral:(CBPeripheral *)peripheral CBCharacteristic:(CBCharacteristic *)characteristic {
    Byte b = 0x01;
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark - getter
- (TBluetoothDevice *)device {
    if (!_device) {
        _device = [[TBluetoothDevice alloc] init];
    }
    return _device;
}

@end
