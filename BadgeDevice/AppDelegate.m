//
//  AppDelegate.m
//  BadgeDevice
//
//  Created by MX on 2017/2/6.
//  Copyright © 2017年 mx. All rights reserved.
//

#import "AppDelegate.h"
#import "BadgeDeviceLib.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    TBLEManager *m = [TBLEManager sharedManager];
    [m turnON];
    NSLog(@"m:%@", m);
    return YES;
}

@end
