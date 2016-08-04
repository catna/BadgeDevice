//
//  TBLEDevice.h
//  BadgeDevice
//
//  Created by MX on 16/5/17.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral,CBCharacteristic;

@interface TBLEDeviceRawData : NSObject
@property (nonatomic ,strong) NSData *UVRawData;/**< 紫外线数据*/
@property (nonatomic ,strong) NSData *THRawData;/**< 温湿度数据*/
@property (nonatomic ,strong) NSData *PrRawData;/**< 大气压数据*/

@property (nonatomic ,strong, readonly) NSString *UVLe;
@property (nonatomic ,strong, readonly) NSString *Peri;
@property (nonatomic ,strong, readonly) NSString *Temp;
@property (nonatomic ,strong, readonly) NSString *Humi;
@end

@interface TBLEDevice : NSObject
@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,copy) NSString *macAddr;
@property (nonatomic ,strong) CBPeripheral *peri;

@property (nonatomic ,strong) NSDictionary *advertisementData;/**< ad*/
@property (nonatomic ,strong) NSMutableArray <CBCharacteristic *>*characteristicsForData;

@property (nonatomic ,assign ,readonly) BOOL isConnect;
- (void)setConnectStatus:(BOOL)connect;

@property (nonatomic ,strong) TBLEDeviceRawData *currentRawData;/**< 当前数据*/
- (void)clearAllPropertyData;
@end
