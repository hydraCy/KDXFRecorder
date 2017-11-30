//
//  AudioComposition.h
//  ReadDemo
//
//  Created by 蔡宇 on 2017/11/27.
//  Copyright © 2017年 蔡宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioComposition : NSObject
/// 合并音频文件
/// @param sourceURLs 需要合并的多个音频文件
/// @param toURL      合并后音频文件的存放地址
/// 注意:导出的文件是:m4a格式的.
+ (void) sourceURLs:(NSArray *) sourceURLs composeToURL:(NSURL *) toURL completed:(void (^)(NSError *error)) completed;

@end
