//
//  BrickManager.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/30/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrickManager.h"
#import "Brick.h"
#import "Bullet.h"
#import "Constants.h"

@implementation BrickManager  {
    SKScene *parentScene;
    CGPoint center;
}

@synthesize brickPoints = _brickPoints;
@synthesize brickHeights = _brickHeights;
@synthesize shiftBricksInwardAction = _shiftBricksInwardAction;
@synthesize inwardBricksCollideAction = _inwardBricksCollideAction;
@synthesize morphAnimations = _morphAnimations;
@synthesize morphBulletShapeLayers = _morphBulletShapeLayers;

- (instancetype)initWithScene:(SKScene *)parentScene {
    if (self = [super init]) {
        self->parentScene = parentScene;
        center = CGPointMake(parentScene.size.width/2, parentScene.size.height/2);
        [self generateBrickPoints];
        [self generateShiftBricks];
        [self generateBrickMorphAnimations];
        [self generateMorphBulletLayers];
        [self generateCollisionBricks];

    }
    return self;
}

- (void)generateBrickPoints {
    NSArray *splitString = [LAYERING_POS_VALUES componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@" "]];
    NSMutableArray *layerPositionValues = [[NSMutableArray alloc] init];
    for (int i = 0; i < [splitString count]; i++) {
        float dimension = [[splitString objectAtIndex:i] floatValue];
        dimension *= ((i % 4) < 2) ? parentScene.size.width : parentScene.size.height;
        [layerPositionValues addObject:[NSNumber numberWithFloat:dimension]];
    }
    _brickPoints = [[NSMutableArray alloc] init];
    _brickHeights = [[NSMutableArray alloc] init];
    for (int i = 0; i < 3; i++) {
        float maxX = [[layerPositionValues objectAtIndex:(4 * i + 1)] floatValue];
        float minX = [[layerPositionValues objectAtIndex:(4 * i)] floatValue];
        float maxY = [[layerPositionValues objectAtIndex:(4 * i + 3)] floatValue];
        float minY = [[layerPositionValues objectAtIndex:(4 * i + 2)] floatValue];
        
        NSMutableArray *layer = [[NSMutableArray alloc] init];
        float brickHeight = ((maxX - minX) - (HORIZONTAL_SPACING * 2) - (BRICK_WIDTH * 3)) / 3.0;
        [_brickHeights addObject:[NSNumber numberWithFloat:brickHeight]];
        float xPos = minX + (1.5 * BRICK_WIDTH) + (brickHeight / 2);
        while (xPos < maxX) {
            NSValue *left = [NSValue valueWithCGPoint:CGPointMake(xPos, minY + (BRICK_WIDTH / 2))];
            NSValue *right = [NSValue valueWithCGPoint:CGPointMake(xPos, maxY - (BRICK_WIDTH / 2))];
            [layer addObjectsFromArray:@[left, right]];
            xPos += brickHeight + HORIZONTAL_SPACING;
        }
        brickHeight = ((maxY - minY) - (4 * VERTICAL_SPACING)) / 5.0;
        [_brickHeights addObject:[NSNumber numberWithFloat:brickHeight]];
        float yPos = minY + (brickHeight / 2);
        while (yPos <= maxY) {
            NSValue *left = [NSValue valueWithCGPoint:CGPointMake(minX, yPos)];
            NSValue *right = [NSValue valueWithCGPoint:CGPointMake(maxX, yPos)];
            [layer addObjectsFromArray:@[left, right]];
            yPos += brickHeight + VERTICAL_SPACING;
        }
        [_brickPoints addObject:layer];
    }
}

// generates the SKAction that shifts the outer two layers of bricks inwards when a round ends
- (void)generateShiftBricks {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for (int i = 0; i < [_brickPoints count] - 1; i++) {
            NSArray *outerLayer = [_brickPoints objectAtIndex:i];
            NSArray *innerLayer = [_brickPoints objectAtIndex:(i + 1)];
            for (int j = 0; j < [outerLayer count]; j++) {
                SKAction *moveAndShrink = [SKAction group:@[[SKAction moveTo:[[innerLayer objectAtIndex:j] CGPointValue] duration:1.0], [SKAction resizeToHeight:[[_brickHeights objectAtIndex:((2 * (i + 1)) + ((j > 5) ? 1 : 0))] floatValue] duration:1.0]]];
                [result addObject:[SKAction runAction:moveAndShrink onChildWithName:[NSString stringWithFormat:@"brick%lu", (i * [outerLayer count] + j)]]];
            }
        }
    _shiftBricksInwardAction = [SKAction sequence:@[[SKAction group:result], [SKAction runBlock:^{
                for (int i = 1; i >= 0; i--) {
                    for (int j = 0; j < 16; j++) {
                        Brick *brick = (Brick *)[parentScene childNodeWithName:[NSString stringWithFormat:@"brick%d", (16 * i) + j]];
                        brick.name = [NSString stringWithFormat:@"brick%d", (16 * (i + 1) + j)];
                    }
                }
            }]]];
}

// generates the resize animation that turns the circular bullets into the rectangular bricks on outer layer
- (void)generateBrickMorphAnimations {
    _morphAnimations = @[[CABasicAnimation animationWithKeyPath:@"path"], [CABasicAnimation animationWithKeyPath:@"path"]];
    for (int i = 0; i < 2; i++) {
        CABasicAnimation *animation = (CABasicAnimation *)[_morphAnimations objectAtIndex:i];
        float width = (i == 0) ? [[_brickHeights objectAtIndex:0] floatValue] : BRICK_WIDTH;
        float height = (i == 0) ? BRICK_WIDTH : [[_brickHeights objectAtIndex:1] floatValue];
        UIBezierPath *end = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, width, height) cornerRadius:0.001];
        animation.toValue = (__bridge id _Nullable)(end.CGPath);
        animation.duration = 1.0;
        animation.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.fillMode = kCAFillModeBoth;
        animation.removedOnCompletion = false;
    }
}

//// generates the CALayer objects that represent the bullets that morph into bricks
- (void)generateMorphBulletLayers {
    _morphBulletShapeLayers = [[NSMutableArray alloc] init];
    NSMutableArray *outerLayer = (NSMutableArray *)[_brickPoints objectAtIndex:0];
    CGRect horizontalBrickBounds = CGRectMake(0, 0, [[_brickHeights objectAtIndex:0] floatValue], BRICK_WIDTH);
    CGRect verticalBrickBounds = CGRectMake(0, 0, BRICK_WIDTH, [[_brickHeights objectAtIndex:1] floatValue]);
    UIBezierPath *horizontalBrickStart = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((horizontalBrickBounds.size.width / 2) - BULLET_RADIUS, 0, 2 * BULLET_RADIUS, 2 * BULLET_RADIUS) cornerRadius:BULLET_RADIUS];
    UIBezierPath *verticalBrickStart = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, (verticalBrickBounds.size.height / 2) - BULLET_RADIUS, 2 * BULLET_RADIUS, 2 * BULLET_RADIUS) cornerRadius:BULLET_RADIUS];
    for (int i = 0; i < [outerLayer count]; i++) {
        CGPoint location = [[outerLayer objectAtIndex:i] CGPointValue];
        CAShapeLayer *bullet = [CAShapeLayer layer];
        bullet.bounds = (i > 5) ? verticalBrickBounds : horizontalBrickBounds;
        bullet.position = CGPointMake(location.x, parentScene.size.height - location.y);
        bullet.path = ((i > 5) ? verticalBrickStart : horizontalBrickStart).CGPath;
        [_morphBulletShapeLayers addObject:bullet];
    }
}

//send the morphBullets from the shooter to bounce off the walls and then land in the correct location.
- (SKAction *)addMorphBullets {
    float horizontalBrickHeight = [[_brickHeights objectAtIndex:0] floatValue];
    float verticalBrickHeight = [[_brickHeights objectAtIndex:1] floatValue];
    NSArray *outerLayerPoints = [_brickPoints objectAtIndex:0];
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    for (int i = 0; i < [outerLayerPoints count]; i++) {
        CGPoint destination = [[outerLayerPoints objectAtIndex:i] CGPointValue];
        int colorIndex = arc4random_uniform([colors count]);
        Bullet *bullet = [[Bullet alloc] initMorphBulletWithPosition: center withColorIndex: colorIndex];
        bullet.name = [NSString stringWithFormat:@"bullet%i", i];
        CGPoint targetLocation;
        if (i <= 5) { //horizontal brick
            float randomVariation = arc4random_uniform(1.2 * horizontalBrickHeight) - (0.6 * horizontalBrickHeight);
            targetLocation = CGPointMake(destination.x + randomVariation , (i % 2 == 0) ? 0 : parentScene.size.height);
        } else {      //vertical brick
            float randomVariation = arc4random_uniform(1.2 * verticalBrickHeight) - (0.6 * verticalBrickHeight);
            targetLocation = CGPointMake((i % 2 == 0) ? 0 : parentScene.size.width, destination.y + randomVariation);
        }
        SKAction *morphBrick = [SKAction runBlock:^{
            CAShapeLayer *layer = [self->_morphBulletShapeLayers objectAtIndex:i];
            layer.fillColor = ((UIColor *)([colors objectAtIndex:colorIndex])).CGColor;
            [self->parentScene.view.layer addSublayer:layer];
            layer.zPosition = 100;
            [CATransaction begin];
            CABasicAnimation *animation = [self->_morphAnimations objectAtIndex:(i > 5) ? 1 : 0];
            [CATransaction setCompletionBlock:^{
                Brick *newBrick = [[Brick alloc] initWithPosition:destination height:((i <= 5) ? horizontalBrickHeight : verticalBrickHeight) withColorIndex:colorIndex];
                newBrick.name = [NSString stringWithFormat:@"brick%d", i];
                if (i <= 5) {
                    newBrick.zRotation = M_PI_2;
                }
                newBrick.xScale = 0.1;
                newBrick.yScale = 0.1;
                [self->parentScene addChild:newBrick];
                
                [newBrick runAction:[SKAction sequence:@[[SKAction scaleTo:1.0 duration:0.5], [SKAction waitForDuration:0.6], [SKAction runBlock:^{
                    [layer removeFromSuperlayer];
                }]]]];
                newBrick.zPosition = 30;
            }];
            [layer addAnimation:animation forKey:animation.keyPath];
            [CATransaction commit];
        }];
        
        float timeA = CGPointDistBetweenPoints(center, targetLocation) / MORPH_BULLET_VELOCITY;
        float timeB = CGPointDistBetweenPoints(targetLocation, destination) / MORPH_BULLET_VELOCITY;
        [actions addObject:
         [SKAction runAction:[SKAction sequence: @[[SKAction moveTo: targetLocation duration:timeA], [SKAction moveTo:destination duration:timeB], morphBrick, [SKAction waitForDuration:0.5], [SKAction removeFromParent]]] onChildWithName:bullet.name]];
        [self addChild:bullet];
    }
    return [SKAction group:actions];
}

// generates the SKAction that shoots the innermost bricks to collide with the shooter, thus ending the game
- (void)generateCollisionBricks {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    SKAction *moveAndRotate = [SKAction group:@[[SKAction moveTo:CGPointMake(parentScene.size.width/2, parentScene.size.height/2) duration:0.5], [SKAction rotateByAngle:M_PI * 6 duration:1.0]]];
    for (int i = 0; i < NUM_BRICKS_PER_LAYER; i++) {
        [result addObject:[SKAction runAction:moveAndRotate onChildWithName:[NSString stringWithFormat:@"brick%d", i + (INNER * NUM_BRICKS_PER_LAYER)]]];
    }
    _inwardBricksCollideAction = [SKAction group:result];
    
}



@end
