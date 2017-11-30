//
//  CommonColor.h
//  LightningLawyer
//
//  Created by 蔡宇 on 16/12/27.
//  Copyright © 2016年 应续材. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
  十六进制获取颜色
 */
@interface CommonColor: NSObject
UIColor* getColor(NSString * hexColor);

@end
