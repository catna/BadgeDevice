//
//  ViewController.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#import <BadgeDeviceLib/TBluetooth.h>
#import <BadgeDeviceLib/TBLEDevice.h>
#import <BadgeDeviceLib/TBLEDefine.h>

#import "DataStoreTool.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation ViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [[TBluetooth sharedBluetooth] scanAndConnect:YES];
    [TBluetooth sharedBluetooth].devicesChanged = ^{
        for (TBLEDevice *device in [TBluetooth sharedBluetooth].devicesDic.allValues) {
            weakify(device);
            device.connectStatusChanged = ^(BOOL isConnect) {
                strongify(device);
                
                if ([device.macAddr isEqualToString:@"04:A3:16:37:E5:27"]) {
                    device.selected = NO;
                    return;
                }
                
                weakify(device);
                device.macAddressReaded = ^(NSString *macaddress) {
                    strongify(device);
                    if ([macaddress isEqualToString:@"04:A3:16:37:E5:27"]) {
                        device.selected = NO;
                        return;
                    }
                };
                
                device.selected = YES;
                
                [[DataStoreTool sharedTool] traceADevice:device];
            };
        }
    };
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
////    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
////    NSEntityDescription *entityDes = [NSEntityDescription entityForName:@"" inManagedObjectContext:[[TDataManager sharedDataManager] managedObjectContext]];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MDeviceData" inManagedObjectContext:[[TDataManager sharedDataManager] managedObjectContext]];
//    [fetchRequest setEntity:entity];
//    // Specify criteria for filtering which objects to fetch
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"time >= %@", [NSDate dateWithTimeIntervalSinceNow:-3600]];
//    [fetchRequest setPredicate:predicate];
//    // Specify how the fetched objects should be sorted
////    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"<#key#>"
////                                                                   ascending:YES];
////    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
//    
//    fetchRequest.fetchBatchSize = 100;
//    NSError *error = nil;
//    NSArray *fetchedObjects = [[[TDataManager sharedDataManager] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
//    if (fetchedObjects == nil) {
//        NSLog(@"some error === --- --- ====");
//    }
//    
//    MDeviceData *d = fetchedObjects.firstObject;
//    NSLog(@"%@", [d generateShowText]);
//}

@end
