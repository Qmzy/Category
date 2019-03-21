//
//  UIView+CornerRadius.h
//  CornerRadius
//
//  Created by CYKJ on 2018/10/19.
//  Copyright © 2018年 D. All rights reserved.


#import <UIKit/UIKit.h>


/**    与下面 UIView 的功能相同   **/
@interface CALayer (CornerRadius)

@property (nonatomic, strong) UIImage * image;

- (void)cornerRadiusWithRadius:(CGFloat)radius cornerColor:(UIColor *)cornerColor;
- (void)cornerRadiusWithRadius:(CGFloat)radius cornerColor:(UIColor *)cornerColor corners:(UIRectCorner)corners;
- (void)cornerRadiusWithRadius:(CGFloat)radius cornerColor:(UIColor *)cornerColor corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

@end




@interface UIView (CornerRadius)

- (void)cornerRadiusWithRadius:(CGFloat)radius cornerColor:(UIColor *)cornerColor;
- (void)cornerRadiusWithRadius:(CGFloat)radius cornerColor:(UIColor *)cornerColor corners:(UIRectCorner)corners;
/**
  *  @brief   设置一个带边框的圆角
  *  @param   radius   圆角半径
  *  @param   cornerColor   圆角背景色
  *  @param   corners   圆角的位置
  *  @param   borderWidth   边框宽度
  *  @param   borderColor    边框颜色
  */
- (void)cornerRadiusWithRadius:(CGFloat)radius
                   cornerColor:(UIColor *)cornerColor
                       corners:(UIRectCorner)corners
                   borderWidth:(CGFloat)borderWidth
                   borderColor:(UIColor *)borderColor;

@end
