//
//  ViewController.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "ViewController.h"
#import "TBluetooth.h"
#import "MDeviceData.h"
#import "AppDelegate.h"
#import "TBLEDevice.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic ,strong) TBluetooth *ble;
@property (nonatomic ,strong) MDeviceData *currentData;
@end

@implementation ViewController {
    BOOL d;
}
#pragma mark - life cycle
- (void)viewDidLoad {
//    [super viewDidLoad];
//    [self addListener];
//    self.view.backgroundColor = [UIColor cyanColor];
}

- (void)dealloc {
//    [self removeListener];
}

#pragma mark - event
- (void)eReadDeviceMacAddr {
    
//    if (YES) {
//        for (TBLEDevice *dev in self.ble.devicesDic.allValues) {
//            if (dev.isConnect) {
//                for (CBService *ser in dev.peri.services) {
//                    [self.ble dataGalleryOpen:YES peri:dev.peri service:ser];
//                }
//            }
//        }
//    }
}

- (void)eDisConn {
    NSLog(@"断开了连接------------------------");
//    if (YES) {
//        for (TBLEDevice *dev in self.ble.devicesDic.allValues) {
//            if (dev.isConnect) {
//                for (CBService *ser in dev.peri.services) {
//                    [self.ble dataGalleryOpen:NO peri:dev.peri service:ser];
//                }
//            }
//        }
//    }
}

- (void)eUpdateData {

//    TBLEDeviceRawData *rd = self.ble.devicesDic.allValues[0].currentRawData;
//    if (rd.dataValidity) {
//        self.textView.text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", rd.Pres, rd.UVLe, rd.Temp, rd.Humi];
//    
//        NSLog(@"1:%@-2:%@-3:%@-4:%@", rd.Pres, rd.Temp, rd.UVLe, rd.Humi);
//        self.currentData.pres = rd.Pres;
//        self.currentData.temp = rd.Temp;
//        self.currentData.uvle = rd.UVLe;
//        self.currentData.humi = rd.Humi;
//        self.currentData.macAddress = self.ble.devicesDic.allValues[0].macAddr;
//        
//        NSDate *date = [NSDate date];
////        NSDateFormatter *f = [[NSDateFormatter alloc] init];
////        f.dateFormat = @"YY-mm-dd HH:MM:SS";
////        NSString *stringDate = [f stringFromDate:date];
//        
//        self.currentData.time = date;
//        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//        [delegate saveContext];
//        self.currentData = nil;
//    }
}

#pragma mark - private methods
- (void)addListener {
}

- (void)removeListener {
}

#pragma mark - getter
//- (TBluetooth *)ble {
//    if (!_ble) {
//        _ble = [TBluetooth sharedBluetooth];
//    }
//    return _ble;
//}
//
//- (MDeviceData *)currentData {
//    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
////    NSManagedObjectContext *context = delegate.managedObjectContext;
////    if (!_currentData) {
////        _currentData = [NSEntityDescription insertNewObjectForEntityForName:@"MDeviceData" inManagedObjectContext:context];
////    }
//    return _currentData;
//}

@end
