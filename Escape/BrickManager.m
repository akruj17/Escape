//
//  BrickManager.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/30/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrickManager.h"
#import "Bullet.h"
#import "Constants.h"

static const float MORPH_BULLET_VELOCITY = 300.0;
static inline float CGPointDistBetweenPoints(const CGPoint a, const CGPoint b) {
    return sqrtf(pow(b.x - a.x, 2) + pow(b.y - a.y, 2));
}

@implementation BrickManager  {
    __weak SKScene *parentScene;
    __weak SKNode *gameLayer;
    CGPoint center;
    __block NSMutableArray *colorsCount; //must change everytime NUM_BRICK_COLORS change
    NSMutableArray *colorBuffer;
    BOOL isFirstGame;
}

@synthesize brickPoints = _brickPoints;
@synthesize brickHeights = _brickHeights;
@synthesize shiftBricksInwardAction = _shiftBricksInwardAction;
@synthesize inwardBricksCollideAction = _inwardBricksCollideAction;
@synthesize morphAnimations = _morphAnimations;
@synthesize morphBulletShapeLayers = _morphBulletShapeLayers;

- (instancetype)initWithGameLayer:(SKNode *)layer andParentScene:(SKScene *)scene {
    if (self = [super init]) {
        parentScene = scene;
        gameLayer = layer;
        colorsCount = [[NSMutableArray alloc] initWithObjects:@0, @0, @0, @0, @0, nil];
        center = CGPointMake(parentScene.size.width/2, parentScene.size.height/2);
        [self generateBrickPoints];
        [self generateShiftBricks];
        [self generateBrickMorphAnimations];
        [self generateMorphBulletLayers];
        [self generateCollisionBricks];
        isFirstGame = YES;
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
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        float brickHeight = ((maxX - minX) - (HORIZONTAL_SPACING * 2) - (BRICK_WIDTH * 3)) / 3.0;
        [_brickHeights addObject:[NSNumber numberWithFloat:brickHeight]];
        float xPos = minX + (1.5 * BRICK_WIDTH) + (brickHeight / 2);
        while (xPos < maxX) {
            NSValue *bottom = [NSValue valueWithCGPoint:CGPointMake(xPos, minY + (BRICK_WIDTH / 2))];
            NSValue *top = [NSValue valueWithCGPoint:CGPointMake(xPos, maxY - (BRICK_WIDTH / 2))];
            [layer addObject:bottom];
            [temp addObject:top];
            xPos += brickHeight + HORIZONTAL_SPACING;
        }
        [layer addObjectsFromArray:temp];
        [temp removeAllObjects];
        brickHeight = ((maxY - minY) - (4 * VERTICAL_SPACING)) / 5.0;
        [_brickHeights addObject:[NSNumber numberWithFloat:brickHeight]];
        float yPos = minY + (brickHeight / 2);
        while (yPos <= maxY) {
            NSValue *left = [NSValue valueWithCGPoint:CGPointMake(minX, yPos)];
            NSValue *right = [NSValue valueWithCGPoint:CGPointMake(maxX, yPos)];
            [layer addObject:left];
            [temp addObject:right];
            yPos += brickHeight + VERTICAL_SPACING;
        }
        [layer addObjectsFromArray:temp];
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
                Brick *brick = (Brick *)[self->gameLayer childNodeWithName:[NSString stringWithFormat:@"brick%d", (16 * i) + j]];
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

// generates the SKAction that shoots the innermost bricks to collide with the shooter, thus ending the game
- (void)generateCollisionBricks {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    SKAction *moveAndRotate = [SKAction group:@[[SKAction moveTo:center duration:0.5], [SKAction rotateByAngle:M_PI * 6 duration:1.0], [SKAction scaleTo:0.5 duration:1.0]]];
    for (int i = 0; i < NUM_BRICKS_PER_LAYER; i++) {
        [result addObject:[SKAction runAction:moveAndRotate onChildWithName:[NSString stringWithFormat:@"brick%d", i + (INNER * NUM_BRICKS_PER_LAYER)]]];
    }
    _inwardBricksCollideAction = [SKAction group:result];
    
}

// add two outer layers of bricks to the scene at the beginning of the game. The innermost layer is empty.
- (void)addBeginningBricksAtPoints {
    for (int i = 0; i < NUM_LAYERS - 1; i++) {
        NSMutableArray *layer = (NSMutableArray *)[_brickPoints objectAtIndex:i];
        NSMutableArray *possibleColors = [[NSMutableArray alloc] initWithArray:@[@0, @0, @0, @1, @1, @1, @2, @2, @2, @3, @3, @3, @4, @4, @4]];
        int extraColor = arc4random_uniform(NUM_BRICK_COLORS);
        if (i == MIDDLE) {
            [colorsCount removeAllObjects];
            int numElementsOfColor = NUM_BRICKS_PER_LAYER / (NUM_BRICK_COLORS);
            for (int i = 0; i < NUM_BRICK_COLORS; i++) {
                [colorsCount addObject:@(numElementsOfColor)];
            }
            [colorsCount setObject:@(numElementsOfColor + 1) atIndexedSubscript:extraColor];
        }
        [possibleColors addObject:[NSNumber numberWithInteger:extraColor]];
        for (int j = 0; j < [layer count]; j++) {
            int possibleColorsIndex = arc4random_uniform((int)[possibleColors count]);
            int color = [[possibleColors objectAtIndex:possibleColorsIndex] intValue];
            [possibleColors removeObjectAtIndex:possibleColorsIndex];
            Brick *brick = [[Brick alloc] initWithPosition:[[layer objectAtIndex:j] CGPointValue] height:[[_brickHeights objectAtIndex:(2 * i) + ((j > 5) ? 1 : 0)] floatValue] withColorIndex:color];
            brick.name = [NSString stringWithFormat:@"brick%i", ((16  * i) + j)];
            if (j <= 5) {
                brick.zRotation = M_PI_2;
            }
            [gameLayer addChild:brick];
        }
    }
    [colorsCount addObject:@(NUM_BRICKS_PER_LAYER * (NUM_LAYERS - 1))];
}

- (void)refreshBricks {
    if (!isFirstGame) {
        for (int i = 0; i < [_brickPoints count]; i++) {
            NSMutableArray *layer = (NSMutableArray *)[_brickPoints objectAtIndex:i];
            for (int j = 0; j < [layer count]; j++) {
                SKNode *brick = [gameLayer childNodeWithName:[NSString stringWithFormat:@"brick%lu", ([layer count] * i) + j]];
                if (brick) {
                    [brick removeFromParent];
                }
            }
        }
    }
    isFirstGame = NO;
    [self addBeginningBricksAtPoints];
}


//send the morphBullets from the shooter to bounce off the walls and then land in the correct location.
- (SKAction *)addMorphBullets {
    float horizontalBrickHeight = [[_brickHeights objectAtIndex:0] floatValue];
    float verticalBrickHeight = [[_brickHeights objectAtIndex:1] floatValue];
    NSArray *outerLayerPoints = [_brickPoints objectAtIndex:0];
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    colorBuffer = [[NSMutableArray alloc] init];
    NSArray *brickColors = [[BrickColors sharedBrickArray] brickColors];
    NSMutableArray *possibleColors = [[NSMutableArray alloc] initWithArray:@[@0, @0, @0, @1, @1, @1, @2, @2, @2, @3, @3, @3, @4, @4, @4]];
    [possibleColors addObject:[NSNumber numberWithInteger:arc4random_uniform(NUM_BRICK_COLORS - 1)]];
    for (int i = 0; i < [outerLayerPoints count]; i++) {
        CGPoint destination = [[outerLayerPoints objectAtIndex:i] CGPointValue];
        int possibleColorsIndex = arc4random_uniform((int)[possibleColors count]);
        int colorIndex = [[possibleColors objectAtIndex:possibleColorsIndex] intValue];
        [possibleColors removeObjectAtIndex:possibleColorsIndex];
        [colorBuffer addObject:@(colorIndex)];
        Bullet *bullet = [[Bullet alloc] initMorphBulletWithColorIndex: colorIndex];
        bullet.name = [NSString stringWithFormat:@"bullet%i", i];
        bullet.position = center;
        CGPoint targetLocation;
        if (i <= 5) { //horizontal brick
            float randomVariation = arc4random_uniform(1.2 * horizontalBrickHeight) - (0.6 * horizontalBrickHeight);
            targetLocation = CGPointMake(destination.x + randomVariation , (i < (NUM_HORIZONTAL_BRICKS_PER_LAYER / 2)) ? 0 : parentScene.size.height);
        } else {      //vertical brick
            float randomVariation = arc4random_uniform(1.2 * verticalBrickHeight) - (0.6 * verticalBrickHeight);
            targetLocation = CGPointMake((i < (NUM_HORIZONTAL_BRICKS_PER_LAYER + (NUM_VERTICAL_BRICKS_PER_LAYER / 2))) ? 0 : parentScene.size.width, destination.y + randomVariation);
        }
        SKAction *morphBrick = nil;
        morphBrick= [SKAction runBlock:^{
            int color = [[self->colorBuffer objectAtIndex:i] intValue];
            CAShapeLayer *layer = [self->_morphBulletShapeLayers objectAtIndex:i];
            layer.fillColor = ((UIColor *)([brickColors objectAtIndex:color])).CGColor;
            [self->parentScene.view.layer addSublayer:layer];
            [CATransaction begin];
            CABasicAnimation *animation = [self->_morphAnimations objectAtIndex:(i > 5) ? 1 : 0];
            [CATransaction setCompletionBlock:^{
            Brick *newBrick = [[Brick alloc] initWithPosition:destination height:((i <= 5) ? horizontalBrickHeight : verticalBrickHeight) withColorIndex:color];
            newBrick.name = [NSString stringWithFormat:@"brick%d", i];
            if (i <= 5) {
                newBrick.zRotation = M_PI_2;
            }
            newBrick.xScale = 0.1;
            newBrick.yScale = 0.1;
            [self->gameLayer addChild:newBrick];
            
            [newBrick runAction:[SKAction sequence:@[[SKAction scaleTo:1.0 duration:0.5], [SKAction waitForDuration:0.6], [SKAction runBlock:^{
                    [layer removeFromSuperlayer];
                    if (!([self->gameLayer childNodeWithName:[NSString stringWithFormat:@"brick%i", i]] || [self->gameLayer childNodeWithName:[NSString stringWithFormat:@"brick%i", i + 16]])) {
                        [self->colorsCount setObject:@([[self->colorsCount objectAtIndex:color] intValue] + 1) atIndexedSubscript:color];
                        [self->colorsCount setObject:@([[self->colorsCount objectAtIndex:NUM_BRICK_COLORS] intValue] + 1) atIndexedSubscript:NUM_BRICK_COLORS];
                    }
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
        bullet.zPosition = 70;
        [parentScene addChild:bullet];
    }
    return [SKAction group:actions];
}

- (void)breakBlock:(Brick *)brick {
    SKEmitterNode *emitter = [SKEmitterNode nodeWithFileNamed:@"brickCollisionEffect"];
    emitter.position = brick.position;
    emitter.particleTexture = [brick getFragmentTexture];
    emitter.zPosition = 3;
    [gameLayer addChild:emitter];
    [emitter runAction:[SKAction sequence:@[[SKAction waitForDuration:1.0], [SKAction removeFromParent]]]];
    [brick removeFromParent];
}

// special round action that randomly changes the colors of the bricks in a particular layer. Not really random tho, just
// iterate over the colors in the specific order and wrap around if necessary. If the player is smart, they will catch this.
- (SKAction *)changeBrickColorsRound:(LayerNames)layer {
    NSArray *bricks = [_brickPoints objectAtIndex:layer];
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    for (int i = 0; i < [bricks count]; i++) {
        [actions addObject:[SKAction runAction:[[Brick class] iterateThroughColors] onChildWithName:[NSString stringWithFormat:@"brick%i", (16 * layer) + i]]];
    }
    return [SKAction runAction:[SKAction group:actions] onChildWithName:gameLayer.name];
}

// special round action that has two opposite sides of a particular layer switch their bricks.
- (SKAction *)bricksSwitchSides:(LayerNames)layer {
    NSArray *bricks = [_brickPoints objectAtIndex:layer];
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    int numSwitches = (SECS_PER_ROUND - 5) / 6;
    int sideToSwitch = arc4random_uniform(2); //0 for horizontal, 1 for vertical
    for (int i = 0; i < numSwitches; i++) {
        int endbound, firstStartIndex, secondStartIndex;
        endbound = ((sideToSwitch == 0) ? NUM_HORIZONTAL_BRICKS_PER_LAYER : NUM_VERTICAL_BRICKS_PER_LAYER) / 2;
        firstStartIndex = (sideToSwitch == 0) ? 0 : NUM_HORIZONTAL_BRICKS_PER_LAYER;
        secondStartIndex = firstStartIndex + (((sideToSwitch == 0) ? NUM_HORIZONTAL_BRICKS_PER_LAYER : NUM_VERTICAL_BRICKS_PER_LAYER) / 2);
        for (int i = 0; i < endbound; i++) {
            CGPoint point1 = [[bricks objectAtIndex:firstStartIndex + i] CGPointValue];
            CGPoint point2 = [[bricks objectAtIndex:secondStartIndex + i] CGPointValue];
            NSString *name1 = [NSString stringWithFormat:@"brick%lu", ((layer * [bricks count]) + firstStartIndex + i)];
            NSString *name2 = [NSString stringWithFormat:@"brick%lu", ((layer * [bricks count]) + secondStartIndex + i)];
            [actions addObject:[SKAction runAction:[SKAction sequence:@[[SKAction scaleTo:0.0 duration:0.3], [SKAction moveTo:point2 duration:0], [SKAction scaleTo:1.0 duration:0.3], [SKAction waitForDuration:4.0], [SKAction scaleTo:0.0 duration:0.3], [SKAction moveTo:point1 duration:0], [SKAction scaleTo:1.0 duration:0.3]]] onChildWithName:name1]];
            [actions addObject:[SKAction runAction:[SKAction sequence:@[[SKAction scaleTo:0.0 duration:0.3], [SKAction moveTo:point1 duration:0], [SKAction scaleTo:1.0 duration:0.3], [SKAction waitForDuration:4.0], [SKAction scaleTo:0.0 duration:0.3], [SKAction moveTo:point2 duration:0], [SKAction scaleTo:1.0 duration:0.3]]] onChildWithName:name2]];
        }
        [actions addObject:[SKAction waitForDuration:6.0]];
        sideToSwitch = sideToSwitch <= 0;
    }
    return [SKAction runAction:[SKAction sequence:actions] onChildWithName:gameLayer.name];
}

// special round action that hides random bricks of a particular layer for 3 seconds at a time.
- (SKAction *)hideBricks:(LayerNames)layer {
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    int timeElapsed = 0;
    int startIndices[5] = {0, (NUM_HORIZONTAL_BRICKS_PER_LAYER / 2), NUM_HORIZONTAL_BRICKS_PER_LAYER, NUM_HORIZONTAL_BRICKS_PER_LAYER + (NUM_VERTICAL_BRICKS_PER_LAYER / 2), NUM_BRICKS_PER_LAYER};
    while (timeElapsed < (SECS_PER_ROUND - 5)) {
        for (int i = 1; i < 5; i++) {
            int randomPosition = (layer * NUM_BRICKS_PER_LAYER) + startIndices[i] + arc4random_uniform(startIndices[i] - startIndices[i - 1]);
            [actions addObject:[SKAction runAction:[SKAction sequence:@[[SKAction scaleTo:0 duration:0.3], [SKAction waitForDuration:1.5], [SKAction scaleTo:1 duration:0.3]]] onChildWithName:[NSString stringWithFormat:@"brick%i", randomPosition]]];
        }
        [actions addObject:[SKAction waitForDuration:2.1]];
        timeElapsed += 2.1;
    }
    return [SKAction runAction:[SKAction sequence:actions] onChildWithName:gameLayer.name];;
}

// special round action that move the bricks of a particular layer around its rectangular layer
- (SKAction *)bricksAlwaysRotating:(LayerNames)layer {
    float velocity = 60;
    NSArray *bricks = [_brickPoints objectAtIndex:layer];
    float horizontalDistance = [[bricks objectAtIndex:(NUM_HORIZONTAL_BRICKS_PER_LAYER / 2) - 1] CGPointValue].x - [[bricks objectAtIndex:0] CGPointValue].x;
    float verticalDistance = [[bricks objectAtIndex:NUM_HORIZONTAL_BRICKS_PER_LAYER + (NUM_VERTICAL_BRICKS_PER_LAYER / 2) - 1] CGPointValue].y - [[bricks objectAtIndex:(NUM_HORIZONTAL_BRICKS_PER_LAYER)] CGPointValue].y;
    float changeTime = (verticalDistance / ((NUM_VERTICAL_BRICKS_PER_LAYER / 2) - 1)) / velocity;
    // start points are [right, top, left, bottom] layers. End points are [bottom, right, top, left].
    NSArray *startPoints = @[[bricks objectAtIndex:(NUM_BRICKS_PER_LAYER - (NUM_VERTICAL_BRICKS_PER_LAYER / 2))], [bricks objectAtIndex:(NUM_HORIZONTAL_BRICKS_PER_LAYER - 1)], [bricks objectAtIndex:(NUM_BRICKS_PER_LAYER - (NUM_VERTICAL_BRICKS_PER_LAYER / 2) - 1)], [bricks objectAtIndex:0]];
    NSArray *endPoints = @[[bricks objectAtIndex:(NUM_HORIZONTAL_BRICKS_PER_LAYER / 2) - 1], [bricks objectAtIndex:(NUM_BRICKS_PER_LAYER - 1)], [bricks objectAtIndex:(NUM_HORIZONTAL_BRICKS_PER_LAYER / 2)], [bricks objectAtIndex:(NUM_HORIZONTAL_BRICKS_PER_LAYER)]];
    NSMutableArray *startToEndActions = [[NSMutableArray alloc] init]; //these are the template actions to move from one end to another
    for (int i = 0; i < [endPoints count]; i++) {
        [startToEndActions addObject:[SKAction moveTo:[[endPoints objectAtIndex:i] CGPointValue] duration:((i % 2 == 0) ? horizontalDistance : verticalDistance) / velocity]];
        //the bricks are transferred from one border to the next
        [startToEndActions addObject:[SKAction sequence:@[[SKAction scaleTo:0.0 duration:0.4], [SKAction group:@[[SKAction moveTo:[[startPoints objectAtIndex:i] CGPointValue] duration:(changeTime - 0.8)], [SKAction rotateToAngle:((i % 2 == 0) ? 0 : M_PI_2) duration:0]]], [SKAction scaleTo:1.0 duration:0.4]]]];
    }
    NSMutableArray *borderActions = [[NSMutableArray alloc] init];
    int orderOfIndices[] = {1, 5, 7, 3};  // this is the order to begin accessing elements from the startToEndActions array
    int endOrderIndices[] = {0, 2, 3, 1}; //this is the ordering of the borders to add actions. Bottom row is first, then top, then right, then left.
    int numBricksPerIndex[] = {(NUM_HORIZONTAL_BRICKS_PER_LAYER / 2), (NUM_HORIZONTAL_BRICKS_PER_LAYER / 2), (NUM_VERTICAL_BRICKS_PER_LAYER / 2), (NUM_VERTICAL_BRICKS_PER_LAYER / 2)};
    NSMutableArray *finalResult = [[NSMutableArray alloc] init];
    int currIndex = -1;
    BOOL changeBorder = YES;
    for (int i = 0; i < [bricks count]; i++) {
        if (changeBorder) {
            currIndex++;
            [borderActions removeAllObjects];
            int j = 0;
            while (j < [startToEndActions count] - 1) {
                [borderActions addObject:[startToEndActions objectAtIndex:(orderOfIndices[currIndex] + j++) % [startToEndActions count]]];
            }
        }
        CGPoint brickStartPos = [[bricks objectAtIndex:i] CGPointValue];
        SKAction *modify = [SKAction moveTo:[[endPoints objectAtIndex:endOrderIndices[currIndex]] CGPointValue] duration:CGPointDistBetweenPoints(brickStartPos, [[endPoints objectAtIndex:endOrderIndices[currIndex]] CGPointValue]) / velocity];
        int startIndex = (endOrderIndices[currIndex] - 1) % 4;
        if (startIndex < 0) { startIndex += 4;}
        SKAction *end = [SKAction moveTo:brickStartPos duration:CGPointDistBetweenPoints([[startPoints objectAtIndex:startIndex] CGPointValue], brickStartPos) / velocity];
        SKAction *result = [SKAction runAction:[SKAction sequence:@[modify, [SKAction sequence:borderActions], end, modify, [SKAction sequence:borderActions], end]] onChildWithName:[NSString stringWithFormat:@"brick%i", (layer * NUM_BRICKS_PER_LAYER) + i]];
        [finalResult addObject:result];
        changeBorder = --numBricksPerIndex[currIndex] == 0;
    }
    return [SKAction runAction:[SKAction sequence:finalResult] onChildWithName:gameLayer.name];
}

- (void)removeBrick:(Brick *)brick {
    int index = [[brick.name substringFromIndex:5] intValue];
    int color = [brick getColorIndex];
    [colorsCount setObject:@([[colorsCount objectAtIndex:color] intValue] - 1) atIndexedSubscript:color];
    [brick removeAllActions];
    [brick removeFromParent];
    if ((index - NUM_BRICKS_PER_LAYER) >= 0) {
        Brick *b = (Brick *)[gameLayer childNodeWithName:[NSString stringWithFormat:@"brick%i", index - NUM_BRICKS_PER_LAYER]];
        if (b) {
            [colorsCount setObject:@([[colorsCount objectAtIndex:[b getColorIndex]] intValue] + 1) atIndexedSubscript:[b getColorIndex]];
        }
    }
    [colorsCount setObject:@([[colorsCount objectAtIndex:NUM_BRICK_COLORS] intValue] - 1) atIndexedSubscript:NUM_BRICK_COLORS];
}

- (int)numBricksWithColorIndex:(int)index {
    if ([[colorsCount objectAtIndex:NUM_BRICK_COLORS] intValue] > 0) {
        return [[colorsCount objectAtIndex:index] intValue];
    }
    return - 1;
}

@end
