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
    
    GOSSpinnerView *spinner = [[GOSSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    spinner.center = self.view.center;
//    spinner.clipsToBounds = YES;
    [self.view addSubview:spinner];
    
    [spinner startAnimation];
}

@end
