//
//  ViewController.m
//  AnimationTest
//
//  Created by Givi Pataridze on 24.04.17.
//  Copyright © 2017 Givi Pataridze. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "GOSSpinnerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *spinner = [[GOSSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    spinner.center = self.view.center;
    spinner.clipsToBounds = YES;
//    spinner.layer.borderColor = [UIColor grayColor].CGColor;
//    spinner.layer.borderWidth = 1.0f;
    [self.view addSubview:spinner];
}

@end
