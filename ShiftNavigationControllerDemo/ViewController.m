//
//  ViewController.m
//  ShiftNavigationControllerDemo
//
//  Created by 杨晴贺 on 2017/3/5.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)backRoot:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES] ;
}


@end
