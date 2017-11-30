//
//  UIViewController+NavigationStyle.m
//  ReadDemo
//
//  Created by 蔡宇 on 2017/11/22.
//  Copyright © 2017年 蔡宇. All rights reserved.
//

#import "UIViewController+NavigationStyle.h"

#define NAVIGATION_HEIGHT (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) + CGRectGetHeight(self.navigationController.navigationBar.frame))

@implementation UIViewController (NavigationStyle)
-(void)setNavigationController{
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBaselineAdjustmentNone;
    
    [self.navigationController.navigationBar setBarTintColor:
     getColor(@"ffd900")];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:19],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
#ifdef __IPHONE_11_0
    
    if (@available(iOS 11.0, *)) {
        
        self.navigationController.navigationBar.frame = CGRectMake(0, CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]),ScreenWidth, NAVIGATION_HEIGHT);
        
    }
    
#endif
}
@end
