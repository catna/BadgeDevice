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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic ,strong) TBluetooth *ble;
@property (nonatomic ,strong) MDeviceData *currentData;
@end

@implementation ViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addListener];

//    NSLog(@"%@",delegate.managedObjectContext);
    [self.ble readDataWithUpdateHandler:^(struct DeviceData deviceData) {
        self.currentData.macAddress = self.ble.device.macAddress;
        self.currentData.pres = (__bridge NSString *)(deviceData.pres);
        self.currentData.humi = (__bridge NSString *)(deviceData.humi);
        self.currentData.temp = (__bridge NSString *)(deviceData.temp);
        self.currentData.uvnu = (__bridge NSString *)(deviceData.UVNu);
        self.currentData.uvle = (__bridge NSString *)(deviceData.UVLe);
        self.currentData.time = [NSDate date];
//        self.textView.text = [self.currentData generateShowText];
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate saveContext];
        
    } notify:YES];
}

- (void)dealloc {
    [self removeListener];
}

#pragma mark - event
- (void)eDeviceConnectSuccess {
//    self.currentData.name = self.ble.device.name;
    self.textView.text = [NSString stringWithFormat:@"%@\n%@",self.textView.text,self.ble.device.name];
}

#pragma mark - private methods
- (void)addListener {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eDeviceConnectSuccess) name:kTBluetoothConnectSuccess object:nil];
}

- (void)removeListener {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter
- (TBluetooth *)ble {
    if (!_ble) {
        _ble = [TBluetooth sharedBluetooth];
    }
    return _ble;
}

- (MDeviceData *)currentData {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    _currentData = [NSEntityDescription insertNewObjectForEntityForName:@"MDeviceData" inManagedObjectContext:context];
    return _currentData;
}

@end
