# 徽章

这是徽章硬件的蓝牙接口库

### 项目描述

1. 徽章的硬件是基于蓝牙4.0的低功耗硬件,数据传输协议基于文档定义的
2. 徽章支持记录一定量的历史数据
3. 徽章的数据结构包括温湿度,气压,紫外线强度值等基本数据

### 项目架构

1. 首先这个项目的代码是作为数据采集单元设计的,以集成到主App中为目的
2. 因为Apple的CoreBluetooth框架的特性,将中心设备和外围设备的逻辑分开来书写,以通知和数据实例的方式告知设备的状态,数据集合等信息

备注:由于之前采用了BabyBluetooth框架(可见项目版本v1.0)时感觉框架过于繁杂且没必要做这么麻烦,就移除了之前的框架

### 其他
1. 添加了很多注释以方便参考

### Reference
> https://developer.apple.com/reference/corebluetooth
> https://en.wikipedia.org/wiki/Bluetooth_low_energy
> http://liuyanwei.jumppo.com/2015/07/17/ios-BLE-0.html