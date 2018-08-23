//
//  MABarProgressView.h
//  MABarProgressViewDemo
//
//  Created by admin on 2018/1/11.
//  Copyright © 2018年 ma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MABarProgressView : UIView

@property (nonatomic, assign) float progress;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *progressRemainingColor;
@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic, assign) UIEdgeInsets outInsets;
@property (nonatomic, assign) UIEdgeInsets  inInsets;

@property (nonatomic, assign) BOOL isCylindroid;

@end
