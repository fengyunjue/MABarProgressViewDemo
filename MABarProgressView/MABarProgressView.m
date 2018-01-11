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
    
    CGFloat lineWidth = 2;
    
    CGPathRef path = CGPathCreateWithCylindroidPath(rect, lineWidth);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    [_lineColor setStroke];
    [_progressRemainingColor setFill];
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGPathRef path1 = CGPathCreateWithCylindroidProgressPath(CGRectMake(2, 2, rect.size.width-4, rect.size.height-4), lineWidth, self.progress, self.isCylindroid);
    CGContextAddPath(context, path1);
    CGPathRelease(path1);
    [_progressColor set];
    CGContextDrawPath(context, kCGPathFill);
}

#define MID(X,A,B) MAX(MIN(X,B),A)
/**
 创建椭圆进度条
 
 @param rect 进度条的总范围
 @param lineWidth lineWidth
 @param progress 进度 0-1
 @param isCylindroid 是否一直保持椭圆,否的话,右边为矩形
 @return 返回路径
 */
CG_EXTERN CGMutablePathRef CGPathCreateWithCylindroidProgressPath(CGRect rect, CGFloat lineWidth, CGFloat progress, BOOL isCylindroid){
    if (isCylindroid) {
        CGFloat width = rect.size.width - rect.size.height;
        rect.size.width = rect.size.height + (width * MID(progress,0,1));
        return CGPathCreateWithCylindroidPath(rect, lineWidth);
    }else{
        CGFloat amount = rect.size.width * MID(progress,0,1);
        
        rect = CGRectInset(rect, lineWidth, lineWidth);
        
        CGFloat radius = rect.size.height/2;
        CGFloat width = rect.size.width;
        CGFloat height = rect.size.height;
        CGAffineTransform translation = CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y);
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        if (amount <= width - radius && amount >= radius) {
            CGPathMoveToPoint(path, &translation, 0, radius);
            
            CGPathAddArcToPoint(path, &translation, 0, 0, radius, 0, radius);
            CGPathAddLineToPoint(path, &translation, amount, 0);
            CGPathAddLineToPoint(path, &translation, amount, radius);
            
            CGPathMoveToPoint(path, &translation, 0, radius);
            CGPathAddArcToPoint(path, &translation, 0, height, radius, height, radius);
            CGPathAddLineToPoint(path, &translation, amount, height);
            CGPathAddLineToPoint(path, &translation, amount, radius);
        }else if (amount > radius){
            CGPathMoveToPoint(path, &translation, 0, radius);
            
            CGFloat x = amount - (width - radius);
            CGPathAddArcToPoint(path, &translation, 0, 0, radius, 0, radius);
            CGPathAddLineToPoint(path, &translation, width - radius, 0);
            CGFloat angle = -acos(x/radius);
            if (isnan(angle)) angle = 0;
            CGPathAddArc(path, &translation, width - radius, radius, radius, M_PI, angle, 0);
            CGPathAddLineToPoint(path, &translation, amount, radius);
            
            CGPathMoveToPoint(path, &translation, 0, radius);
            CGPathAddArcToPoint(path, &translation, 0, height, radius, height, radius);
            CGPathAddLineToPoint(path, &translation, width - radius, height);
            angle = acos(x/radius);
            if (isnan(angle)) angle = 0;
            CGPathAddArc(path, &translation, width - radius, radius, radius, -M_PI, angle, 1);
            CGPathAddLineToPoint(path, &translation, amount, radius);
        }else if (amount  < radius && amount > 0){
            CGFloat x = radius - amount;// x轴三角边的长度
            CGFloat y = radius - sqrt(pow(radius, 2)-pow(x, 2));// y轴三角边的长度
            CGPoint topPoint = CGPointMake(amount, y);//
            CGFloat angle = acos(x/radius);
            CGPathMoveToPoint(path, &translation, topPoint.x, topPoint.y);
            CGPathAddArc(path, &translation, radius, radius, radius, M_PI - angle, M_PI + angle, 0);
        }
        return path;
    }
}

/**
 创建椭圆形
 
 @param rect 椭圆的范围
 @param lineWidth lineWidth
 @return 返回路径
 */
CG_EXTERN CGMutablePathRef CGPathCreateWithCylindroidPath(CGRect rect, CGFloat lineWidth){
    // 先将矩形减去lineWidth
    rect = CGRectInset(rect, lineWidth, lineWidth);
    // 左右圆的半径
    CGFloat radius = rect.size.height/2;
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    // 路径的偏移量
    CGAffineTransform translation = CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, &translation, 0, radius);
    CGPathAddArcToPoint(path, &translation, 0, 0, radius, 0, radius);
    CGPathAddArcToPoint(path, &translation, width, 0, width, radius , radius);
    CGPathAddArcToPoint(path, &translation, width, height, width - radius, height, radius);
    CGPathAddArcToPoint(path, &translation, 0, height, 0, radius, radius);
    
    return path;
}

@end
