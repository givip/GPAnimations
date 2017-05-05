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
    
    UIView *spinner = [[GOSSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    spinner.center = self.view.center;
    spinner.clipsToBounds = YES;
    [self.view addSubview:spinner];
}

@end
