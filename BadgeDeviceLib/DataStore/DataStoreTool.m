//
//  DataStoreTool.m
//  BadgeDevice
//
//  Created by MX on 2016/10/2.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "DataStoreTool.h"
#import "MDeviceData.h"
#import "TDataManager.h"
#import <BadgeDeviceLib/TBluetooth.h>
#import <BadgeDeviceLib/TBLEDevice.h>
#import <BadgeDeviceLib/TBLEDefine.h>
#import "TLocationManager.h"
#import "JZLocationConverter.h"

@interface DataStoreTool()
@property (nonatomic, strong) NSMutableArray<TBLEDevice *> *deviceArray;
@property (nonatomic, strong) NSMutableArray<MDeviceData *> *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation DataStoreTool {
    NSUInteger _storeCount;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

+ (instancetype)sharedTool {
    static id tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[[self class] alloc] init];
    });
    return tool;
}

- (BOOL)traceADevice:(TBLEDevice *)device {
    if (device) {
        weakify(self);
        weakify(device);
        if (![self.deviceArray containsObject:device]) {
            [self.deviceArray addObject:device];
        }
        device.DataUpdateHandler = ^(BOOL dataValidity){
            if (dataValidity) {
                strongify(self);
                strongify(device);
                if (_storeCount >= 4) {
                    [self storeDeviceData:device];
                    _storeCount = 0;
                }
                _storeCount ++;
            }
        };
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)cancelTraceDevice:(TBLEDevice *)device {
    if (device && [self.deviceArray containsObject:device]) {
        device.DataUpdateHandler = nil;
        [self.deviceArray removeObject:device];
        return YES;
    } else {
        return NO;
    }
}

- (void)storeDeviceData:(TBLEDevice *)device {
    if (self.dataArray.count >= 10) {
        [[TDataManager sharedDataManager] saveContext];
        [self.dataArray removeAllObjects];
    }
    MDeviceData *d = [NSEntityDescription insertNewObjectForEntityForName:@"MDeviceData" inManagedObjectContext:[[TDataManager sharedDataManager] managedObjectContext]];
    d.time = [NSDate date];
    d.pres = device.currentRawData.Pres;
    d.humi = device.currentRawData.Humi;
    d.temp = device.currentRawData.Temp;
    d.uvle = device.currentRawData.UVLe;
    d.macAddress = device.macAddr;
    TLocationManager *lm = [TLocationManager sharedManager];
    [self assembleLocation:lm.location toDeviceData:d];
    [self.dataArray addObject:d];
}

- (void)assembleLocation:(CLLocation *)location toDeviceData:(MDeviceData *)d {
    if (nil == location) {
        location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
        d.locationTimeStamp = @"";
    } else {
        d.locationTimeStamp = [self.dateFormatter stringFromDate:location.timestamp];
    }
    CLLocationCoordinate2D coor = location.coordinate;
    coor = [JZLocationConverter gcj02ToWgs84:coor];
    d.latitude = [NSString stringWithFormat:@"%.5f", coor.latitude];
    d.longitude = [NSString stringWithFormat:@"%.5f", coor.longitude];
}

- (NSArray<MDeviceData *> *)readDataWith:(NSTimeInterval)timeInterval {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MDeviceData" inManagedObjectContext:[TDataManager sharedDataManager].managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    if (0 != timeInterval) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"time >= %@", [NSDate dateWithTimeIntervalSinceNow:timeInterval]];
        [fetchRequest setPredicate:predicate];
    }
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[TDataManager sharedDataManager].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"未取得任何数据");
    }
    return fetchedObjects;
}

#pragma mark - getter
- (NSMutableArray<TBLEDevice *> *)deviceArray {
    if (!_deviceArray) {
        _deviceArray = [[NSMutableArray alloc] init];
    }
    return _deviceArray;
}

- (NSMutableArray<MDeviceData *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _dataArray;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _dateFormatter;
}

@end