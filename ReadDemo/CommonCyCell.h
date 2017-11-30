//
//  CommonCyCell.h
//  SmartDemo
//
//  Created by 蔡宇 on 16/12/22.
//  Copyright © 2016年 ilaw. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
  基类Cell
 */
@interface CommonCyCell : UITableViewCell
+ (id) cellForTableView:(UITableView*)tableView;
+ (NSString*)cellIdentifier;
- (id) initWithCellIdentifier:(NSString*)cellID;
@end
