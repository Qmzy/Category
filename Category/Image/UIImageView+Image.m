//
//  UIImageView+Image.m
//  IOSMVPBaseProject
//
//  Created by CYKJ on 2018/8/13.
//  Copyright © 2018年 CYKJ. All rights reserved.


#import "UIImageView+Image.h"
#import "Util.h"


//@implementation UIImageView (Image)
//
//- (void)awakeFromNib
//{
//    [super awakeFromNib];
//
//    if (self.image == nil && self.accessibilityIdentifier) {
//
//        NSArray * arr = [self.accessibilityIdentifier componentsSeparatedByString:@"|"];
//        __block UIImage * image = nil;
//
//        // 在 MyBundle.bundle 找
//        if (arr.count > 1) {
//            Class cls = NSClassFromString(arr[0]);
//            image = [Util imageNamed:arr[1] module:nil cls:cls];
//        }
//
//        // 去 main 找
//        if (!image) {
//            image = [UIImage imageNamed:[arr lastObject]];
//        }
//
//        if (image) {
//            self.image = image;
//        }
//    }
//}
//
//@end
