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

@property (nonatomic, strong) GOSSpinnerView *spinner;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.spinner = [[GOSSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    self.spinner.center = self.view.center;
    [self.view addSubview:self.spinner];
    
    [self.spinner startAnimation];
}
- (IBAction)stopButton:(id)sender {
    [self.spinner stopAnimation];
}

@end
