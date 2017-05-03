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

static CGFloat const kShapeSize = 50;

@interface ViewController ()

@property (nonatomic) CAShapeLayer *shape;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shape = [self createLayerWithCenter:self.view.center];
    [self.view.layer addSublayer:self.shape];
//    [self addAnimation];
    
//    CAAnimationGroup *animGroup = [self createAnimationGroup:[self zRotationAnimation], [self xRotationAnimation], nil];
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:[self zRotationAnimation], [self xRotationAnimation], nil];
    animGroup.repeatCount = 20;
    animGroup.duration = 2.0;
    [self.shape addAnimation:animGroup forKey:@"MyAnimation"];
    
}

- (void)addAnimation {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"position.y";
    animation.duration = 1;
    
    [self.view.layer addAnimation:animation forKey:@"basic"];
}

- (CABasicAnimation *)zRotationAnimation {
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.toValue = @(2 * M_PI); // The angle we are rotating to
    rotate.duration = 2.0;
    rotate.repeatCount = INFINITY;
    return rotate;
}

- (CABasicAnimation *)xRotationAnimation {
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotate.toValue = @(M_PI); // The angle we are rotating to
    rotate.duration = 1.0;
    rotate.repeatCount = INFINITY;
//    rotate.beginTime = 5;
    return rotate;
}

- (CAAnimationGroup *)createAnimationGroup:(CAAnimation *)animation, ... NS_REQUIRES_NIL_TERMINATION {
    CAAnimationGroup *group = [CAAnimationGroup animation];
    NSMutableArray *animations = [NSMutableArray new];
    va_list args;
    va_start(args, animation);
    for (CAAnimation *arg = animation; arg != nil; arg = va_arg(args, CAAnimation*))
    {
        [animations addObject:arg];
    }
    va_end(args);
   
    group.animations = [animations copy];
    group.duration = INFINITY;
    return group;
}

- (CAShapeLayer *)createLayerWithCenter:(CGPoint)center {
    CAShapeLayer *square = [CAShapeLayer layer];
    CGRect rect = CGRectMake(0, 0, kShapeSize, kShapeSize);
    square.bounds = rect;
    square.path = [UIBezierPath bezierPathWithRect:rect].CGPath;
    square.fillColor = [UIColor redColor].CGColor;
    square.position = center;
    return square;
}
@end
