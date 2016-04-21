//
//  StringTool.m
//  yucen_fdr
//
//  Created by ug19 on 15/5/15.
//  Copyright (c) 2015年 UG. All rights reserved.
//

#import "StringTool.h"

@implementation StringTool

+ (NSString *)formatString:(id)object {
	if ([StringTool isNil:object]) {
		return @"";
	} else {
		NSString *str = (NSString *)object;
		return [NSString stringWithFormat:@"%@", str];
	}
}

+ (BOOL)isEmpty:(id)object {
	if ([object isKindOfClass:[NSNull class]]) {
		return YES;
	} else {
		NSString *str = (NSString *)object;
		NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		NSString *trimmedString = [str stringByTrimmingCharactersInSet:set];
		if (trimmedString.length == 0) {
			return YES;
		} else {
			return NO;
		}
	}
}

+ (BOOL)isNil:(id)object {
	if ([object isKindOfClass:[NSNull class]]) {
		return YES;
	} else {
		NSString *str = (NSString *)object;
		NSString *checkStr = [NSString stringWithFormat:@"%@", str];
		return [checkStr isEqualToString:@"(null)"] || [checkStr isEqualToString:@""] || checkStr.length == 0 ? YES : NO;
	}
}

+ (NSString *)trimString:(NSString *)string limit:(NSInteger)limit {
	if (string == nil) {
		return string;
	}
	if (string.length > limit) {
		return [string substringToIndex:limit];
	} else {
		return string;
	}
}

+ (NSString *)trimMixString:(NSString *)string limit:(NSInteger)limit {
	if (string == nil) {
		return string;
	}
	NSMutableString *c = [NSMutableString new];
	NSInteger position = limit;
	for (int i = 0; i < string.length; i ++) {
		if (position == 0) {
			break;
		}
		unichar ch = [string characterAtIndex:i];
		if (0x4e00 < ch && ch < 0x9fff) {
			//若为汉字
			[c appendString:[string substringWithRange:NSMakeRange(i, 1)]];
			position = position - 2;
		} else {
			[c appendString:[string substringWithRange:NSMakeRange(i, 1)]];
			position = position - 1;
		}
	}
	return c;
}

/** 十六进制字符串转换为十进制 */
+ (NSString *)stringFromHexString:(NSString *)hexString {
	if (![hexString hasSuffix:@"0x"]) {
		return [NSString stringWithFormat:@"%.0lu", strtoul([hexString UTF8String], 0, 16)];
	} else {
		return [NSString stringWithFormat:@"%.0lu", strtoul([[NSString stringWithFormat:@"0x%@", hexString] UTF8String], 0, 16)];
	}
}

@end
