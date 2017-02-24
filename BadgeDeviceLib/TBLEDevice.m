//
//  TBLEDevice.m
//  BadgeDevice
//
//  Created by MX on 2017/2/6.
//  Copyright © 2017年 mx. All rights reserved.
//

#import "TBLEDevice.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TBLEDefine.h"
#import "TBLETools.h"
#import "TBLEData.h"
#import "TBLENoti.h"

@interface TBLEDevice () <CBPeripheralDelegate>
/// 用于存储相关联的characteristic
@property (nonatomic, strong) NSMutableDictionary <NSString *, CBCharacteristic *> *dicKeyCharacteristic;
/// 内部保存这些服务的动态字典
@property (nonatomic, strong) NSMutableDictionary <NSString *,CBService *> *dicServices;
@end

@implementation TBLEDevice
@synthesize peri = _peri;
@synthesize data = _data;
@synthesize dataHistory = _dataHistory;

/*!
 *	@brief 初始化方法
 *  @discussion 在这个方法里可以把代理设置为本实例，这样就可以把回调方法写入到这个类里面了
 *	@param peri	依赖的设备
 *	@return 实例
 */
- (id)initWithPeripheral:(CBPeripheral *)peri {
    if (self = [super init]) {
        _peri = peri;
        _peri.delegate = self;
        _powerQ = 0;
        _listen = YES;
        _open = YES;
        _autoReconnect = YES;
    }
    return self;
}

/*!
 *	@brief 向特定的characteristic发送数据
 *
 *	@param data				需要发送的数据
 *	@param characteristic	characteristic
 *
 *	@return 是否通过参数检查
 */
- (BOOL)send:(NSData *)data to:(CBCharacteristic *)characteristic {
    if (data && characteristic && self.peri) {
        [self.peri writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        return YES;
    }
    return NO;
}

- (BOOL)timeCalibration {
    // 找到时间的Characteristic
    CBCharacteristic *timeCh = [self.dicKeyCharacteristic objectForKey:ConnectTimeConfig];
    if (timeCh) {
        return [self send:[TBLETools createCurrentTimeData] to:timeCh];
    }
    return NO;
}

- (BOOL)readHistoryData {
    CBCharacteristic *ch = [self.dicKeyCharacteristic objectForKey:ConnectData];
    if (ch) {
        [self.peri readValueForCharacteristic:ch];
        return YES;
    }
    return NO;
}

#pragma mark - CBPeripheralDelegate
/*!
 *	@brief 接收设备信号更新
 *  @discussion 因为设备的peripheral属性包含的RSSI 在iOS 8以后便废弃了，可能需要在此处添加一个通知来告知设备的信号值已经更新
 *	@param peripheral	设备
 *	@param RSSI			信号强度值
 *	@param error		error
 */
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    _RSSI = RSSI;
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBLENotiStatusChanged object:self];
}

/*!
 *	@brief 发现设备的服务
 *  @discussion 搜索到设备的服务
 *	@param peripheral	设备
 *	@param error        附带的错误
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        [self.dicServices setObject:service forKey:service.UUID.UUIDString];
        DLog(@"BLE-peripheralDidDiscoverServices:%@", service.UUID.UUIDString);
        // 去搜寻设备中service的Characteristic
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/*!
 *	@brief 搜索到设备服务内的Characteristic
 *  @discussion 当设备搜索到响应的Characteristic时，要把这些Characteristic给保存起来，以便之后根据这些Characteristic来发送数据或者取得数据
 *	@param peripheral	设备
 *	@param service		服务
 *	@param error		附带的错误
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *ch in service.characteristics) {
        DLog(@"BLE-didDiscoverCharacteristics:%@ service:%@", ch.UUID, service.UUID);
        [self.dicKeyCharacteristic setObject:ch forKey:ch.UUID.UUIDString];
        // 开始读取设备的相关信息
        [self readDeviceInfo:NO ch:ch];
        if ([ch.UUID.UUIDString isEqualToString:ConnectTimeConfig]) {
            [self timeCalibration];
        }
        // 如果是这些配置,则设置监听状态,注意要在字典中设置过key-Value再执行下列语句
        [self changeNotiOf:peripheral];
        [self changeDataSwitch];
    }
}

/*!
 *	@brief 设备Characteristic的数据更新
 *  @discussion 当设备的数据更新的时候，应该把更新的数据转换成需要的数据，然后暴露给外面访问，并且通知设备的数据已经更新了
 *	@param peripheral			设备
 *	@param characteristic	Characteristic
 *	@param error				error
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // 解析设备信息
    [self readDeviceInfo:YES ch:characteristic];
    
    if ([characteristic.UUID.UUIDString isEqualToString:THData]) {
        self.data.date = [NSDate date];
        self.data.temp = [TBLETools convertTempData:characteristic.value];
        self.data.humi = [TBLETools convertHumiData:characteristic.value];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTBLENotiDataChanged object:self];
    }
    if ([characteristic.UUID.UUIDString isEqualToString:PrData]) {
        self.data.pres = [TBLETools convertPresData:characteristic.value];
    }
    if ([characteristic.UUID.UUIDString isEqualToString:UVData]) {
        self.data.uvNu = [TBLETools convertUVNuData:characteristic.value];
    }
    DLog(@"BLE %@", [self.data represent]);
    
    if ([characteristic.UUID.UUIDString isEqualToString:ConnectData]) {
        DLog(@"BLE history value: %@", characteristic.value);
        NSArray <NSData *>*datas = [TBLETools distillHistoryData:characteristic.value];
        if (datas) {
            self.dataHistory.temp = [TBLETools convertTempData:datas[0]];
            self.dataHistory.humi = [TBLETools convertHumiData:datas[0]];
            self.dataHistory.pres = [TBLETools convertPresData:datas[1]];
            self.dataHistory.uvNu = [TBLETools convertUVNuData:datas[2]];
            self.dataHistory.date = [TBLETools parseHistoryDate:datas[3].bytes];
            const char *battery = datas[4].bytes;
            _powerQ = (short)&battery;
            DLog(@"BLE powerQ:%uld History %@", self.powerQ, [self.dataHistory represent]);
            [[NSNotificationCenter defaultCenter] postNotificationName:kTBLENotiHistoryDataReaded object:self];
            // 在这里形成读取链
            [self readHistoryData];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTBLENotiGetError object:@"历史数据解析出错,查看日志来得到信息"];
        }
    }
}

#pragma mark - private methods
/*!
 *	@brief 变更监听的开关
 *  @discussion 在这个位置设置需要监听的UUID，注意是监听而不是开启
 *	@param peri	需要notify的设备
 */
- (void)changeNotiOf:(CBPeripheral *)peri {
    for (NSString *key in @[THData, UVData, PrData, ConnectData]) {
        CBCharacteristic *ch = [self.dicKeyCharacteristic objectForKey:key];
        if ([ch.UUID.UUIDString isEqualToString:key] && peri && ch) {
            [peri setNotifyValue:self.listen forCharacteristic:ch];
        }
    }
}

/*!
 *	@brief 变更数据通道,所有的字面量数据都是预定义好的
 */
- (void)changeDataSwitch {
    for (NSString *key in @[THConfig, UVConfig, PrConfig]) {
        CBCharacteristic *ch = [self.dicKeyCharacteristic objectForKey:key];
        if (ch) {
            // openData 是否打开数据通道(预定义好的开关数据内容)
            Byte od = self.open ? 0x01 : 0x00;
            NSData *d = [NSData dataWithBytes:&od length:sizeof(od)];
            [self send:d to:ch];
        }
    }
}

/*!
 *	@brief 读取设备信息
 *	@discussion     因为读取设备信息需要先通知peri去读，然后在didRead的方法里去解析
 *	@param parse    是否需要解析
 *  @param ch       需要解析的Characteristic
 */
- (void)readDeviceInfo:(BOOL)parse ch:(CBCharacteristic *)ch {
    if (!parse) {
        [self.peri readValueForCharacteristic:ch];
        return;
    }
    if ([ch.UUID.UUIDString isEqualToString:MacAddrUUID]) {
        _macAddress = [TBLETools macWithCharacteristicData:ch.value];
    }
    if ([ch.UUID.UUIDString isEqualToString:SoftwareVersionUUID]) {
        _firmware = [TBLETools firmwareStringFrom:ch.value];
    }
}

#pragma mark - setter
- (void)setListen:(BOOL)listen {
    _listen = listen;
    [self changeNotiOf:self.peri];
}

- (void)setOpen:(BOOL)open {
    _open = open;
    [self changeDataSwitch];
}

#pragma mark - getter
- (NSMutableDictionary <NSString *,CBCharacteristic *> *)dicKeyCharacteristic {
    if (!_dicKeyCharacteristic) {
        _dicKeyCharacteristic = [[NSMutableDictionary alloc] init];
    }
    return _dicKeyCharacteristic;
}

- (NSDictionary <NSString *,CBService *> *)services {
    return self.dicServices;
}

- (NSMutableDictionary <NSString *,CBService *> *)dicServices {
    if (!_dicServices) {
        _dicServices = [[NSMutableDictionary alloc] init];
    }
    return _dicServices;
}

- (TBLEData *)data {
    if (!_data) {
        _data = [[TBLEData alloc] init];
    }
    return _data;
}

- (TBLEData *)dataHistory {
    if (!_dataHistory) {
        _dataHistory = [[TBLEData alloc] init];
    }
    return _dataHistory;
}

@end
