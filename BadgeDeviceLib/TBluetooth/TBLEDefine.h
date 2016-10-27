//
//  TBLEDefine.h
//  BadgeDevice
//
//  Created by MX on 16/5/17.
//  Copyright © 2016年 MX. All rights reserved.
//

#ifndef TBLEDefine_h
#define TBLEDefine_h

#define MacAddrUUID @"2A23"

#define UVService @"F000AA00-0451-4000-B000-000000000000"
#define UVData    @"F000AA01-0451-4000-B000-000000000000"
#define UVConfig  @"F000AA02-0451-4000-B000-000000000000"

#define THService @"F000AA20-0451-4000-B000-000000000000"
#define THData    @"F000AA21-0451-4000-B000-000000000000"
#define THConfig  @"F000AA22-0451-4000-B000-000000000000"

#define PrService @"F000AA40-0451-4000-B000-000000000000"
#define PrData    @"F000AA41-0451-4000-B000-000000000000"
#define PrConfig  @"F000AA42-0451-4000-B000-000000000000"

#define ConnectService    @"F000CCC0-0451-4000-B000-000000000000"
#define ConnectData       @"F000CCC1-0451-4000-B000-000000000000"
#define ConnectTimeConfig @"F000CCC2-0451-4000-B000-000000000000"

#define DeviceNameOne @"SensorTag"
#define DeviceNameTwo @"TI BLE Sensor Tag"

#define AutoSearchTimeGap 5 /**<自动搜索时间间隔*/

#endif /* TBLEDefine_h */

///define block declare
#define weakify(var) __weak typeof(var) AHKWeak_##var = var;
#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = AHKWeak_##var; \
_Pragma("clang diagnostic pop")
