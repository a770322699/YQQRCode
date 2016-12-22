//
//  ViewController.m
//  Demo
//
//  Created by maygolf on 16/12/19.
//  Copyright © 2016年 yiquan. All rights reserved.
//

#import "ViewController.h"

#import "YQScanQRView.h"

@interface ViewController ()

@property (nonatomic, strong) YQScanQRView *scanView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    _scanView = [[YQScanQRView alloc] initWithFrame:self.view.bounds];
    _scanView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _scanView.backgroundColor = [UIColor clearColor];
    _scanView.borderFrame = CGRectMake(50, 100, 300, 300);
    _scanView.alertText = @"将取景框对准订单条形码活二维码 即可自动验证订单";
    [self.view addSubview:_scanView];
    
    UIButton *star = [UIButton buttonWithType:UIButtonTypeSystem];
    [star setTitle:@"star" forState:UIControlStateNormal];
    star.frame = CGRectMake(30, 50, 100, 50);
    [star addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:star];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)start{
    if (self.scanView.isScaning == NO) {
        [self.scanView start];
    }
}

@end
