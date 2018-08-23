//
//  MABarProgressView.m
//  MABarProgressViewDemo
//
//  Created by admin on 2018/1/11.
//  Copyright © 2018年 ma. All rights reserved.
//

#import "MABarProgressView.h"

@implementation MABarProgressView

- (instancetype)init{
    return [self initWithFrame:CGRectMake(0.f, 0.f, 120.f, 20.f)];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _progress = 0.f;
        _lineColor = [UIColor grayColor];
        _progressColor = [UIColor grayColor];
        _progressRemainingColor = [UIColor clearColor];
        _isCylindroid = NO;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        _outInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        _inInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    }
    return self;
}

- (CGSize)intrinsicContentSize{
    return CGSizeMake(120.f, 10.f);
}

- (void)setProgress:(float)progress{
    if (progress != _progress) {
        _progress = progress;
        [self setNeedsDisplay];
    }
}

- (void)setOutInsets:(UIEdgeInsets)outInsets{
    if (UIEdgeInsetsEqualToEdgeInsets(outInsets, _outInsets)) {
        _outInsets = outInsets;
        [self setNeedsDisplay];
    }
}

- (void)setInInsets:(UIEdgeInsets)inInsets{
    if (UIEdgeInsetsEqualToEdgeInsets(inInsets, _inInsets)) {
        _inInsets = inInsets;
        [self setNeedsDisplay];
    }
}

- (void)setProgressColor:(UIColor *)progressColor {
    NSAssert(progressColor, @"The color should not be nil.");
    if (progressColor != _progressColor && ![progressColor isEqual:_progressColor]) {
        _progressColor = progressColor;
        [self setNeedsDisplay];
    }
}

- (void)setProgressRemainingColor:(UIColor *)progressRemainingColor {
    NSAssert(progressRemainingColor, @"The color should not be nil.");
    if (progressRemainingColor != _progressRemainingColor && ![progressRemainingColor isEqual:_progressRemainingColor]) {
        _progressRemainingColor = progressRemainingColor;
        [self setNeedsDisplay];
    }
}

- (void)setIsCylindroid:(BOOL)isCylindroid{
    if (isCylindroid != _isCylindroid) {
        _isCylindroid = isCylindroid;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPathRef path = CGPathCreateWithCylindroidPath(rect, self.outInsets);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    [_lineColor setStroke];
    [_progressRemainingColor setFill];
    CGContextDrawPath(context, kCGPathStroke);
    
    CGPathRef path1 = CGPathCreateWithCylindroidProgressPath(rect, UIEdgeInsetsMake(self.outInsets.top+self.inInsets.top, self.outInsets.left+self.inInsets.left, self.outInsets.bottom+self.inInsets.bottom, self.outInsets.right+self.inInsets.right), self.progress, self.isCylindroid);
    CGContextAddPath(context, path1);
    CGPathRelease(path1);
    [_progressColor set];
    CGContextDrawPath(context, kCGPathFill);
}

#define MID(X,A,B) MAX(MIN(X,B),A)
/**
 创建椭圆进度条
 
 @param rect 进度条的总范围
 @param inserts 间距
 @param progress 进度 0-1
 @param isCylindroid 是否一直保持椭圆,否的话,右边为矩形
 @return 返回路径
 */
CG_EXTERN CGMutablePathRef CGPathCreateWithCylindroidProgressPath(CGRect rect, UIEdgeInsets inserts, CGFloat progress, BOOL isCylindroid){
    progress = MID(progress,0,1);
    if (isCylindroid) {
        // 如果使用椭圆进度,则通过修改宽度使用画椭圆的函数即可
        CGFloat width = rect.size.width - rect.size.height;
        rect.size.width = rect.size.height + (width * progress);
        return CGPathCreateWithCylindroidPath(rect, inserts);
    }else{
        // 先将矩形减去inserts
        rect = UIEdgeInsetsInsetRect(rect, inserts);
        // 进度的宽度
        CGFloat amount = rect.size.width * progress;
        // 左右两边圆弧的半径
        CGFloat radius = rect.size.height/2;
        CGFloat width = rect.size.width;
        CGFloat height = rect.size.height;
        // 路径的偏移量
        CGAffineTransform translation = CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y);
        // 创建一个可变路径
        CGMutablePathRef path = CGPathCreateMutable();
        // 进度分为三部分
        if (amount  < radius && amount > 0) {// 1.宽度小于半径 http://upload-images.jianshu.io/upload_images/1429831-f2b9a679b7c39619.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/800
            // 图1的x
            CGFloat x = radius - amount;
            // 图1的y,根据勾股定理计算
            CGFloat y = radius - sqrt(pow(radius, 2)-pow(x, 2));
            // 图1的topPoint
            CGPoint topPoint = CGPointMake(amount, y);
            // 使用acos计算出直角三角形的角度
            CGFloat angle = acos(x/radius);
            if (isnan(angle)) angle = 0;
            // 将路径的起始点移动到topPoint
            CGPathMoveToPoint(path, &translation, topPoint.x, topPoint.y);
            // 画圆弧,原点为(raduis,raduis),半径为raduis,startAngle和endAngle如图1,最后一个参数为是否顺序画圆弧,但实际绘图结果会是逆时针的,也就是说设置为NO,绘图时才是顺时针
            CGPathAddArc(path, &translation, radius, radius, radius, M_PI - angle, M_PI + angle, 0);
        }else if (amount >= radius && amount <= width - radius){// 2.宽度大于圆弧的半径且小于最大宽度减半径 http://upload-images.jianshu.io/upload_images/1429831-42f16f05018ee651.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/800
            // 起点
            CGPathMoveToPoint(path, &translation, 0, radius);
            // 画圆弧,图2.1
            CGPathAddArcToPoint(path, &translation, 0, 0, radius, 0, radius);
            // 图2.2
            CGPathAddLineToPoint(path, &translation, amount, 0);
            // 图2.3
            CGPathAddLineToPoint(path, &translation, amount, radius);
            // 移动点的位置
            CGPathMoveToPoint(path, &translation, 0, radius);
            // 图2.4
            CGPathAddArcToPoint(path, &translation, 0, height, radius, height, radius);
            // 图2.5
            CGPathAddLineToPoint(path, &translation, amount, height);
            // 图2.6
            CGPathAddLineToPoint(path, &translation, amount, radius);
        }else{// 3.宽度大于最大宽度减半径 http://upload-images.jianshu.io/upload_images/1429831-5d18c924c7b12344.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/800
            CGPathMoveToPoint(path, &translation, 0, radius);
            
            CGFloat x = amount - (width - radius);
            // 图3.1
            CGPathAddArcToPoint(path, &translation, 0, 0, radius, 0, radius);
            // 图3.2
            CGPathAddLineToPoint(path, &translation, width - radius, 0);
            CGFloat angle = acos(x/radius);
            if (isnan(angle)) angle = 0;
            // 图3.3
            CGPathAddArc(path, &translation, width - radius, radius, radius, M_PI, -angle, 0);
            // 图3.4
            CGPathAddLineToPoint(path, &translation, amount, radius);

            CGPathMoveToPoint(path, &translation, 0, radius);
            // 图3.5
            CGPathAddArcToPoint(path, &translation, 0, height, radius, height, radius);
            // 图3.6
            CGPathAddLineToPoint(path, &translation, width - radius, height);
            // 图3.7
            CGPathAddArc(path, &translation, width - radius, radius, radius, -M_PI, angle, 1);
            // 图3.8
            CGPathAddLineToPoint(path, &translation, amount, radius);
        }
        return path;
    }
}
/**
 创建椭圆形
 
 @param rect 椭圆的范围
 @param inserts 间距
 @return 返回路径
 */
CG_EXTERN CGMutablePathRef CGPathCreateWithCylindroidPath(CGRect rect, UIEdgeInsets inserts){
    // 先将矩形减去inserts
    rect = UIEdgeInsetsInsetRect(rect, inserts);
    // 左右圆的半径
    CGFloat radius = rect.size.height/2;
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    // 路径的偏移量
    CGAffineTransform translation = CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y);
    
    // 创建一个可变路径
    CGMutablePathRef path = CGPathCreateMutable();
    // 起点
    CGPathMoveToPoint(path, &translation, 0, radius);
    // 画圆弧
    CGPathAddArcToPoint(path, &translation, 0, 0, radius, 0, radius);
    CGPathAddArcToPoint(path, &translation, width, 0, width, radius , radius);
    CGPathAddArcToPoint(path, &translation, width, height, width - radius, height, radius);
    CGPathAddArcToPoint(path, &translation, 0, height, 0, radius, radius);
    
    return path;
}

@end
