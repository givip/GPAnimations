//
//  GOSSpinnerView.m
//  GovernmentService
//
//  Created by Givi Pataridze on 03.05.17.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "GOSSpinnerView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

static CGFloat const kShapeSize = 80;
static CGFloat const kContainerSize = 200;

@interface GOSSpinnerView ()

@property (nonatomic, strong) CAShapeLayer *shape;

@end

@implementation GOSSpinnerView

- (void)startAnimation
{
    
}

- (void)stopAnimation
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self)
    {
        self = [super initWithFrame:frame];
        self.shape = [self loaderShapeLayer];
        
        [self.layer addSublayer:self.shape];
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = [NSArray arrayWithObjects:
                                [self zRotationAnimation],
                                [self xRotationAnimation],
                                [self yRotationAnimation],
                                nil];
        animGroup.repeatCount = INFINITY;
        animGroup.duration = 4.0f;
       
//        [self.layer addAnimation:animGroup forKey:@"GroupAnimation"];
//        [self.shape addAnimation:[self changeColorAnimation] forKey:@"ColorChangeAnimation"];
    }
    return self;
}

- (void)clearContext:(CGContextRef)context
{
    CGContextClearRect(context, self.bounds);
    CGContextSetRGBFillColor(context, 255, 255, 255, 1);
}

- (CAShapeLayer *)loaderShapeLayer
{
    NSAssert(2 * kShapeSize <= kContainerSize, @"Контейнер не вмещает фигуру");
    
    CGPoint center = self.layer.position;
    NSArray<NSValue *> *hexagoneVertexes = [self hexagoneVertexesWithCenter:center
                                                                     radius:kShapeSize
                                                              containerSize:CGSizeMake(kContainerSize, kContainerSize)];
    UIBezierPath *path = [self hexagoneWithPoints:hexagoneVertexes roundness:0.85f];
    CAShapeLayer *square = [CAShapeLayer layer];
    square.path = path.CGPath;
    square.fillColor = [UIColor blueColor].CGColor;
    square.backgroundColor = [UIColor clearColor].CGColor;
    return square;
}

- (UIBezierPath *)hexagoneWithPoints:(NSArray<NSValue *> *)points roundness:(CGFloat)roundness
{

    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    if (points.count == 0)
    {
        return path;
    }
    CGPoint begin = points[0].CGPointValue;
    [path moveToPoint:begin];
    CGPoint prevPoint = begin;

    for (NSUInteger step = 0; step < points.count; step++)
    {
        CGPoint vertex;
        if (step == points.count - 1)
        {
            vertex = points[0].CGPointValue;
        }
        else
        {
            vertex = points[step+1].CGPointValue;
        }
        
        CGPoint controlPoint = [self controlPointBetweenPoint:prevPoint andPoint:vertex roundness:roundness];
        NSLog(@"Vertex #%lu: x= %f , y= %f -- ControlPoint: x= %f , y= %f", step, vertex.x, vertex.y, controlPoint.x, controlPoint.y);
        [path addQuadCurveToPoint:vertex controlPoint:controlPoint];
        prevPoint = vertex;
    }
    return path;
}

- (NSArray<NSValue *> *)hexagoneVertexesWithCenter:(CGPoint)center radius:(CGFloat)radius containerSize:(CGSize)size
{
    NSAssert(size.height == size.width, @"Контейнер не квадратный");
    CGFloat containerSide = size.width;
    
    CGFloat inset = (containerSide - (2 * radius)) / 2;
    
    CGFloat xOffset = radius * cos(M_PI/6);
    CGFloat yOffset = radius * sin(M_PI/6);
    
    CGPoint h0 = CGPointMake(inset + radius, inset + (2 * radius));
    CGPoint h1 = CGPointMake(inset + radius + xOffset, inset + radius + yOffset);
    CGPoint h2 = CGPointMake(inset + radius + xOffset, inset + radius - yOffset);
    CGPoint h3 = CGPointMake(inset + radius, inset);
    CGPoint h4 = CGPointMake(inset + radius - xOffset, inset + radius - yOffset);
    CGPoint h5 = CGPointMake(inset + radius - xOffset, inset + radius + yOffset);
    
    return @[
             [NSValue valueWithCGPoint:h0],
             [NSValue valueWithCGPoint:h1],
             [NSValue valueWithCGPoint:h2],
             [NSValue valueWithCGPoint:h3],
             [NSValue valueWithCGPoint:h4],
             [NSValue valueWithCGPoint:h5]
             ];
}

- (CGPoint)controlPointBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2 roundness:(CGFloat)roundness
{
    NSAssert (fabs(roundness) < 1, @"Параметр скругления должен быть на отрезке [-1;1]");
    CGFloat distance = sqrt(pow((p2.x - p1.x), 2) + pow((p2.y - p1.y), 2));
    CGFloat length = distance * (1 - roundness);
    CGFloat h = fabs(p2.y - p1.y);
    CGFloat w = fabs(p2.x - p1.x);
    CGFloat controlPointXOffset = length * cos(M_PI_2 - atan(h/w));
    CGFloat controlPointYOffset = length * sin(M_PI_2 - atan(h/w));
    CGPoint center = CGPointMake((p2.x + p1.x)/2, (p2.y + p1.y)/2);
    CGFloat controlPointXAbsOffset;
    CGFloat controlPointYAbsOffset;
    if (p1.x <= p2.x)
    {
        if (p1.y <= p2.y)
        {
            controlPointXAbsOffset = center.x - controlPointXOffset;
            controlPointYAbsOffset = center.y + controlPointYOffset;
        }
        else
        {
            controlPointXAbsOffset = center.x + controlPointXOffset;
            controlPointYAbsOffset = center.y + controlPointYOffset;
        }
    }
    else
    {
        if (p1.y <= p2.y)
        {
            controlPointXAbsOffset = center.x - controlPointXOffset;
            controlPointYAbsOffset = center.y - controlPointYOffset;
        }
        else
        {
            controlPointXAbsOffset = center.x + controlPointXOffset;
            controlPointYAbsOffset = center.y - controlPointYOffset;
        }
    }
    return CGPointMake(controlPointXAbsOffset, controlPointYAbsOffset);
}

- (CAKeyframeAnimation *)changeColorAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"fillColor"];
    animation.values = [NSArray arrayWithObjects: (id)[UIColor redColor].CGColor, (id)[UIColor blackColor].CGColor, nil];
    animation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.5], [NSNumber numberWithFloat:3.0], nil];
    animation.calculationMode = kCAAnimationPaced;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 4.0f;
//    animation.beginTime = 1.5f;
    animation.repeatCount = INFINITY;
    return animation;
}

- (CABasicAnimation *)colorChangeOne {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    animation.toValue = (__bridge id _Nullable)([UIColor redColor].CGColor);
    animation.duration = 0;
    animation.beginTime = 1.5f;
    return animation;
}

- (CABasicAnimation *)colorChangeTwo {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    animation.toValue = (__bridge id _Nullable)([UIColor blackColor].CGColor);
    animation.duration = 0;
    animation.beginTime = 3.0f;
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