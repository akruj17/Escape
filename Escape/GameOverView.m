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
    CAShapeLayer *background, *playButton;
    CABasicAnimation *resizeBackgroundAnimation, *playButtonAnimation, *replacement;
    UIButton *continueButton, *skip;
}

- (instancetype)initWithFrame:(CGRect)frame belowLayer:(CALayer *)layer {
    if (self = [super initWithFrame:frame]) {
        [self createBackgroundLayer];
        [self createContinuePlayLayer];
        [self createButtons];
    }
    return self;
}

- (void)createBackgroundLayer {
    backgroundFullSize = CGSizeMake(0.85 * self.bounds.size.width, 0.8 * self.bounds.size.height);
    CGRect bounds = CGRectMake(0, 0, backgroundFullSize.width, backgroundFullSize.height);
    background = [CAShapeLayer layer];
    background.bounds = bounds;
    background.position = self.center;
    background.fillColor = [UIColor redBackgroundColor].CGColor;
    float startRadius = 0.4 * self.bounds.size.width;
    background.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((bounds.size.width / 2) - startRadius, (bounds.size.height / 2) - startRadius, 2 * startRadius, 2 * startRadius) cornerRadius:startRadius].CGPath;
    UIBezierPath *end = [UIBezierPath bezierPathWithRoundedRect:background.bounds cornerRadius:10];
    resizeBackgroundAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    [resizeBackgroundAnimation setValue:@"resizeAnim" forKey:@"id"];
    resizeBackgroundAnimation.delegate = self;
    resizeBackgroundAnimation.toValue = (__bridge id _Nullable)(end.CGPath);
    resizeBackgroundAnimation.duration = 1.5;
    resizeBackgroundAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    resizeBackgroundAnimation.fillMode = kCAFillModeBoth;
    resizeBackgroundAnimation.removedOnCompletion = NO;
    [self.layer addSublayer:background];
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
    playButtonAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    playButtonAnimation.delegate = self;
    [playButtonAnimation setValue:@"forwardAnim" forKey:@"id"];
    playButtonAnimation.fromValue = [NSNumber numberWithDouble:0.0];
    playButtonAnimation.duration = 1;
    playButtonAnimation.removedOnCompletion = NO;
}

- (void)createButtons {
    continueButton = [[UIButton alloc] initWithFrame:CGRectMake(self.center.x - 150, self.center.y + (self.bounds.size.height * 0.05), 300, 40)];
    continueButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50];
    continueButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [continueButton setTitleColor:[UIColor blackColor] forState:normal];
    [continueButton setTitle:@"continue?" forState:normal];
    [continueButton addTarget:self action:@selector(continuePressed) forControlEvents:UIControlEventTouchUpInside];
    skip = [[UIButton alloc] initWithFrame:CGRectMake(self.center.x - 100, self.center.y + (self.bounds.size.height * 0.12), 200, 40)];
    skip.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
    skip.titleLabel.textAlignment = NSTextAlignmentCenter;
    [skip setTitle:@"skip" forState:normal];
    [skip setTitleColor:[UIColor blackColor] forState:normal];
    [skip addTarget:self action:@selector(executeResizeAnimation) forControlEvents:UIControlEventTouchUpInside];
}

//present the gameoverview with the continue option present
- (void) presentWithAnimation {
    [self.layer addSublayer:playButton];
    playButtonAnimation.beginTime = CACurrentMediaTime();
    [playButton addAnimation:playButtonAnimation forKey:@"currentAnim"];
    [self addSubview:continueButton];
    [self addSubview:skip];
    skip.alpha = 0;
    skip.enabled = NO;
    continueButton.alpha = 1;
    continueButton.enabled = YES;
    [UIView animateWithDuration:0.5 delay:3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self->skip.alpha = 1.0;
    } completion:^(BOOL finished) {
        self->skip.enabled = YES;
    }];
}

// the play button is not added, and the resizing immediately takes place
- (void) presentWithoutAnimation {
    [background addAnimation:resizeBackgroundAnimation forKey:resizeBackgroundAnimation.keyPath];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:@"id"] isEqualToString:@"forwardAnim"] && flag) { //drawing the play button is complete
        CABasicAnimation *reverse = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        [reverse setValue:@"backwardAnim" forKey:@"id"];
        reverse.duration = 10.0;
        reverse.beginTime = CACurrentMediaTime();
        reverse.fromValue = [NSNumber numberWithDouble:[[playButton presentationLayer] strokeEnd]];
        reverse.toValue = [NSNumber numberWithDouble:0.0];
        reverse.delegate = self;
        reverse.removedOnCompletion = NO;
        [playButton addAnimation:reverse forKey:@"currentAnim"];
    } else if ([[anim valueForKey:@"id"] isEqualToString:@"backwardAnim"] && flag) { //erasing the play button is complete
        [self executeResizeAnimation];
    } else if ([[anim valueForKey:@"id"] isEqualToString:@"resizeAnim"] && flag) {
        [_delegate moveToRestartView];
    }
}


- (void)continuePressed {
    [_delegate continueButtonPressed];
}

- (void)executeResizeAnimation {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self->continueButton.alpha = 0;
        self->continueButton.enabled = NO;
        self->skip.alpha = 0;
        self->skip.enabled = NO;
    } completion:^(BOOL finished) {
        if (finished) {
            [self->background addAnimation:self->resizeBackgroundAnimation forKey:self->resizeBackgroundAnimation.keyPath];
            [self->playButton removeFromSuperlayer];
        }
    }];
}

- (void)resetProperties {
    [background removeAllAnimations];
    [playButton removeAllAnimations];
    if ([playButton superlayer]) {
        [self->playButton removeFromSuperlayer];
    }
    [continueButton removeFromSuperview];
    [skip removeFromSuperview];
}

- (void)pauseAnimation {
    CABasicAnimation *currentAnim = (CABasicAnimation *)[playButton animationForKey:@"currentAnim"];
    CFTimeInterval elapsedTime = CACurrentMediaTime() - currentAnim.beginTime;
    if (currentAnim) {
        replacement = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        [replacement setValue:[currentAnim valueForKey:@"id"] forKey:@"id"];
        replacement.fromValue = [NSNumber numberWithDouble:[[playButton presentationLayer] strokeEnd]];
        replacement.toValue = currentAnim.toValue;
        replacement.delegate = self;
        replacement.removedOnCompletion = NO;
        replacement.duration = currentAnim.duration - elapsedTime;
        [self pauseLayer:playButton];
    }
}

- (void)resumeAnimation {
    [playButton removeAllAnimations];
    [self resumeLayer:playButton];
    [playButton addAnimation:replacement forKey:@"currentAnim"];
}

- (void)pauseLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

@end


