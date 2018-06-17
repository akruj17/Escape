//
//  Shooter.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/15/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "Shooter.h"

@implementation Shooter

- (instancetype) initWithSize:(CGFloat)size {
    if (self = [super init]) {
        //circle portion
        SKShapeNode *circle = [SKShapeNode shapeNodeWithCircleOfRadius:size/2];
        circle.fillColor = [UIColor blueColor];
        circle.strokeColor = [UIColor blueColor];
        [self addChild:circle];
        //triangle portion
        float xCoord = (size/3) / sqrt(3);
        CGPoint trianglePoints[] = {CGPointMake(0, size/2), CGPointMake( -xCoord, (size/6)), CGPointMake(xCoord, (size/6)), CGPointMake(0, size/2)};
        SKShapeNode *triangle = [SKShapeNode shapeNodeWithPoints: trianglePoints count:4];
        triangle.strokeColor = [UIColor blackColor];
        triangle.fillColor = [UIColor blackColor];
        [self addChild:triangle];
    }
    return self;
}


@end
