//
//  CommonCyCell.m
//  SmartDemo
//
//  Created by 蔡宇 on 16/12/22.
//  Copyright © 2016年 ilaw. All rights reserved.
//

#import "CommonCyCell.h"

@implementation CommonCyCell

+(NSString *)cellIdentifier{
    return NSStringFromClass([self class]);
}

+ (id)cellForTableView:(UITableView *)tableView{
    NSString *cellID = [self cellIdentifier];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[self alloc] initWithCellIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (id) initWithCellIdentifier:(NSString *)cellID{
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
}

@end
