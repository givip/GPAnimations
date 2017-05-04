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

static CGFloat const kShapeSize = 100;

@interface ViewController ()

@property (nonatomic) CAShapeLayer *shape;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shape = [self createLayerWithCenter:self.view.center];
    [self.view.layer addSublayer:self.shape];
    
//    CAAnimationGroup *animGroup = [self createAnimationGroup:[self colorChangeOne], nil];
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:
                            [self zRotationAnimation],
                            [self xRotationAnimation],
                            [self yRotationAnimation],
//                            [self colorChangeOne],
                            [self colorChangeTwo],
                            nil];
    animGroup.repeatCount = INFINITY;
    animGroup.duration = 4.0;
    [self.shape addAnimation:animGroup forKey:@"MyAnimation"];
    
}

- (CABasicAnimation *)colorChangeOne {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    animation.toValue = (__bridge id _Nullable)([UIColor redColor].CGColor);
    animation.duration = 0;
    animation.beginTime = 1;
    return animation;
}

- (CABasicAnimation *)colorChangeTwo {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    animation.toValue = (__bridge id _Nullable)([UIColor blackColor].CGColor);
    animation.duration = 0;
    animation.beginTime = 3;
    return animation;
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
    rotate.beginTime = 1;
    return rotate;
}

- (CABasicAnimation *)yRotationAnimation {
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotate.toValue = @(-M_PI); // The angle we are rotating to
    rotate.duration = 1.0;
    rotate.beginTime = 1;
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
    square.fillColor = [UIColor blueColor].CGColor;
    square.backgroundColor = [UIColor clearColor].CGColor;
    square.position = center;
    return square;
}
@end
