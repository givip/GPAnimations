//
//  GOSSpinnerView.h
//  GovernmentService
//
//  Created by Givi Pataridze on 03.05.17.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOSSpinnerView : UIView

- (void)startAnimation;
- (void)stopAnimation;

- (instancetype)initWithFrame:(CGRect)frame edgeRoundness:(CGFloat)edgeRoundness;

@end
