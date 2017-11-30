//
//  BlackCue.h
//  demo1
//
//  Created by J on 16/5/19.
//  Copyright © 2016年 J. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlackCue : NSObject
// 底部
+(void)showText:(NSString *)text;
// 特殊位置
+(void)showCapText:(NSString *)text;
// 中间
+(void)showCenterText:(NSString *)text;
@end
