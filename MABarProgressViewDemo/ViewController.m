//
//  ViewController.m
//  MABarProgressViewDemo
//
//  Created by admin on 2018/1/11.
//  Copyright © 2018年 ma. All rights reserved.
//

#import "ViewController.h"
#import "MABarProgressView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    MABarProgressView *progressView = [[MABarProgressView alloc] initWithFrame:CGRectMake(100, 100, 120, 40)];
    progressView.center = self.view.center;
    progressView.lineColor = [UIColor redColor];
    progressView.progressRemainingColor = [UIColor yellowColor];
    progressView.progressColor = [UIColor blueColor];
    progressView.tag = 123456;
    progressView.isCylindroid = YES;
    progressView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:progressView];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)updateTime:(NSTimer *)timer{

    self.view.tag+=1;
    
    CGFloat progress = self.view.tag / 40.f;
    
    ((MABarProgressView *)[self.view viewWithTag:123456]).progress = progress;
    
    if (progress > 1) self.view.tag = 0;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    MABarProgressView *bar = [self.view viewWithTag:123456];
    bar.isCylindroid = !bar.isCylindroid;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
