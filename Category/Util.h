//
//  Util.h
//  Category
//
//  Created by CYKJ on 2019/3/1.
//  Copyright © 2019年 D. All rights reserved.


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Util : NSObject

/**
  *  @brief   反转字符串
  */
+ (NSString * _Nullable )stringByReversed:(NSString *)originStr;

/**
  *  @brief   获取图片资源
  */
+ (UIImage * _Nullable)imageNamed:(NSString *)imageName module:(NSString * _Nullable)module cls:(Class _Nullable)cls;

@end

NS_ASSUME_NONNULL_END
