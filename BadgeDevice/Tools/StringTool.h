//
//  StringTool.h
//  yucen_fdr
//
//  Created by ug19 on 15/5/15.
//  Copyright (c) 2015年 UG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringTool : NSObject

/**
 *  格式化字符串，防止纯数字时字符串自动转换为 NSNumber 类型，同时防止空值
 *
 *  @param object 字符串或 NSNull 等空值
 *
 *  @return 格式化后的字符串，空时返回“暂无数据”
 */
+ (NSString *)formatString:(id)object;

/** 判断一个对象是否为空的字符串或是否全为空格 */
+ (BOOL)isEmpty:(id)object;

/** 判断一个对象是否为空的字符串 */
+ (BOOL)isNil:(id)object;

/**
 *  切割字符串到指定的字符长度
 *
 *  @param string 要切割的原字符串
 *  @param limit  指定的字符数
 *
 *  @return 若原 string 字符串超过指定的字符长度 limit，则返回切割后的字符串
 */
+ (NSString *)trimString:(NSString *)string limit:(NSInteger)limit;

/**
 *  根据不同语言切割字符串到指定的字节长度，即若切割英文字符串8个字节（字符数），则中文字符串为4个字符
 *
 *  @param string 要切割的原字符串
 *  @param limit  指定的字节长度
 *
 *  @return 若原 string 字符串超过指定的字符长度 limit，则返回切割后的字符串，中文字符串比英文的少一半字符
 */
+ (NSString *)trimMixString:(NSString *)string limit:(NSInteger)limit;

/** 十六进制字符串转换为十进制 */
+ (NSString *)stringFromHexString:(NSString *)hexString;

@end
