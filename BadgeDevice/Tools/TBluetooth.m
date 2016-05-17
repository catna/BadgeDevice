//
//  TBluetooth.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBluetooth.h"
#import "TBLEDefine.h"
#import "TBLEDevice.h"

#import <BabyBluetooth.h>
#import <SVProgressHUD.h>

#import "TBluetoothTools.h"

// NSString *const kTBluetoothConnectSuccess = @"kTBluetoothConnectSuccess";
// NSString *const kTBluetoothDisConnect = @"kTBluetoothDisConnect";

@interface TBluetooth ()
@property (nonatomic ,strong) NSMutableDictionary <CBPeripheral *,NSString *> *ignoreDic;/**<main ignore dic*/
@property (nonatomic ,strong) NSMutableArray <NSString *> *canConnAddrList;/**<need to ignore mac*/

@property (nonatomic ,strong) NSMutableDictionary <CBPeripheral *,NSDictionary *> *peripheralsAdvertisementData;

@end

@implementation TBluetooth {
    void(^blockUpdateHandler)(struct DeviceData);
    BOOL isNotify;
    struct DeviceData deviceData;
}
@synthesize device        = _device;
@synthesize babyBluetooth = _babyBluetooth;

#pragma mark - life cycle

#pragma mark - Public methods
+ (instancetype)sharedBluetooth {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (void)scanAndConnectWithMacAddrList:(NSArray <NSString *>*)macAddrList {
    [self.canConnAddrList addObjectsFromArray:macAddrList];
}

- (void)readDataWithUpdateHandler:(void (^)(struct DeviceData))handler notify:(BOOL)notify {
    blockUpdateHandler = handler;
    isNotify = notify;
}

#pragma mark - private methods
- (void)cancelConnectingAndConfig {
    [self.babyBluetooth cancelAllPeripheralsConnection];
    // 扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@NO};
    [self.babyBluetooth setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}

- (void)setupWorkFlow {
    __block typeof(self) weakSelf = self;
    [self babyBluetooth];
    // 蓝牙设备开启状态的委托
    [self.babyBluetooth setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
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
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"已扫描的设备:%@",peripheral.name);
        [strongSelf.peripheralsAdvertisementData setObject:advertisementData forKey:peripheral];
    }];

    // 设置连接设备的过滤器，只连接设备
    [_babyBluetooth setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        if ([peripheralName isEqualToString:DeviceNameOne] || [peripheralName isEqualToString:DeviceNameTwo]) {
            return YES;
        }
        return NO;
    }];

    // 连接到设备成功的委托
    [_babyBluetooth setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"连接成功---%@",peripheral.name);
        strongSelf.device.name = peripheral.name;
        strongSelf.device.peri = peripheral;
        [strongSelf.babyBluetooth AutoReconnect:peripheral];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kTBluetoothConnectSuccess object:nil userInfo:nil];
    }];
//
    // 设备断开连接的委托
    [_babyBluetooth setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开%@连接", peripheral.name);
       __strong typeof(self) strongSelf = weakSelf;
       [strongSelf.device clearAllPropertyData];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kTBluetoothDisConnect object:nil userInfo:nil];
    }];
//
    // 扫描到设备的 service 的委托
    [_babyBluetooth setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
//        for (CBService *service in peripheral.services) {
//            NSLog(@"CBService, UUID:%@", service.UUID.UUIDString);
//        }
    }];

//     扫描到设备某个 service 下的 characteristic 的委托
    [_babyBluetooth setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if ([service.UUID.UUIDString isEqualToString:UVService]) {
            for (CBCharacteristic *chara in service.characteristics) {
                // 找到 UV Config 的 characteristic，这里写入 0x01，启动传感器的自动通知
                if ([chara.UUID.UUIDString isEqualToString:UVConfig]) {	                    [strongSelf writeValueForCBPeripheral:peripheral CBCharacteristic:chara];
                }

                if ([chara.UUID.UUIDString isEqualToString:UVData]) {
                }
            }
        }
    }];

    [_babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if ([characteristic.UUID.UUIDString isEqualToString:MacAddrUUID]) {
            // 只取 System ID
            NSString *macAddress = [TBluetoothTools macWithCharacteristic:characteristic];
            NSLog(@"设备mac地址是:%@",macAddress);
            strongSelf.device.macAddr = macAddress;
        }
    }];
}

- (void)bluetoothStartConnect {
    _babyBluetooth.scanForPeripherals().then.connectToPeripherals().begin();
}

/** 先写入 0x01 到 config 的 characteristic 中，之后再去 data 的 characteristic 去读取数据 */
- (void)writeValueForCBPeripheral:(CBPeripheral *)peripheral CBCharacteristic:(CBCharacteristic *)characteristic {
    Byte b = 0x01;
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark - getter
- (TBLEDevice *)device {
    if (!_device) {
        _device = [[TBLEDevice alloc] init];
    }
    return _device;
}

- (BabyBluetooth *)babyBluetooth {
    if (!_babyBluetooth) {
        _babyBluetooth = [BabyBluetooth shareBabyBluetooth];
    }
    return _babyBluetooth;
}

- (NSMutableArray <NSString *>*)canConnAddrList {
    if (!_canConnAddrList) {
        _canConnAddrList = [[NSMutableArray alloc] init];
    }
    return _canConnAddrList;
}

- (NSMutableDictionary <CBPeripheral *,NSString *> *)ignoreDic {
    if (!_ignoreDic) {
        _ignoreDic = [[NSMutableDictionary alloc] init];
    }
    return _ignoreDic;
}

- (NSMutableDictionary <CBPeripheral *,NSDictionary *> *)peripheralsAdvertisementData {
    if (!_peripheralsAdvertisementData) {
        _peripheralsAdvertisementData = [[NSMutableDictionary alloc] init];
    }
    return _peripheralsAdvertisementData;
}
@end
