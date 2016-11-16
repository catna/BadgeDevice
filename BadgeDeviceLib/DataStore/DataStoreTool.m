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
#import "TLocationManager.h"
#import "JZLocationConverter.h"

@interface DataStoreTool()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation DataStoreTool
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

#pragma mark - public methods
- (MDeviceData *)createAModelToFill {
    MDeviceData *d = [NSEntityDescription insertNewObjectForEntityForName:@"MDeviceData" inManagedObjectContext:[[TDataManager sharedDataManager] managedObjectContext]];
    TLocationManager *lm = [TLocationManager sharedManager];
    [self assembleLocation:lm.location toDeviceData:d];
    return d;
}

- (void)save {
    [[TDataManager sharedDataManager] saveContext];
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

#pragma mark - private methods
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

#pragma mark - getter
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _dateFormatter;
}

@end
