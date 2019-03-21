//
//  UIView+CornerRadius.m
//  CornerRadius
//
//  Created by CYKJ on 2018/10/19.
//  Copyright © 2018年 D. All rights reserved.


#import "UIView+CornerRadius.h"
#import <objc/runtime.h>


@implementation NSObject (Swizzle)

+ (void)swizzleInstanceMethod:(SEL)originalSEL with:(SEL)swizzleSEL
{
    Method originalMethod = class_getInstanceMethod(self, originalSEL);
    Method swizzleMethod  = class_getInstanceMethod(self, swizzleSEL);
    if (!originalMethod || !swizzleMethod) return;
    method_exchangeImplementations(originalMethod, swizzleMethod);
}

@end



@implementation UIImage (CornerRadius)

+ (UIImage *)imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock
{
    if (!drawBlock)
        return nil;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
   
    if (!context) return nil;
    
    drawBlock(context);
   
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)maskRoundCornerRadiusImageWithColor:(UIColor *)cornerColor radius:(CGFloat)radius size:(CGSize)size corners:(UIRectCorner)corners borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth
{
    return [UIImage imageWithSize:size drawBlock:^(CGContextRef  _Nonnull context) {
        
        CGContextSetLineWidth(context, 0);
        
        [cornerColor set];
        
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIBezierPath * rectPath = [UIBezierPath bezierPathWithRect:CGRectInset(rect, -0.3, -0.3)];
        UIBezierPath * roundPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 0.3, 0.3) byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
        [rectPath appendPath:roundPath];
        CGContextAddPath(context, rectPath.CGPath);
        CGContextEOFillPath(context);
        
        if (!borderColor || !borderWidth) return;
        
        [borderColor set];
        
        UIBezierPath * borderOutterPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                                byRoundingCorners:corners
                                                                      cornerRadii:CGSizeMake(radius, radius)];
        UIBezierPath * borderInnerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, borderWidth, borderWidth) byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
        [borderOutterPath appendPath:borderInnerPath];
        
        CGContextAddPath(context, borderOutterPath.CGPath);
        CGContextEOFillPath(context);
    }];
}

@end



static void* const MaskCornerRadiusLayerKey = "MaskCornerRadiusLayerKey";
static void* const MaskCornerRadiusCornerColor = "MaskCornerRadiusCornerColor";
static void* const MaskCornerRadiusRadius = "MaskCornerRadiusRadius";
static void* const MaskCornerRadiusCorners = "MaskCornerRadiusCorners";
static void* const MaskCornerRadiusBorderWidth = "MaskCornerRadiusBorderWidth";
static void* const MaskCornerRadiusBorderColor = "MaskCornerRadiusBorderColor";

@implementation CALayer (CornerRadius)

+ (void)load
{
    [CALayer swizzleInstanceMethod:@selector(layoutSublayers) with:@selector(swizzle_layoutSublayers)];
}

- (void)swizzle_layoutSublayers
{
    // 调用系统的 layoutSublayers 方法
    [self swizzle_layoutSublayers];
    
    CALayer * maskLayer = objc_getAssociatedObject(self, MaskCornerRadiusLayerKey);
    
    if (maskLayer) {
        
        UIImage * aImage = [self getImageFromSet];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        maskLayer.image = aImage;
        maskLayer.frame = self.bounds;
        [CATransaction commit];
        [self addSublayer:maskLayer];
    }
}

- (void)setImage:(UIImage *)image
{
    self.contents = (__bridge id)image.CGImage;
}

- (UIImage *)image
{
    return [UIImage imageWithCGImage:(__bridge CGImageRef)self.contents];
}

- (void)cornerRadiusWithRadius:(CGFloat)radius cornerColor:(UIColor *)cornerColor
{
    [self cornerRadiusWithRadius:radius cornerColor:cornerColor corners:UIRectCornerAllCorners];
}

- (void)cornerRadiusWithRadius:(CGFloat)radius cornerColor:(UIColor *)cornerColor corners:(UIRectCorner)corners
{
    [self cornerRadiusWithRadius:radius cornerColor:cornerColor corners:corners borderWidth:0 borderColor:nil];
}

- (void)cornerRadiusWithRadius:(CGFloat)radius cornerColor:(UIColor *)cornerColor corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    // 如果没有设置背景色直接返回。（这导致适用性不强）
    if (!cornerColor)
        return;
    
    // 用于处理圆角的 layer
    CALayer * maskLayer = objc_getAssociatedObject(self, MaskCornerRadiusLayerKey);
    
    if (!maskLayer) {
        maskLayer = [CALayer new];
        maskLayer.opaque = YES;
        objc_setAssociatedObject(self, MaskCornerRadiusLayerKey, maskLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 背景色
    if (cornerColor) {
        objc_setAssociatedObject(maskLayer, MaskCornerRadiusCornerColor, cornerColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        objc_setAssociatedObject(maskLayer, MaskCornerRadiusCornerColor, nil, OBJC_ASSOCIATION_ASSIGN);
    }
    // 圆角
    objc_setAssociatedObject(maskLayer, MaskCornerRadiusRadius, @(radius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    // 圆角位置
    objc_setAssociatedObject(maskLayer, MaskCornerRadiusCorners, @(corners), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    // 边框宽度
    objc_setAssociatedObject(maskLayer, MaskCornerRadiusBorderWidth, @(borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 边框色
    if (borderColor) {
        objc_setAssociatedObject(maskLayer, MaskCornerRadiusBorderColor, borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        objc_setAssociatedObject(maskLayer, MaskCornerRadiusBorderColor, nil, OBJC_ASSOCIATION_ASSIGN);
    }
    
    // 从集合中获取 image，如果没有则生成新的 image
    UIImage * image = [self getImageFromSet];
    
    if (image) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        maskLayer.image = image;
        [CATransaction commit];
    }
}

static NSMutableSet<UIImage *> * _imageSet;
static void* const ImageSize = "ImageSize";
static void* const ImageCornerColor = "ImageCornerColor";
static void* const ImageRadius = "ImageRadius";
static void* const ImageCorners = "ImageCorners";
static void* const ImageBorderWidth = "ImageBorderWidth";
static void* const ImageBorderColor = "ImageBorderColor";

- (UIImage *)getImageFromSet
{
    if (!self.bounds.size.width || !self.bounds.size.height) return nil;
    
    CALayer * maskLayer = objc_getAssociatedObject(self, MaskCornerRadiusLayerKey);
    UIColor * cornerColor = objc_getAssociatedObject(maskLayer, MaskCornerRadiusCornerColor);
    
    if (!cornerColor) return nil;
    
    // 获取圆角半径、圆角位置、边框宽度、边框颜色
    CGFloat radius = [objc_getAssociatedObject(maskLayer, MaskCornerRadiusRadius) floatValue];
    UIRectCorner corners = [objc_getAssociatedObject(maskLayer, MaskCornerRadiusCorners) unsignedIntegerValue];
    CGFloat borderWidth = [objc_getAssociatedObject(maskLayer, MaskCornerRadiusBorderWidth) floatValue];
    UIColor * borderColor = objc_getAssociatedObject(maskLayer, MaskCornerRadiusBorderColor);
    
    if (!_imageSet) {
        _imageSet = [NSMutableSet new];
    }
    
    __block UIImage * image = nil;
    
    // 获取图片存储的信息
    [_imageSet enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, BOOL * _Nonnull stop) {
        
        CGSize imageSize = [objc_getAssociatedObject(obj, ImageSize) CGSizeValue];
        UIColor * imageCornerColor = objc_getAssociatedObject(obj, ImageCornerColor);
        CGFloat imageRadius = [objc_getAssociatedObject(obj, ImageRadius) floatValue];
        UIRectCorner imageCorners = [objc_getAssociatedObject(obj, ImageCorners) unsignedIntegerValue];
        CGFloat imageBorderWidth = [objc_getAssociatedObject(obj, ImageBorderWidth) floatValue];
        UIColor * imageBorderColor = objc_getAssociatedObject(obj, ImageBorderColor);
                                      
        BOOL isBorderSame = (CGColorEqualToColor(borderColor.CGColor, imageBorderColor.CGColor) && borderWidth == imageBorderWidth) || (!borderColor && !imageBorderColor) || (!borderWidth && !imageBorderWidth);
        
        // 判断是否可以重复利用
        BOOL canReuse = CGSizeEqualToSize(self.bounds.size, imageSize) && CGColorEqualToColor(imageCornerColor.CGColor, cornerColor.CGColor) && imageCorners == corners && radius == imageRadius && isBorderSame;
        
        if (canReuse) {
            image = obj;
            *stop = YES;
        }
    }];
    
    if (!image) {
        image = [UIImage maskRoundCornerRadiusImageWithColor:cornerColor
                                                      radius:radius
                                                        size:self.bounds.size
                                                     corners:corners
                                                 borderColor:borderColor
                                                 borderWidth:borderWidth];
        
        objc_setAssociatedObject(image, ImageSize, [NSValue valueWithCGSize:self.bounds.size], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(image, ImageCornerColor, cornerColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(image, ImageRadius, @(radius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(image, ImageCorners, @(corners), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (borderColor) {
            objc_setAssociatedObject(image, ImageBorderColor, borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        objc_setAssociatedObject(image, ImageBorderWidth, @(borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [_imageSet addObject:image];
    }
    return image;
}

@end




@implementation UIView (CornerRadius)
/// 实际由 layer 实现功能
- (void)cornerRadiusWithRadius:(CGFloat)radius cornerColor:(UIColor *)cornerColor
{
    [self.layer cornerRadiusWithRadius:radius cornerColor:cornerColor];
}

- (void)cornerRadiusWithRadius:(CGFloat)radius cornerColor:(UIColor *)cornerColor corners:(UIRectCorner)corners
{
    [self.layer cornerRadiusWithRadius:radius cornerColor:cornerColor corners:corners];
}

- (void)cornerRadiusWithRadius:(CGFloat)radius cornerColor:(UIColor *)cornerColor corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    [self.layer cornerRadiusWithRadius:radius cornerColor:cornerColor corners:corners borderWidth:borderWidth borderColor:borderColor];
}

@end
