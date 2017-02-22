//
//  TBLEData.m
//  BadgeDevice
//
//  Created by MX on 2017/2/6.
//  Copyright © 2017年 mx. All rights reserved.
//

#import "TBLEData.h"

@interface TBLEData ()
/// 用于将时间按照一定的格式打印出来
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation TBLEData
// 在设置这些变量的时候就判断数据是否在正常范围内,从而改变数据的可用性
#pragma mark - setter
- (void)setTemp:(double)temp {
    _temp = temp;
}

- (void)setHumi:(double)humi {
    _humi = humi;
}

- (void)setPres:(double)pres {
    _pres = pres;
}

- (void)setUvNu:(double)uvNu {
    _uvNu = uvNu;
}

- (NSString *)represent {
    NSMutableString *string = [NSMutableString stringWithString:[[self class] description]];
    [string appendString:[NSString stringWithFormat:@"BLEData-useful:%d temp:%.4f humi:%.4f pres:%.4f uvnu:%.4f time:%@", self.useful, self.temp, self.humi, self.pres, self.uvNu, [self.dateFormatter stringFromDate:self.date]]];
    return string;
}

#pragma mark - getter
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _dateFormatter;
}

@end
