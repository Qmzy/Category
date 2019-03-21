//
//  HookTool.m
//  IOSMVPBaseProject
//
//  Created by CYKJ on 2018/8/21.
//  Copyright © 2018年 CYKJ. All rights reserved.


#import "HookTool.h"
#import <objc/runtime.h>
#import "Util.h"


NSString * normal_imageName;  // 全局变量。不能用 @property 或者  {  NSString * normal_imageName;  }  会崩溃
NSString * select_imageName;  // 选中状态的图片。经过打印显示，所有状态的 key 值都是 UIResourceName，输出顺序为：normal -》highlighted -》selected -》disabled
@implementation HookTool

+ (void)load
{
    // hook UINibDecoder      - decodeObjectForKey:
    NSString * clsName = [NSString stringWithFormat:@"redoce%@biNIU", @"D"];
    clsName = [Util stringByReversed:clsName];  // 混淆
    
    [HookTool exchangeInstanceMethod:NSClassFromString(clsName)
                         originalSEL:@selector(decodeObjectForKey:)
                         swizzledSEL:@selector(swizzle_decodeObjectForKey:)];

    // hook UIImageView        - initWithCoder:
    [HookTool exchangeInstanceMethod:UIImageView.class
                         originalSEL:@selector(initWithCoder:)
                         swizzledSEL:@selector(swizzle_imageView_initWithCoder:)];
    
    // hook UIButton        - initWithCoder:
    [HookTool exchangeInstanceMethod:UIButton.class
                         originalSEL:@selector(initWithCoder:)
                         swizzledSEL:@selector(swizzle_button_initWithCoder:)];
}

- (id)swizzle_decodeObjectForKey:(NSString *)key
{
    Method originalMethod = class_getInstanceMethod([HookTool class], @selector(swizzle_decodeObjectForKey:));
    IMP function = method_getImplementation(originalMethod);
    id (*functionPoint)(id, SEL, id) = (id (*)(id, SEL, id)) function;
    id value = functionPoint(self, _cmd, key);

    NSString * propKey = [Util stringByReversed:@"emaNecruoseRIU"]; // 混淆
    
    if ([key isEqualToString:propKey]) {
        if (normal_imageName) {
            select_imageName = value;
        }
        else {
            normal_imageName = value;
        }
        
        NSLog(@"%@ : %@", key, value);
    }
    
    return value;
}

- (id)swizzle_imageView_initWithCoder:(NSCoder *)aDecoder
{
    // 执行顺序：initWithCoder -》DecoderWithKey -》setImage：，所以每次给 imageView 设置图片时，需要将之前的置空。
    // tabbarItem 的图片设置不会执行 initWithCoder，如果不置空，会导致 imageView 设置成和 tabbarItem 一样的图片。
    normal_imageName = nil;
    select_imageName = nil;
    
    UIImageView * instance = (UIImageView *)[self swizzle_imageView_initWithCoder:aDecoder];
    
    if (normal_imageName && [normal_imageName isKindOfClass:[NSString class]] && normal_imageName.length > 0) {
        
        UIImage * normalImage = [HookTool imageAfterSearch:normal_imageName];
        // 赋值
        if (normalImage) {
            instance.image = normalImage;
        }
        normal_imageName = nil;
        select_imageName = nil;
    }
    
    return instance;
}

- (id)swizzle_button_initWithCoder:(NSCoder *)aDecoder
{
    // 执行顺序：initWithCoder -》DecoderWithKey -》setImage：，所以每次给 button 设置图片时，需要将之前的置空。
    // tabbarItem 的图片设置不会执行 initWithCoder，如果不置空，会导致 button 设置成和 tabbarItem 一样的图片。
    normal_imageName = nil;
    select_imageName = nil;
    
    UIButton * instance = (UIButton *)[self swizzle_button_initWithCoder:aDecoder];
    
    // 正常状态
    if (normal_imageName && [normal_imageName isKindOfClass:[NSString class]] && normal_imageName.length > 0) {
        
        UIImage * normalImage = [HookTool imageAfterSearch:normal_imageName];
        if (normalImage) {
            [instance setImage:normalImage forState:UIControlStateNormal];
        }
        normal_imageName = nil;
    }
    
    // 选中状态
    if (select_imageName && [select_imageName isKindOfClass:[NSString class]] && select_imageName.length > 0) {
        
        UIImage * selectImage = [HookTool imageAfterSearch:select_imageName];
        if (selectImage) {
            [instance setImage:selectImage forState:UIControlStateSelected];
        }
        select_imageName = nil;
    }
    
    return instance;
}

/**
  *  @brief   获取查找后的图片
  */
+ (UIImage *)imageAfterSearch:(NSString *)imageName
{
    // 去 IOSMVPBase 找
    UIImage * resultImage = [Util imageNamed:imageName module:nil cls:nil];
    
    // 去 main 找
    if (!resultImage) {
        resultImage = [UIImage imageNamed:imageName];
    }
    
    return resultImage;
}

/**
  *  @brief   替换方法实现
  */
+ (void)exchangeInstanceMethod:(Class)otherClass originalSEL:(SEL)originalSEL swizzledSEL:(SEL)swizzledSEL
{
    Method originalMethod = class_getInstanceMethod(otherClass, originalSEL);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSEL);
    
    // otherClass 添加替换后的 SEL，避免 unrecognizeSelectorSentToInstance 错误
    class_addMethod( otherClass,
                    swizzledSEL,
                    method_getImplementation(originalMethod),
                    method_getTypeEncoding(originalMethod));
    // 替换 otherClass 类的旧方法实现
    BOOL c = class_addMethod( otherClass,
                             originalSEL,
                             method_getImplementation(swizzledMethod),
                             method_getTypeEncoding(swizzledMethod));
    
    if (!c) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
