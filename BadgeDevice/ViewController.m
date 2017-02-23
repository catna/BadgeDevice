//
//  ViewController.m
//  BadgeDevice
//
//  Created by MX on 2017/2/6.
//  Copyright © 2017年 mx. All rights reserved.
//

#import "ViewController.h"
#import "BadgeDeviceLib.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeviceInfoTableViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *table;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eNotiDataChange) name:kTBLENotiDataChanged object:nil];
    TBLEManager *m = [TBLEManager sharedManager];
    [m turnON];
}

#pragma mark - Event
- (void)eNotiDataChange {
    [self.table reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[TBLEManager sharedManager] devices] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    TBLEManager *m = [TBLEManager sharedManager];
    TBLEDevice *dev = m.devices.allValues[indexPath.row];
    TBLEData *d = dev.data;
    if (d.useful) {
        cell.textLabel.text = [NSString stringWithFormat:@"t:%.1f h:%.1f p:%.1f u:%.1f", d.temp, d.humi, d.pres, d.uvNu];
        cell.contentView.backgroundColor = dev.peri.state == CBPeripheralStateConnected ? [UIColor greenColor] : [UIColor redColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceInfoTableViewController *devVc = [[DeviceInfoTableViewController alloc] init];
    TBLEManager *m = [TBLEManager sharedManager];
    TBLEDevice *dev = m.devices.allValues[indexPath.row];
    devVc.dev = dev;
    [self.navigationController pushViewController:devVc animated:YES];
}

@end
