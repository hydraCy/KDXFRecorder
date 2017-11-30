//
//  DataCache.h
//  ReadDemo
//
//  Created by 蔡宇 on 2017/11/22.
//  Copyright © 2017年 蔡宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"
@interface DataCache : NSObject
+(void)addData:(Record *)recordData;

+(NSMutableArray *)getAllData;

/**
 * 获取网络缓存的总大小 bytes(字节)
 */
+ (NSInteger)getAllHttpCacheSize;

/**
 * 删除所有网络缓存
 */
+ (void)removeAllHttpCache;

@end
