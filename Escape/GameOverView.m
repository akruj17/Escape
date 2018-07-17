//
//  GameOverView.m
//  Escape
//
//  Created by Arjun Kunjilwar on 7/3/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "GameOverView.h"
#import "UIColor+ColorExtensions.h"

@interface GameOverView()<CAAnimationDelegate>@end

@implementation GameOverView {
    CGSize backgroundFullSize;
    CAShapeLayer *background;
    CAShapeLayer *playButton;
    CABasicAnimation *resizeAnimation, *playLayerAnimation;
    UIButton *continueButton, *skip;
}

- (instancetype)initWithFrame:(CGRect)frame belowLayer:(CALayer *)layer {
    if (self = [super initWithFrame:frame]) {
        backgroundFullSize = CGSizeMake(0.85 * self.bounds.size.width, 0.8 * self.bounds.size.height);
        CGRect bounds = CGRectMake(0, 0, backgroundFullSize.width, backgroundFullSize.height);
        background = [CAShapeLayer layer];
        background.bounds = bounds;
        background.position = self.center;
        background.fillColor = [UIColor redBackgroundColor].CGColor;
        float startRadius = 0.4 * self.bounds.size.width;
        background.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((bounds.size.width / 2) - startRadius, (bounds.size.height / 2) - startRadius, 2 * startRadius, 2 * startRadius) cornerRadius:startRadius].CGPath;
        UIBezierPath *end = [UIBezierPath bezierPathWithRoundedRect:background.bounds cornerRadius:10];
        resizeAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        [resizeAnimation setValue:@"resizeAnim" forKey:@"id"];
        resizeAnimation.delegate = self;
        resizeAnimation.toValue = (__bridge id _Nullable)(end.CGPath);
        resizeAnimation.duration = 4;
        resizeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        resizeAnimation.fillMode = kCAFillModeBoth;
        resizeAnimation.removedOnCompletion = YES;
        [self.layer addSublayer:background];
        continueButton = [[UIButton alloc] initWithFrame:CGRectMake(self.center.x - 150, self.center.y + (self.bounds.size.height * 0.05), 300, 40)];
        continueButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50];
        continueButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [continueButton setTitleColor:[UIColor blackColor] forState:normal];
        [continueButton setTitle:@"continue?" forState:normal];
        [continueButton addTarget:self action:@selector(presentAd) forControlEvents:UIControlEventTouchUpInside];
        skip = [[UIButton alloc] initWithFrame:CGRectMake(self.center.x - 100, self.center.y + (self.bounds.size.height * 0.12), 200, 40)];
        skip.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
        skip.titleLabel.textAlignment = NSTextAlignmentCenter;
        [skip setTitle:@"skip" forState:normal];
        [skip setTitleColor:[UIColor blackColor] forState:normal];
        [skip addTarget:self action:@selector(resizeAnimation) forControlEvents:UIControlEventTouchUpInside];
        [self createContinuePlayLayer];
    }
    return self;
}

- (void)createContinuePlayLayer {
    UIBezierPath *path = [UIBezierPath bezierPath];
    float startAngle = M_PI + (M_PI / 2.5);
    float radius = 0.10 * self.bounds.size.height;
    CGPoint circCenter = CGPointMake(self.center.x, self.center.y - (0.08 * self.bounds.size.height));
    [path addArcWithCenter:circCenter radius:radius startAngle:startAngle endAngle:startAngle + (M_PI * 2) clockwise:YES];
    [path moveToPoint:CGPointMake(path.currentPoint.x, circCenter.y - (radius * 0.6))];
    [path addLineToPoint:CGPointMake(path.currentPoint.x, circCenter.y + (radius * 0.6))];
    float newX = (radius * 0.6) * tanf(M_PI / 3);
    [path addLineToPoint:CGPointMake(path.currentPoint.x + newX, circCenter.y)];
    [path closePath];
    
    playButton = [CAShapeLayer layer];
    playButton.fillColor = [UIColor clearColor].CGColor;
    playButton.strokeColor = [UIColor blackColor].CGColor;
    playButton.path = path.CGPath;
    
    playLayerAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    playLayerAnimation.delegate = self;
    [playLayerAnimation setValue:@"forwardAnim" forKey:@"id"];
    playLayerAnimation.fromValue = [NSNumber numberWithDouble:0.0];
    playLayerAnimation.duration = 1;
    playLayerAnimation.removedOnCompletion = YES;
    
}

//present the gameoverview with the continue option present
- (void) presentWithAnimation {
    [self.layer addSublayer:playButton];
    [playButton addAnimation:playLayerAnimation forKey:@"strokeEnd"];
    [self addSubview:continueButton];
    [self addSubview:skip];
    skip.alpha = 0;
    skip.enabled = NO;
    [UIView animateWithDuration:0.5 delay:3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self->skip.alpha = 1.0;
    } completion:^(BOOL finished) {
        self->skip.enabled = YES;
    }];
}

- (void) presentWithoutAnimation {
    [self resizeAnimation];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"%@", [anim valueForKey:@"id"]);
    if ([[anim valueForKey:@"id"] isEqualToString:@"forwardAnim"]) {
        CABasicAnimation *reverse = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        [reverse setValue:@"backwardAnim" forKey:@"id"];
        reverse.duration = 10.0;
        reverse.fromValue = [NSNumber numberWithDouble:[[playButton presentationLayer] strokeEnd]];
        reverse.toValue = [NSNumber numberWithDouble:0.0];
        reverse.delegate = self;
        [reverse setRemovedOnCompletion:NO];
        [playButton removeAllAnimations];
        [playButton addAnimation:reverse forKey:@"strokeEnd"];
    } else if ([[anim valueForKey:@"id"] isEqualToString:@"backwardAnim"]) {
        [self resizeAnimation];
    } else if ([[anim valueForKey:@"id"] isEqualToString:@"resizeAnim"]) {
        [_delegate presentRestartView];
    }
}

- (void)presentAd {
    [_delegate presentVideoAd];
}

- (void)resizeAnimation {
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self->continueButton.alpha = 0;
        self->continueButton.enabled = NO;
        self->skip.alpha = 0;
        self->skip.enabled = NO;
    } completion:nil];
    [background addAnimation:resizeAnimation forKey:resizeAnimation.keyPath];
    [playButton removeFromSuperlayer];
}

@end


