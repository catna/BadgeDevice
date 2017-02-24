//
//  TBLEDevice.h
//  BadgeDevice
//
//  Created by MX on 2017/2/6.
//  Copyright © 2017年 mx. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral, CBService;
@class TBLEData;

/// 单个设备
@interface TBLEDevice : NSObject
/// 依据此设备创建的本实例，暴露出来以供读取其他信息
@property (nonatomic, strong, readonly) CBPeripheral *peri;
/// 搜索到的设备服务,依据UUID保留下来
@property (nonatomic, strong, readonly) NSDictionary <NSString *,CBService *> *services;

/// 本设备在连接前广播的数据内容，在此处保存下来，当然可能为空，不想写nullable，太费劲了,当然为了兼容swift之后可以慢慢添加上去
@property (nonatomic, strong) NSDictionary *advertise;

/// 状态信息
/// 设备的mac地址信息，可能读不出来
@property (nonatomic, strong, readonly) NSString *macAddress;
/// 设备的固件版本，同mac
@property (nonatomic, strong, readonly) NSString *firmware;

/*!
 *	@brief 信号强度
 *  @discussion 因为系统自带的那个信号强度属性已经被废弃了,所以在这里提供数据强度的读取接口,当未读取到信号强度时,这个属性会是nil
 */
@property (nonatomic, strong, readonly) NSNumber *RSSI;
/// 设备记录下的电量信息，可能为0
@property (nonatomic, assign, readonly) NSUInteger powerQ;

/// 设备的当前数据
@property (nonatomic, strong, readonly) TBLEData *data;
/// 设备的历史数据(因为数据可能会造成干扰,所以分成两个数据对象来提供)
@property (nonatomic, strong, readonly) TBLEData *dataHistory;

/// 监听数据的开关,注意是监听而不是开启,监听代表是否接收数据变化
@property (nonatomic, assign) BOOL listen;  // default is YES;

/// 打开数据通道的开关,所谓数据通道,就是向物理设备(蓝牙接口)发送打开的指令,预定义的是0x01,默认是打开此开关的,意味着在发现相应的UUID时就开启了数据通道指令
@property (nonatomic, assign) BOOL open;    // default is YES;

/*!
 *	@brief 初始化本实例，是叫装饰器还是依赖注入呢，我其实也有些不明白
 *
 *	@param peri	依据这个设备操作
 *
 *	@return 返回一个本实例
 */
- (id)initWithPeripheral:(CBPeripheral *)peri;

/*!
 *	@brief 同步时间
 *  @discussion 默认会在发现相应的UUID时进行一次时间的同步
 *	@return 是否把同步时间的数据发送出去
 */
- (BOOL)timeCalibration;

/*!
 *	@brief 读取历史数据
 *  @discussion 读取历史数据的时候,内部会根据UUID默认循环的读下去,一旦数据解析不成功,就会跳出循环
 *  @return 是否找到可以读取的 Characteristic 并且发送读取消息
 */
- (BOOL)readHistoryData;

#pragma mark - advanced
/// 自动重连的选项
@property (nonatomic, assign) BOOL autoReconnect;   // default is YES
/// 自动更新信号强度的选项
@property (nonatomic, assign) BOOL autoRefreshRSSI; // default is NO
@end
