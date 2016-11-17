//
//  TBluetooth.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBluetooth.h"
#import <BabyBluetooth.h>

#import "TBLEDefine.h"
#import "TBLEDevice.h"
#import "TBLENotification.h"
#import "TBluetoothTools.h"

@interface TBluetooth ()
@property (nonatomic, strong, readonly) BabyBluetooth *babyBluetooth;/**<babyBluetooth tool*/
@property (nonatomic, strong) NSTimer *timer;
@end


@interface TBluetooth (Tools)
- (void)distillMacAddr:(CBPeripheral *)peri ch:(CBCharacteristic *)ch;
@end


@implementation TBluetooth
@synthesize BLEAvaliable = _BLEAvaliable;
@synthesize devicesDic = _devicesDic;
@synthesize babyBluetooth = _babyBluetooth;

#pragma mark - life cycle
- (id)init {
    if (self = [super init]) {
        _babyBluetooth = [BabyBluetooth shareBabyBluetooth];
        [self cancelConnectingAndConfig];
        [self setupWorkFlow];
        self.autoSearchEnable = NO;
        [self.timer fire];
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

- (void)scanAndConnect:(BOOL)autoSearch {
    DLog(@"开始连接工作,自动搜索:%d", autoSearch);
    _autoSearchEnable = autoSearch;
    [self search];
}

- (void)removeDevice:(TBLEDevice *)device {
    if ([self.devicesDic.allKeys containsObject:device.peri]) {
        [self.devicesDic removeObjectForKey:device.peri];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBLENotiManagerDeviceChanged object:self.devicesDic];
        DLog(@"移除设备:%@", device);
    }
    [self.babyBluetooth cancelPeripheralConnection:device.peri];
}

- (void)stop {
    self.babyBluetooth.stop(1);
    [self.devicesDic removeAllObjects];
}

- (BOOL)connect:(BOOL)connect peri:(CBPeripheral *)peri {
    if (!peri) return NO;
    DLog(@"连接:%d, 设备:%@", connect, peri);
    if (connect) {
        self.babyBluetooth.having(peri).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().begin();
    } else {
        [self.babyBluetooth cancelPeripheralConnection:peri];
    }
    return YES;
}

- (void)eTimer {
    if (self.autoSearchEnable) {
        [self search];
    }
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
    weakify(self);

    [self.babyBluetooth setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        strongify(self);
        switch (central.state) {
            case CBCentralManagerStatePoweredOn:
                DLog(@"电源开启%@", self.devicesDic);
                break;
                
            default:
                DLog(@"电源关闭或者不可用%@", self.devicesDic);
                break;
        }
        _BLEAvaliable = central.state == CBCentralManagerStatePoweredOn;
        [[NSNotificationCenter defaultCenter] postNotificationName:kBLENotiManagerStatusChanged object:nil];
    }];
    
    //只发现名字符合要求的设备，其他的一律忽略
    [self.babyBluetooth setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
         if ([peripheralName isEqualToString:DeviceNameOne] || [peripheralName isEqualToString:DeviceNameTwo]) {
             return YES;
         }
         return NO;
     }];

    // 扫描到设备的委托
    [self.babyBluetooth setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        strongify(self);
        DLog(@"已扫描的设备:%@",peripheral.name);
        if (![self.devicesDic.allKeys containsObject:peripheral]) {
            TBLEDevice *d = [[TBLEDevice alloc] initWithPeri:peripheral];
            [self.devicesDic setObject:d forKey:peripheral];
            [self.devicesDic[peripheral] setValue:advertisementData forKey:@"advertisementData"];
            [self.devicesDic[peripheral] setValue:[NSDate date] forKey:@"discoveryTime"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kBLENotiManagerDeviceChanged object:self.devicesDic];
        }
    }];

    [self.babyBluetooth setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        if ([peripheralName isEqualToString:DeviceNameOne] || [peripheralName isEqualToString:DeviceNameTwo]) {
            return YES;
        }
        return NO;
    }];

    // 连接到设备成功的委托
    [self.babyBluetooth setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        strongify(self);
        DLog(@"连接成功---%@",peripheral.name);
    }];

    // 设备断开连接的委托
    [self.babyBluetooth setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        strongify(self);
        DLog(@"断开%@连接", peripheral.name);
    }];

//     扫描到设备某个 service 下的 characteristic 的委托
    [self.babyBluetooth setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        strongify(self);
        DLog(@"搜索到Characteristics, service:%@", service);
        if ([self.devicesDic.allKeys containsObject:peripheral]) {
            TBLEDevice *device = self.devicesDic[peripheral];
            if (device.dataWagon && [device.dataWagon respondsToSelector:@selector(storeCharacteristicInService:peri:)]) {
                [device.dataWagon storeCharacteristicInService:service peri:peripheral];
            }
        }
    }];

    [self.babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        strongify(self);
        DLog(@"读取到Characteristics:%@, 数据:%@", characteristic, characteristic.value);
        //筛选出可以设备的mac地址
        [self distillMacAddr:peripheral ch:characteristic];
        if ([self.devicesDic.allKeys containsObject:peripheral]) {
            TBLEDevice *device = self.devicesDic[peripheral];
            if (device.dataWagon && [device.dataWagon respondsToSelector:@selector(carryCharacteristic:peri:)]) {
                [device.dataWagon carryCharacteristic:characteristic peri:peripheral];
            }
        }
    }];
}

- (void)search {
    self.babyBluetooth.scanForPeripherals().connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().begin();
}



#pragma mark - getter
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

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:AutoSearchTimeGap target:self selector:@selector(eTimer) userInfo:nil repeats:YES];
    }
    return _timer;
}

@end

@implementation TBluetooth (Tools)
- (void)distillMacAddr:(CBPeripheral *)peri ch:(CBCharacteristic *)ch {
    if ([ch.UUID.UUIDString isEqualToString:MacAddrUUID]) {
        NSString *macAddress = [TBluetoothTools macWithCharacteristicData:ch.value];
        DLog(@"读取到设备mac地址:%@",macAddress);
        if ([self.devicesDic.allKeys containsObject:peri]) {
            [self.devicesDic[peri] setValue:macAddress forKey:@"macAddr"];
        }
    }
}

@end
