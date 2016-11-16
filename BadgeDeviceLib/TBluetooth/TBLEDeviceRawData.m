//
//  TBLEDeviceRawData.m
//  BadgeDevice
//
//  Created by MX on 2016/10/27.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBLEDeviceRawData.h"
#import "TBluetoothTools.h"
#import "TBLENotification.h"

@interface TBLEDeviceRawData ()
@end

@implementation TBLEDeviceRawData {
    BOOL _uV, _pV, _tV, _hV;
}
@synthesize dataValidity = _dataValidity;
@synthesize Temp = _Temp;
@synthesize Humi = _Humi;
@synthesize Pres = _Pres;
@synthesize UVLe = _UVLe;

- (id)init {
    if (self = [super init]) {
        self.dataCreateTime = [NSDate date];
        self.dataRecordTime = [NSDate date];
    }
    return self;
}

- (void)setTHRawData:(NSData *)THRawData {
    if (THRawData == NULL) {
        return;
    }
    _THRawData = THRawData;
    double t = [TBluetoothTools convertTempData:THRawData];
    double h = [TBluetoothTools convertHumiData:THRawData];
    _tV = t > -40.0;
    _hV = h > -1.0;
    
    _Temp = [NSString stringWithFormat:@"%.2f", t];
    _Humi = [NSString stringWithFormat:@"%.2f", h];
    [self updateData];
}

- (void)setPrRawData:(NSData *)PrRawData {
    if (PrRawData == NULL) {
        return;
    }
    _PrRawData = PrRawData;
    double p = [TBluetoothTools convertPresData:PrRawData];
    _pV = p >= 800 && p <= 1100;
    _Pres = [NSString stringWithFormat:@"%.2f", p];
    [self updateData];
}

- (void)setUVRawData:(NSData *)UVRawData {
    if (UVRawData == NULL) {
        return;
    }
    _UVRawData = UVRawData;
    double uv = [TBluetoothTools convertUVNuData:UVRawData];
    _uV = uv >= 0;
    _UVLe = [NSString stringWithFormat:@"%d", [TBluetoothTools matchUVLeWithUVNu:uv]];
    [self updateData];
}

- (BOOL)dataValidity {
    if (_uV && _pV && _tV && _hV) {
        return YES;
    }
    return NO;
}

- (void)updateData {
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLENotiDeviceDataUpdate object:nil];
#if DEBUG
    NSLog(@"徽章数据->\r\n温度:%@\t湿度:%@\t气压:%@\t紫外线:%@\r\n", self.Temp, self.Humi, self.Pres, self.UVLe);
#endif
}

@end
