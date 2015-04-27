//
//  RootViewController.m
//  iaccepted
//
//  Created by iaccepted on 15/4/21.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#import "RootViewController.h"
#import "OpenglView.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)loadView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    OpenglView *glView = [[OpenglView alloc] initWithFrame:frame];
    self.view = glView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"memory warning");
    // Dispose of any resources that can be recreated.
}

@end
