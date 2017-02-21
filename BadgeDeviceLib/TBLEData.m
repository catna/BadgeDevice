//
//  TBLEData.m
//  BadgeDevice
//
//  Created by MX on 2017/2/6.
//  Copyright © 2017年 mx. All rights reserved.
//

#import "TBLEData.h"

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
@end
