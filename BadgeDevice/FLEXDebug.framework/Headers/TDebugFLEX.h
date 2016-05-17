//
//  TDebugFLEX.h
//  weather-Swift
//
//  Created by MX on 16/5/13.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDebugFLEX : NSObject

@property (nonatomic ,strong ,readonly) UIButton *buttonDebug;/**< call debug button*/

+ (instancetype)sharedDebugFLEX;

- (void)showDebugTool;

@end

@interface UIViewController (ViewDebug)

@end