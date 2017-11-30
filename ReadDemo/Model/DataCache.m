//
//  DataCache.m
//  ReadDemo
//
//  Created by 蔡宇 on 2017/11/22.
//  Copyright © 2017年 蔡宇. All rights reserved.
//

#import "DataCache.h"
#import <YYCache/YYCache.h>

static NSString * const dataKeyCache = @"dataKeyCache";
static YYCache *_dataCache;



@implementation DataCache

+(void)load{
    _dataCache  = [YYCache cacheWithName:dataKeyCache];
}

+(void)addData:(Record *)recordData{
    NSMutableArray *dataArr =(NSMutableArray *) [_dataCache objectForKey:@"data"];
    if (dataArr.count == 0) {
        NSMutableArray *arr = [[NSMutableArray alloc]initWithObjects:recordData, nil];
        [_dataCache setObject:arr forKey:@"data"];
    }else{
        [dataArr insertObject:recordData atIndex:0];
        [_dataCache setObject:dataArr forKey:@"data"];
    }
}

+(NSMutableArray *)getAllData{
    return (NSMutableArray *)[_dataCache objectForKey:@"data"];
    
}

+ (NSInteger)getAllHttpCacheSize
{
    return [_dataCache.diskCache totalCost];
}

+ (void)removeAllHttpCache
{
    
    [_dataCache.diskCache removeAllObjects];
}
@end
