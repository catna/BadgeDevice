//
//  DataStoreTool.h
//  BadgeDevice
//
//  Created by MX on 2016/10/2.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TBLEDevice;

@interface DataStoreTool : NSObject
+ (instancetype)sharedTool;

- (BOOL)traceADevice:(TBLEDevice *)device;
- (BOOL)cancelTraceDevice:(TBLEDevice *)device;
@end
