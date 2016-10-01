//
//  ViewController.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "ViewController.h"
#import "MDeviceData.h"
#import "AppDelegate.h"
#import "TDataManager.h"

#import <BadgeDeviceLib/TBluetooth.h>




@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic ,strong) MDeviceData *currentData;
@end

@implementation ViewController {
    BOOL d;
}
#pragma mark - life cycle

#pragma mark - event

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

- (MDeviceData *)currentData {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [TDataManager sharedDataManager].managedObjectContext;
    if (!_currentData) {
        _currentData = [NSEntityDescription insertNewObjectForEntityForName:@"MDeviceData" inManagedObjectContext:context];
    }
    return _currentData;
}

@end
