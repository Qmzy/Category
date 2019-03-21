//
//  UIButton+Image.m
//  IOSMVPBaseProject
//
//  Created by CYKJ on 2018/8/13.
//  Copyright © 2018年 CYKJ. All rights reserved.


#import "UIButton+Image.h"
#import "Util.h"


//@implementation UIButton (Image)
//
//- (void)awakeFromNib
//{
//    [super awakeFromNib];
//
//    UIImage * normalImage = nil;
//    UIImage * selectImage = nil;
//
//    // setBackgroundImage:  设置正常状态背景图
//    if (self.accessibilityLabel) {
//
//        normalImage = [self imageFromOneBundle:self.accessibilityLabel];
//
//        if ([self backgroundImageForState:UIControlStateNormal]) {
//            [self setBackgroundImage:normalImage forState:UIControlStateNormal];
//        }
//    }
//
//    // setImage:  设置前景图
//    if (self.accessibilityIdentifier) {
//
//        normalImage = [self imageFromOneBundle:self.accessibilityIdentifier];
//
//        if ([self imageForState:UIControlStateNormal]) {
//            [self setImage:normalImage forState:UIControlStateNormal];
//        }
//    }
//
//    // 选中状态
//    if (self.accessibilityHint) {
//
//        selectImage = [self imageFromOneBundle:self.accessibilityHint];
//
//        // 优先设置背景图
//        if ([self backgroundImageForState:UIControlStateSelected]) {
//            [self setBackgroundImage:selectImage forState:UIControlStateSelected];
//        }
//        else if ([self imageForState:UIControlStateSelected]) {
//            [self setImage:selectImage forState:UIControlStateSelected];
//        }
//    }
//}
//
///**
//  *  @brief   获取模块内的图片
//  */
//- (UIImage *)imageFromOneBundle:(NSString *)accessibilityString
//{
//    NSArray * arr = [accessibilityString componentsSeparatedByString:@"|"];
//    UIImage * image = nil;
//
//    // 在 MyBundle.bundle 中找
//    if (arr.count > 1) {
//        Class cls = NSClassFromString(arr[0]);
//        image = [Util imageNamed:arr[1] module:nil cls:cls];
//    }
//
//    // 去 main 找
//    if (!image) {
//        image = [UIImage imageNamed:[arr lastObject]];
//    }
//
//    return image;
//}
//
//@end
