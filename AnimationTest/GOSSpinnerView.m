//
//  GOSSpinnerView.m
//  GovernmentService
//
//  Created by Givi Pataridze on 03.05.17.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "GOSSpinnerView.h"

static CGFloat const GOSHexagoneRoundness = 0.14f; /**< Стандартное значение параметра edgeRoundness при инициализации*/
static CGFloat const GOSAnimationTime = 6.0f; /**< Момент изменения цвета при втором вращении*/

static CGFloat const GOSRotationStartTimeFront = 1.0f; /**< Начало прямой анимации вращения по осям X и Y*/
static CGFloat const GOSRotationStartTimeBack = 4.0f; /**< Начало обратной анимации вращения по осям X и Y*/
static CGFloat const GOSColorChangeStartTimeFront = 1.5f; /**< Момент изменения цвета при первом вращении*/
static CGFloat const GOSColorChangeStartTimeBack = 4.5f; /**< Момент изменения цвета при втором вращении*/

static CGFloat const GOSMaskCircleRadiusRelatively = 0.98f; /**< Радиус окружности-маски для скругления углов шестиугольника*/

@interface GOSSpinnerView ()

@property (nonatomic, strong) CAShapeLayer *hexagone; /**< Слой шестиугольника*/
@property (nonatomic, strong) UIColor *frontSideColor; /**< Первый цвет лоадера*/
@property (nonatomic, strong) UIColor *backSideColor; /**< Второй цвет лоадера*/

@end

@implementation GOSSpinnerView

- (void)startAnimation
{
    [self stopAnimation];
    CAAnimationGroup *animGroup = [self createAnimationGroupWithAnimations:
                                   [self zRotationAnimation],
                                   [self rotationAnimationWithAngle:M_PI axis:@"x" startFrom:GOSRotationStartTimeFront],
                                   [self rotationAnimationWithAngle:-M_PI axis:@"y" startFrom:GOSRotationStartTimeFront],
                                   [self rotationAnimationWithAngle:M_PI axis:@"x" startFrom:GOSRotationStartTimeBack],
                                   [self rotationAnimationWithAngle:-M_PI axis:@"y" startFrom:GOSRotationStartTimeBack],
                                   [self animationChangeToColor:self.backSideColor startFrom:GOSColorChangeStartTimeFront],
                                   [self animationChangeToColor:self.frontSideColor startFrom:GOSColorChangeStartTimeBack],
                                   nil];
    animGroup.repeatCount = INFINITY;
    animGroup.duration = GOSAnimationTime;
    
    [self.hexagone addAnimation:animGroup forKey:@"GOSLoaderAnimation"];
}

- (void)stopAnimation
{
    [self.hexagone removeAllAnimations];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame edgeRoundness:GOSHexagoneRoundness];
}


- (instancetype)initWithFrame:(CGRect)frame edgeRoundness:(CGFloat)edgeRoundness;
{
    if (self)
    {
        self = [super initWithFrame:frame];
        
        CGFloat radius = frame.size.width / 2.0;
        CGFloat cornerRadius = radius * GOSMaskCircleRadiusRelatively;
        
        _frontSideColor = [UIColor colorWithRed:20.0/255.0
                                          green:102.0/255.0
                                           blue:172.0/255.0
                                          alpha:1.0];
        _backSideColor = [UIColor colorWithRed:239.0/255.0
                                         green:64.0/255.0
                                          blue:88.0/255.0
                                         alpha:1.0];
        
        _hexagone = [self createHexagoneLayerWithRadius:radius withRoundness:edgeRoundness];
        _hexagone.fillColor = _frontSideColor.CGColor;
        _hexagone.position = self.center;
        
        CAShapeLayer *circleMask = [self createCircleLayerWithRadius:cornerRadius];
        _hexagone.mask = circleMask;
        
        [self.layer addSublayer:_hexagone];
    }
    return self;
}

#pragma mark- Loader animation methods
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
    rotate.repeatCount = INFINITY;
    return rotate;
}

- (CABasicAnimation *)rotationAnimationWithAngle:(CGFloat)angle axis:(NSString *)axis startFrom:(CGFloat)start {
    /// Проверка значения оси на допустимое значение
    if (![axis isEqualToString:@"y"] && ![axis isEqualToString:@"x"])
    {
        return nil;
    }
    NSString *animationKeyPath = [NSString stringWithFormat:@"%@%@", @"transform.rotation.", axis];
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:animationKeyPath];
    rotate.toValue = @(angle);
    rotate.duration = 1.0;
    rotate.beginTime = start;
    return rotate;
}

- (CAAnimationGroup *)createAnimationGroupWithAnimations:(CAAnimation *)animation, ... NS_REQUIRES_NIL_TERMINATION {
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
    CGPoint center = self.hexagone.position;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:0.0
                                                      endAngle:2*M_PI
                                                     clockwise:0];
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
                                                              containerSize:CGSizeMake(2.0 * radius, 2.0 * radius)];
    UIBezierPath *path = [self hexagoneWithPoints:hexagoneVertexes roundness:roundness];
    CAShapeLayer *square = [CAShapeLayer layer];
    square.path = path.CGPath;
    square.masksToBounds = YES;
    square.miterLimit = 0;
    square.frame = CGRectMake(0, 0, radius * 2.0, radius * 2.0);
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
        [path addQuadCurveToPoint:vertex controlPoint:controlPoint];
        prevPoint = vertex;
    }
    return path;
}

#pragma mark- Hexagone vertexes calculation
- (NSArray<NSValue *> *)hexagoneVertexesWithCenter:(CGPoint)center radius:(CGFloat)radius containerSize:(CGSize)size
{
    /// Контейнер должен быть квадратный
    if (size.height != size.width)
    {
        return nil;
    }
    CGFloat containerSide = size.width;
    
    CGFloat inset = (containerSide - (2.0 * radius)) / 2.0;
    
    CGFloat xOffset = radius * cos(M_PI / 6.0);
    CGFloat yOffset = radius * sin(M_PI / 6.0);
    
    CGPoint h0 = CGPointMake(inset + radius, inset + (2.0 * radius));
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

#pragma mark- Control points for hexagone Bezier Path
- (CGPoint)controlPointBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2 roundness:(CGFloat)roundness
{
    /// Параметр скругления должен быть на отрезке [0;1]
    /// Если это условие не выполняется, то рисуются прямые линии
    CGPoint center = CGPointMake((p2.x + p1.x) / 2, (p2.y + p1.y) / 2);
    if (!(fabs(roundness) <= 1))
    {
        return center;
    }
    
    CGFloat distance = sqrt(pow((p2.x - p1.x), 2) + pow((p2.y - p1.y), 2));
    CGFloat length = roundness * distance;
    CGFloat h = fabs(p2.y - p1.y);
    CGFloat w = fabs(p2.x - p1.x);
    CGFloat controlPointXOffset = length * cos(M_PI_2 - atan(h/w));
    CGFloat controlPointYOffset = length * sin(M_PI_2 - atan(h/w));
    
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
