//
//  DeviceInfoTableViewController.h
//  BadgeDevice
//
//  Created by MX on 2017/2/23.
//  Copyright © 2017年 mx. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TBLEDevice;

@interface DeviceInfoTableViewController : UITableViewController
@property (nonatomic, strong) TBLEDevice *dev;
@end
