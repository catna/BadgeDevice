//
//  TLocationManager.m
//  BadgeDevice
//
//  Created by MX on 2016/10/7.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TLocationManager.h"
#import "JZLocationConverter.h"
#import <UIKit/UIKit.h>

@interface TLocationManager()<CLLocationManagerDelegate>
@property (nonatomic, strong) void (^aLocationRequestHandler)(CLLocation *);
@end

@implementation TLocationManager
@synthesize location = _location;
@synthesize locationManager = _locationManager;

- (id)init {
    if (self = [super init]) {
        [self locationManager];
    }
    return self;
}

+ (instancetype)sharedManager {
    static id sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TLocationManager alloc] init];
    });
    return sharedManager;
}

- (void)requestALocation:(void (^)(CLLocation *))handler {
    self.aLocationRequestHandler = handler;
}

- (void)setWorkingInBackground:(BOOL)workingInBackground {
    _workingInBackground = workingInBackground;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 9.0) {
        self.locationManager.allowsBackgroundLocationUpdates = _workingInBackground;
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    _location = locations.firstObject;
    if (self.aLocationRequestHandler) {
        self.aLocationRequestHandler(_location);
    }
    self.aLocationRequestHandler = nil;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locationManager requestAlwaysAuthorization]; // 永久授权
            [_locationManager requestWhenInUseAuthorization]; //使用中授权
        }
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.pausesLocationUpdatesAutomatically = YES;
        _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        [_locationManager startUpdatingLocation];
    }
    return _locationManager;
}

@end
