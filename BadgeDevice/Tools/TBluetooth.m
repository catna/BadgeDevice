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

NSString *const kTBLENotificationDataUpdate = @"kTBLENotificationDataUpdate";
NSString *const kTBLENotificationMatchSuccess = @"kTBLENotificationMatchSuccess";


@interface TBluetooth ()

@property (nonatomic ,strong) NSDictionary <NSString *,NSArray<NSString *>*>* seConfDataDic;

@property (nonatomic ,strong) NSMutableDictionary <CBPeripheral *,TBLEDevice *> *devicesDic;

/*!
 *	@brief 1.在设备有可供连接的mac地址列表时，且设备的mac地址与列表中的不匹配
 *          2.在设备的可连接列表中仅包含一个空字符串时
 *          以上两种情况外的设备都会被添加到忽略列表中
 */
@property (nonatomic ,strong) NSMutableDictionary <CBPeripheral *,NSString *> *ignoreDic;/**<main ignore dic*/
@property (nonatomic ,strong) NSMutableArray <NSString *> *canConnAddrList;/**<need to ignore mac*/

@property (nonatomic ,strong) NSMutableDictionary <CBPeripheral *,NSDictionary *> *peripheralsAdvertisementData;

@end

@implementation TBluetooth
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
    [self.canConnAddrList removeAllObjects];
    [self.canConnAddrList addObjectsFromArray:macAddrList];
    [self cancelConnectingAndConfig];
    [self setupWorkFlow];
    self.babyBluetooth.scanForPeripherals().then.connectToPeripherals().and.discoverServices().and.discoverCharacteristics().then.readValueForCharacteristic().begin();
}

- (void)setDataNotify:(BOOL)notify {
    if (self.device.peri) {
        for (CBCharacteristic *ch in self.device.characteristicsForData) {
            [self.device.peri setNotifyValue:notify forCharacteristic:ch];
        }
    }
}

- (void)cancelConn {
    if (self.device.peri) {
        [self.babyBluetooth AutoReconnectCancel:self.device.peri];
        [self.device clearAllPropertyData];
    }
}

- (void)clear {
    [self.peripheralsAdvertisementData removeAllObjects];
    [self.canConnAddrList removeAllObjects];
    [self.ignoreDic removeAllObjects];
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

    //只发现名字符合要求的设备，其他的一律忽略
    [_babyBluetooth setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
         if ([peripheralName isEqualToString:DeviceNameOne] || [peripheralName isEqualToString:DeviceNameTwo]) {
             return YES;
         } else {
             return NO;
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
        if ([strongSelf.ignoreDic.allKeys containsObject:peripheral]) {
            NSLog(@"忽略字典里存在这个设备，需要取消这个设备的连接");
            [central cancelPeripheralConnection:peripheral];
            return;
        }
        [strongSelf.devicesDic setObject:[[TBLEDevice alloc] init] forKey:peripheral];
        strongSelf.devicesDic[peripheral].name = peripheral.name;
        strongSelf.devicesDic[peripheral].peri = peripheral;
        strongSelf.devicesDic[peripheral].isConnect = YES;
    }];
//
    // 设备断开连接的委托
    [_babyBluetooth setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开%@连接", peripheral.name);
        __strong typeof(self) strongSelf = weakSelf;
        if ([strongSelf.devicesDic.allKeys containsObject:peripheral]) {
            strongSelf.devicesDic[peripheral].isConnect = NO;
        }
    }];
//
    // 扫描到设备的 service 的委托
    [_babyBluetooth setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        #ifndef DEBUG
        for (CBService *service in peripheral.services) {
           NSLog(@"CBService, UUID:%@", service.UUID.UUIDString);
        }
        #endif
    }];

//     扫描到设备某个 service 下的 characteristic 的委托
    [_babyBluetooth setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf openPeri:peripheral dataGalleryService:service];
    }];

    [_babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if ([characteristic.UUID.UUIDString isEqualToString:MacAddrUUID]) {
            // 只取 System ID
            NSString *macAddress = [TBluetoothTools macWithCharacteristic:characteristic];
            NSLog(@"设备mac地址是:%@",macAddress);
            BOOL matchSuc = NO;
            for (NSString *macStr in strongSelf.canConnAddrList) {
                if ([macAddress isEqualToString:macStr]) {
                    NSLog(@"找到了可以连接的设备");
                    [strongSelf matchedSuccess:&matchSuc p:peripheral addr:macAddress];
                    return;
                }
            }

            if (strongSelf.canConnAddrList.count == 1 && [strongSelf.canConnAddrList[0] isEqualToString:@""]) {
                NSLog(@"没有匹配的mac地址表,但传入参数是空字符串""所以也连接了");
                [strongSelf matchedSuccess:&matchSuc p:peripheral addr:macAddress];
                return;
            }

            if (!matchSuc) {
                NSLog(@"没有在mac地址列表或者空字符串中匹配找到可以连接的设备,断开连接");
                [strongSelf.ignoreDic setObject:macAddress forKey:peripheral];
                [strongSelf.babyBluetooth.centralManager cancelPeripheralConnection:peripheral];
                return;
            }
        }

        NSString *UUIDStr = characteristic.UUID.UUIDString;
        for (NSArray *uuidArr in strongSelf.seConfDataDic.allValues) {
            if ([uuidArr containsObject:UUIDStr]) {
                NSString *dataName;
                if ([UUIDStr isEqualToString:THData]) {
                    dataName = @"温湿度";
                    strongSelf.device.currentRawData.THRawData = characteristic.value;
                } else if ([UUIDStr isEqualToString:UVData]) {
                    dataName = @"紫外线";
                    strongSelf.device.currentRawData.UVRawData = characteristic.value;
                } else if ([UUIDStr isEqualToString:PrData]) {
                    dataName = @"大气压";
                    strongSelf.device.currentRawData.PrRawData = characteristic.value;
                }
                NSLog(@"准备发送通知,读取到%@数据--%@",dataName,characteristic.value);
                [[NSNotificationCenter defaultCenter] postNotificationName:kTBLENotificationDataUpdate object:nil];
            }
        }
    }];
}

/** 先写入 0x01 到 config 的 characteristic 中，之后再去 data 的 characteristic 去读取数据 */
- (void)writeValueForCBPeripheral:(CBPeripheral *)peripheral CBCharacteristic:(CBCharacteristic *)characteristic {
    Byte b = 0x01;
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}
///打开数据通道
- (void)openPeri:(CBPeripheral *)peri dataGalleryService:(CBService *)service{
    for (NSString *key in self.seConfDataDic.allKeys) {
        if ([service.UUID.UUIDString isEqualToString:key]) {
            for (CBCharacteristic *ch in service.characteristics) {
//                NSLog(@"发现了服务%@下的Ch%@",service,ch);
                if ([ch.UUID.UUIDString isEqualToString:self.seConfDataDic[key][1]]) {
                    [self writeValueForCBPeripheral:peri CBCharacteristic:ch];
                }
                if ([ch.UUID.UUIDString isEqualToString:self.seConfDataDic[key][1]]) {
#ifdef DEBUG
                    NSDictionary *nameDic = @{UVService:@"紫外线",THService:@"温湿度",PrService:@"大气压"};
                    NSString *str = nameDic[key];
                    NSLog(@"读取到%@数据--%@",str,ch.value);
#endif
                    [peri setNotifyValue:YES forCharacteristic:ch];
                }

            }
        }
    }
}

- (void)matchedSuccess:(BOOL *)match p:(CBPeripheral *)p addr:(NSString *)addr {
    *match = YES;
    self.device.macAddr = addr;
    [self.babyBluetooth AutoReconnect:p];
    self.device.advertisementData = [self.peripheralsAdvertisementData objectForKey:p];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBLENotificationMatchSuccess object:nil];
}

#pragma mark - getter
- (TBLEDevice *)device {
    if (!_device) {
        _device = [[TBLEDevice alloc] init];
    }
    return _device;
}

- (NSMutableDictionary <CBPeripheral *,TBLEDevice *>*)devicesDic {
    if (!_devicesDic) {
        _devicesDic = [[NSMutableDictionary alloc] init];
    }
    return _devicesDic;
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

- (NSDictionary <NSString *,NSArray <NSString *>*>*)seConfDataDic {
    if (!_seConfDataDic) {
        _seConfDataDic = @{UVService:@[UVConfig,UVData],THService:@[THConfig,THData],PrService:@[PrConfig,PrData]};
    }
    return _seConfDataDic;
}
@end
