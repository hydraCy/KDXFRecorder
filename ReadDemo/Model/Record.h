//
//  Record.h
//  ReadDemo
//
//  Created by 蔡宇 on 2017/11/21.
//  Copyright © 2017年 蔡宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject

@property(nonatomic,strong) NSString *recordId;
@property(nonatomic,strong) NSString *recordTime;
@property(nonatomic,strong) NSString *imageUrl;
@property(nonatomic,strong) NSString *voiceUrl;
@property(nonatomic,strong) NSString *contentStr;
@property(nonatomic,assign) NSInteger voiceTime;
@end
