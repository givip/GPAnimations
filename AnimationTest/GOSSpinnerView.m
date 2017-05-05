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

static CGFloat const kHexagoneRoundness = 0.14f;

@interface GOSSpinnerView ()

@property (nonatomic, assign) CGSize shapeSize;
@property (nonatomic, strong) CAShapeLayer *frontShape;
//@property (nonatomic, assign) CGSize containerSize;

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
    return [self initWithFrame:frame edgeRoundness:kHexagoneRoundness];
}


- (instancetype)initWithFrame:(CGRect)frame edgeRoundness:(CGFloat)edgeRoundness;
{
    if (self)
    {
        self = [super initWithFrame:frame];
        
        CGFloat radius = self.frame.size.width/2;
        CGFloat cornerRadius = radius*0.98f;
        
        UIColor *first = [UIColor colorWithRed:20.0/255.0 green:102.0/255.0 blue:172.0/255.0 alpha:1.0];
        UIColor *second = [UIColor colorWithRed:239.0/255.0 green:64.0/255.0 blue:88.0/255.0 alpha:1.0];
        
        self.frontShape = [self createHexagoneLayerWithRadius:radius withRoundness:edgeRoundness];
        self.frontShape.fillColor = first.CGColor;
        self.frontShape.position = self.center;
        
        CAShapeLayer *circleMask = [self createCircleLayerWithRadius:cornerRadius];
        
        self.frontShape.mask = circleMask;
        [self.layer addSublayer:self.frontShape];

        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = [NSArray arrayWithObjects:
                                [self zRotationAnimation],
                                [self xRotationAnimationWithAngle:M_PI startFrom:1.0f],
                                [self yRotationAnimationWithAngle:-M_PI startFrom:1.0f],
                                [self xRotationAnimationWithAngle:-M_PI startFrom:4.0f],
                                [self yRotationAnimationWithAngle:M_PI startFrom:4.0f],
                                [self animationChangeToColor:second startFrom:1.5f],
                                [self animationChangeToColor:first startFrom:4.5f],
                                nil];
        animGroup.repeatCount = INFINITY;
        animGroup.duration = 6.0f;
       
        [self.frontShape addAnimation:animGroup forKey:@"GroupAnimation"];
    }
    return self;
}


- (CABasicAnimation *)animationChangeToColor:(UIColor *)color startFrom:(CGFloat)start {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    animation.toValue = (__bridge id _Nullable)(color.CGColor);
    animation.duration = 0.001f;
    animation.fillMode = kCAFillModeForwards;
    animation.cumulative = YES;
    animation.beginTime = start;
    return animation;
}

- (CABasicAnimation *)zRotationAnimation {
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.toValue = @(2 * M_PI);
    rotate.duration = 2.0;
    rotate.additive = YES;
    rotate.repeatCount = INFINITY;
    return rotate;
}

- (CABasicAnimation *)xRotationAnimationWithAngle:(CGFloat)angle startFrom:(CGFloat)start {
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotate.toValue = @(angle);
    rotate.duration = 1.0;
    rotate.beginTime = start;
    
    return rotate;
}

- (CABasicAnimation *)yRotationAnimationWithAngle:(CGFloat)angle startFrom:(CGFloat)start {
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotate.toValue = @(angle);
    rotate.duration = 1.0;
    rotate.beginTime = start;
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
    return group;
}

#pragma mark- Circle mask drawing
- (CAShapeLayer *)createCircleLayerWithRadius:(CGFloat)radius
{
    CGPoint center = self.frontShape.position;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:0];
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = path.CGPath;
    circle.fillRule = kCAFillRuleEvenOdd;
    circle.backgroundColor = [UIColor clearColor].CGColor;
    return circle;
}

#pragma mark- Hexagone drawing
- (CAShapeLayer *)createHexagoneLayerWithRadius:(CGFloat)radius withRoundness:(CGFloat)roundness
{
    CGPoint center = self.layer.position;
    NSArray<NSValue *> *hexagoneVertexes = [self hexagoneVertexesWithCenter:center
                                                                     radius:radius
                                                              containerSize:CGSizeMake(radius*2, radius*2)];
    UIBezierPath *path = [self hexagoneWithPoints:hexagoneVertexes roundness:roundness];
    CAShapeLayer *square = [CAShapeLayer layer];
    square.path = path.CGPath;
    square.masksToBounds = YES;
    square.miterLimit = 0;
    square.frame = CGRectMake(0, 0, radius*2, radius*2);
    square.backgroundColor = [UIColor clearColor].CGColor;
    return square;
}

#pragma mark- Hexagone path drawing
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

#pragma mark- Hexagone vertexes calculation
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

#pragma mark- Bezier Path control point calculation for hexagone
- (CGPoint)controlPointBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2 roundness:(CGFloat)roundness
{
    NSAssert (fabs(roundness) <= 1, @"Параметр скругления должен быть на отрезке [0;1]");
    CGFloat distance = sqrt(pow((p2.x - p1.x), 2) + pow((p2.y - p1.y), 2));
    CGFloat length = roundness * distance;
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


@end
