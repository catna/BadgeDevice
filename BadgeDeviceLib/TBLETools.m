//
//  TBLETools.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBLETools.h"

@implementation TBLETools
+ (NSString *)macWithCharacteristicData:(NSData *)macData {
    if (macData) {
        NSString *value = [NSString stringWithFormat:@"%@", macData];
        NSMutableString *macString = [[NSMutableString alloc] init];
        int rangs[6] = {1,3,5,12,14,16};
        for (int i = 5; i >= 0; i--) {
            [macString appendString:[[value substringWithRange:NSMakeRange(rangs[i], 2)] uppercaseString]];
            [macString appendString:@":"];
        }
        return [macString substringToIndex:macString.length - 1];
    }
    return @"";
}

+ (NSString *)firmwareStringFrom:(NSData *)data {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!str) {
        str = @"";
    }
    return str;
}

+ (double)convertPresData:(NSData *)data {
    const void *rawData = data.bytes;
    int a = 0;
    char *b = (char *)&a;
    for (int i = 0; i < data.length - 3; i ++) {
        *(b + i) = *(char *)(rawData + 3 + i);
    }
    return [[self class] calculatorPres:(double)a];
}

+ (double)convertUVNuData:(NSData *)data {
    //rawData: <2a000000> length:4
    const void *rawData = data.bytes;
    return (double)*(int *)rawData;
}

+ (double)convertHumiData:(NSData *)data {
    //raw: <c46be29c> length:4
    const void *rawData = data.bytes;
    int a = 0;
    char *b = (char *)&a;
    for (int i = 0; i < sizeof(int) - 2; i ++) {
        *(b + i) = *(char *)(rawData + 2 + i);
    }
    return [[self class] calculatorHumi:(double)a];
}

+ (double)convertTempData:(NSData *)data {
    const void *rawData = data.bytes;
    int a = 0;
    char *b = (char *)&a;
    for (int i = 0; i < sizeof(int) - 2; i ++) {
        *(b + i) = *(char *)(rawData + i);
    }
    return [[self class] calculatorTemp:(double)a];
}

+ (int)matchUVLeWithUVNu:(double)UVNu {
    double u0 = (UVNu * 3.0) / 128;	// u0 为输出电压
    if (u0 <= 0.99) {	// u0 小于等于0.99时，认为 uv 指数为0
        return 0;
    }
    double uv = (u0 - 0.99) * 10 / (2.2 - 1);
    if (0 <= uv && uv <= 0.5) {
        return 1;	// 一级，最弱
    } else if (0.5 < uv && uv <= 1) {
        return 2;	// 二级，弱
    } else if (1 < uv && uv <= 1.75) {
        return 3;	// 三级，中等
    } else if (1.75 < uv && uv <= 3) {
        return 4;	// 四级，强
    } else if (uv > 3) {
        return 5;	// 五级，很强
    } else {
        return 0;
    }
}

#pragma mark - calculator
+ (double)calculatorHumi:(double)humi {
    return humi * 125.0 / 65536 - 6;
}

+ (double)calculatorTemp:(double)temp {
    return temp * 175.72 / 65536 - 46.85;
}

+ (double)calculatorPres:(double)pres {
    return pres / 100.0;
}

+ (double)calculatorUvLe:(double)uvle {
    return [[self class] matchUVLeWithUVNu:uvle];
}

@end

@implementation TBLETools (History)
+ (NSData *)createCurrentTimeData {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy|MM|dd|HH|mm";
    NSString *dateString = [formatter stringFromDate:date];
    NSArray <NSString *>*dateArray = [dateString componentsSeparatedByString:@"|"];
    
    char year   = [[dateArray[0] substringFromIndex:2] intValue];
    char month  = [dateArray[1] intValue];
    char day    = [dateArray[2] intValue];
    char hour   = [dateArray[3] intValue];
    char minute = [dateArray[4] intValue];
    
    char dateBytes[8];
    dateBytes[7] = 0x00;
    dateBytes[6] = 0x00;
    dateBytes[5] = 0x00;
    dateBytes[4] = minute;
    dateBytes[3] = hour;
    dateBytes[2] = day;
    dateBytes[1] = month;
    dateBytes[0] = year;
    
    NSData *data = [NSData dataWithBytes:&dateBytes length:sizeof(dateBytes)];
    return data;
}

+ (NSDate *)parseHistoryDate:(const char *)dateBytes {
    char y = dateBytes[0];
    char M = dateBytes[1];
    char d = dateBytes[2];
    char H = dateBytes[3];
    char m = dateBytes[4];
    NSString *strDate = [NSString stringWithFormat:@"20%02d-%02d-%02d %02d:%2d", y, M, d, H, m];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *date = [dateFormatter dateFromString:strDate];
    return date;
}

//    读取到的历史和电量信息<1009080a 2129f06b 7e775c8d 01430908>
//    BYTE0：年
//    BYTE1：月
//    BYTE2：日
//    BYTE3：时
//    BYTE4：分
//    BYTE5：紫外线
//    BYTE6~7：温度
//    BYTE8~9：湿度
//    BYTE10~12：大气压
//    BYTE13：电池电量
//    BYTE14~15：保留
+ (NSArray <NSData *> *)distillHistoryData:(NSData *)data {
    NSMutableArray <NSData *> *arr = [[NSMutableArray alloc] init];
    const char *rawData = data.bytes;
    // 对数据进行判断
    unsigned int const allFF = ~0;
    unsigned long long all00 = 0;
    int compareFFResult = bcmp(data.bytes, &allFF, sizeof(allFF));
    int compare00Result = bcmp(data.bytes, &all00, data.length);
    if (compareFFResult == 0 || compare00Result == 0) {
        return nil;
    }
    // 定义好数据的长度(bit长度)
    int tehu = 0, uvle = 0;
    char time[5], pres[6];
    // 将bit拷贝到相应位置
    memcpy(time, rawData, 5);
    *((char *)&uvle) = rawData[5];
    memcpy(&tehu, &rawData[6], 4);
    memcpy(&pres, &rawData[7], 6);
    // 将温湿度数据传送到数组的第一个
    [arr addObject:[NSData dataWithBytes:&tehu length:sizeof(tehu)]];
    // 将气压数据传送到数组的第二个
    [arr addObject:[NSData dataWithBytes:pres length:6]];
    // 将紫外线数据传送到数组的第三个
    [arr addObject:[NSData dataWithBytes:&uvle length:sizeof(uvle)]];
    // 将时间放到数组的第四个
    [arr addObject:[NSData dataWithBytes:time length:5]];
    // 将电池电量数据放到数组的第五个
    char battery = rawData[13];
    [arr addObject:[NSData dataWithBytes:&battery length:sizeof(char)]];
    // 如果数组的长度不是5
    if (arr.count != 5) {
        return nil;
    }
    return arr;
}

@end
