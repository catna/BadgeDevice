//
//  TBLEData.m
//  BadgeDevice
//
//  Created by MX on 2017/2/6.
//  Copyright © 2017年 mx. All rights reserved.
//

#import "TBLEData.h"

@interface TBLEData ()
@end

@implementation TBLEData
@synthesize dateFormatter = _dateFormatter;
// 在设置这些变量的时候就判断数据是否在正常范围内,从而改变数据的可用性
// 选取一个属性设置就好,多了没必要
- (void)setTemp:(double)temp {
    _temp = temp;
    [self dataCheck];
}

- (void)dataCheck {
    BOOL ct = _temp > -40 && _temp < 100;
    BOOL ch = _humi > -1 && _humi <= 100;
    BOOL cp = _pres >= 800 && _pres <= 1200;
    _useful = ct && ch && cp;
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
