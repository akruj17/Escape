//
//  Shooter.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/15/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "Shooter.h"

@implementation Shooter {
}

- (instancetype) initWithSize:(CGFloat)size {
    if (self = [super init]) {
        //circle portion
        SKShapeNode *circle = [SKShapeNode shapeNodeWithCircleOfRadius:size/2];
        circle.fillColor = [UIColor blueColor];
        circle.strokeColor = [UIColor blueColor];
        circle.name = @"circle";
        [self addChild:circle];
    }
    return self;
}

- (void)changeColorTo:(UIColor *)newColor {
    SKShapeNode *circle = (SKShapeNode *)[self childNodeWithName:@"circle"];
    circle.fillColor = newColor;
    circle.strokeColor = newColor;
}


@end
