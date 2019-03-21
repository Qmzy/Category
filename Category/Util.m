//
//  Util.m
//  Category
//
//  Created by CYKJ on 2019/3/1.
//  Copyright © 2019年 D. All rights reserved.


#import "Util.h"

@implementation Util

/**
  *  @brief   反转字符串
  */
+ (NSString *)stringByReversed:(NSString *)originStr
{
    NSMutableString * s = [NSMutableString string];
    for (NSUInteger i = originStr.length; i > 0; i--) {
        [s appendString:[originStr substringWithRange:NSMakeRange(i-1, 1)]];
    }
    return s;
}

+ (UIImage *)imageNamed:(NSString *)imageName module:(NSString *)module cls:(Class)cls
{
    if (module == nil || module.length == 0) {
        module = @"My";
    }
    
    // NEEDFIX 这里不对的，不能直接为本类的 bundle，这样是指定模块了
    if (cls == nil) {
        cls = [self class];
    }
    
    return [UIImage imageNamed:imageName
                      inBundle:[self bundleWithClassName:cls moduleName:module] compatibleWithTraitCollection:nil];
}

/**
  *  @brief   获取 xib、图片资源
  */
+ (NSBundle *)bundleWithClassName:(Class)cls moduleName:(NSString *)module
{
    if (cls == nil) {
        return [NSBundle mainBundle];
    }
    
    NSBundle * bundle = [NSBundle bundleForClass:cls];
    NSURL * bundleURL = [bundle URLForResource:module withExtension:@"bundle"];
    
    if (bundleURL == nil) {
        
        // 从视图堆栈中获取 class
        __block UINavigationController * nav;
        [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIViewController * windowVC = obj.rootViewController;
            if ([windowVC isKindOfClass:[UINavigationController class]]) {
                nav = (UINavigationController *)windowVC;
                *stop = YES;
            }
        }];
        
        if (nav != nil) {
            Class callerCls = [nav.viewControllers.firstObject class];
            bundle = [NSBundle bundleForClass:callerCls];
            bundleURL = [bundle URLForResource:module withExtension:@"bundle"];
        }
        
        if (bundleURL == nil) {
            return [NSBundle mainBundle];
        }
    }
    return [NSBundle bundleWithURL:bundleURL];
}

@end
