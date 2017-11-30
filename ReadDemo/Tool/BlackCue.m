//
//  BlackCue.m
//  demo1
//
//  Created by J on 16/5/19.
//  Copyright © 2016年 J. All rights reserved.
//

#import "BlackCue.h"
#import "NSString+Util.h"

#define UIColorFromRGBA(rgbValue, alphaValue) \
[UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

@implementation BlackCue
+(void)showText:(NSString *)text{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    NSDictionary *dictionary =@{NSFontAttributeName:[UIFont systemFontOfSize:16]};
    CGSize size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictionary context:nil].size;
    CGFloat W=[[UIScreen mainScreen]bounds].size.width;
    CGFloat H=[[UIScreen mainScreen]bounds].size.height;
    
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(W/2-size.width/2-10, H-90, size.width+20, 28)];
    view.backgroundColor=UIColorFromRGBA(0x000000, 0.6);
    view.layer.cornerRadius=3;
    view.layer.masksToBounds=YES;
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(W/2-size.width/2-10, H - 90, size.width+20, size.height+10)];
    label.backgroundColor=[UIColor clearColor];
    label.text=text;
    label.textAlignment=NSTextAlignmentCenter;
    label.font=[UIFont systemFontOfSize:14];
    label.numberOfLines=0;
    label.textColor=UIColorFromRGBA(0xffffff, 1);
    [window addSubview:view];
    [window addSubview:label];
    
    [UIView animateWithDuration:2.5 animations:^{
        view.alpha = 0;
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [label removeFromSuperview];
        [window removeFromSuperview];
    }];
    
}

+(void)showCapText:(NSString *)text{
    
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    NSDictionary *dictionary =@{NSFontAttributeName:[UIFont systemFontOfSize:16]};
    CGSize size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictionary context:nil].size;
    CGFloat W=[[UIScreen mainScreen]bounds].size.width;
    CGFloat H = [[UIScreen mainScreen] bounds].size.height;
    
     UIView *view=[[UIView alloc]initWithFrame:CGRectMake(W/2-size.width/2-10, W * 1.1, size.width+20, 28)];
    if (H < 500) {
        
        view.frame = CGRectMake(W/2-size.width/2-10, W * 1.1 - 22, size.width+20, 28);
        
    }
    view.backgroundColor=UIColorFromRGBA(0x000000, 0.6);
    view.layer.cornerRadius=3;
    view.layer.masksToBounds=YES;
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, size.width+20, size.height+10)];
    label.backgroundColor=[UIColor clearColor];
    label.text=text;
    label.textAlignment=NSTextAlignmentCenter;
    label.font=[UIFont systemFontOfSize:14];
    label.numberOfLines=0;
    label.textColor=UIColorFromRGBA(0xffffff, 1);
    [window addSubview:view];
    [view addSubview:label];
    
    [UIView animateWithDuration:1.5 animations:^{
        view.alpha = 0;
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [label removeFromSuperview];
        [window removeFromSuperview];
    }];
    
}

+(void)showCenterText:(NSString *)text
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    NSDictionary *dictionary =@{NSFontAttributeName:[UIFont systemFontOfSize:15]};
    CGFloat W=[[UIScreen mainScreen]bounds].size.width;
    CGFloat H=[[UIScreen mainScreen]bounds].size.height;
    
    CGSize size = [text boundingRectWithSize:CGSizeMake(W-52, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictionary context:nil].size;
    
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(W/2-size.width/2-10, H/2-(size.height+14)/2, size.width+20, size.height+14)];
    view.backgroundColor=UIColorFromRGBA(0x000000, 0.5);
    view.layer.cornerRadius=4;
    view.layer.masksToBounds=YES;
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(W/2-size.width/2, H/2-(size.height+4)/2, size.width, size.height+4)];
    label.backgroundColor=[UIColor clearColor];
    label.text=text;
    label.textAlignment=NSTextAlignmentCenter;
    label.font=[UIFont systemFontOfSize:15];
    label.numberOfLines=0;
    label.textColor=UIColorFromRGBA(0xffffff, 1);
    [window addSubview:view];
    [window addSubview:label];
    
    [UIView animateWithDuration:2.5 animations:^{
        view.alpha = 0;
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [label removeFromSuperview];
        [window removeFromSuperview];
    }];
    
}

@end
