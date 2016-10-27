//
//  TBLEDevice.h
//  BadgeDevice
//
//  Created by MX on 16/5/17.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBPeripheral,CBCharacteristic;
@class TBLEDeviceRawData, TBLEDeviceDistill;

@interface TBLEDevice : NSObject
@property (nonatomic ,strong) NSDictionary *advertisementData;/**< ad*/

@property (nonatomic ,copy, readonly) NSString *macAddr;
- (void)setMacAddr:(NSString *)macAddr;
@property (nonatomic, strong) void (^macAddressReaded)(NSString *macAddress);

@property (nonatomic ,strong) CBPeripheral *peri;
@property (nonatomic ,strong) NSMutableArray <CBCharacteristic *>*characteristicsForData;

/*!
 *	@brief 这个是设备的连接状态，只是在连接成功或者连接失败的时候变化，外部最好不要随便修改它的数据
 */
@property (nonatomic ,assign ,readonly) BOOL isConnect;
- (void)setConnectStatus:(BOOL)connect;
/*!
 *	@brief 当连接状态变化时的回调
 */
@property (nonatomic, strong) void (^connectStatusChanged)(BOOL isConnect);

/*!
 *	@brief 这个是设备是否属于手机，并且有权限重新连接的一个凭证，在网络端申请进行一下判断，当这个值为NO的时候，会自动断掉这个设备的连接;当为YES的时候，会设置该设备为自动重连状态
 */
@property (nonatomic, assign) BOOL selected;

@property (nonatomic ,strong) TBLEDeviceRawData *currentRawData;/**< 当前数据*/
@property (nonatomic, strong) void (^DataUpdateHandler)(BOOL dataValidity);
- (void)clearAllPropertyData;
@end

@interface TBLEDevice (DataDistill)
@property (nonatomic, strong, readonly) TBLEDeviceDistill *distillTool;
@end
