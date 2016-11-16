//
//  TLocationManager.h
//  BadgeDevice
//
//  Created by MX on 2016/10/7.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TLocationManager : NSObject
@property (nonatomic, strong, readonly) CLLocation * location;
@property (nonatomic, strong, readonly) CLLocationManager *locationManager;

@property (nonatomic, assign) BOOL workingInBackground;

+ (instancetype)sharedManager;

- (void)requestALocation:(void (^)(CLLocation *location))handler;
@end
