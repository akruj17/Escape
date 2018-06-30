//
//  GameScene.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/15/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "GameScene.h"
#import "Shooter.h"
#import "Bullet.h"
#import "Brick.h"
#import "Constants.h"
#import "BrickColors.h"
#import "UIColor+ColorExtensions.h"
#import "BrickManager.h"
@import GoogleMobileAds;
@import UIKit;

static const int SECS_PER_ROUND = 10;
static const float MORPH_BULLET_VELOCITY = 300.0;

static inline float CGPointDistBetweenPoints(const CGPoint a, const CGPoint b) {
    return sqrtf(pow(b.x - a.x, 2) + pow(b.y - a.y, 2));
}

@interface GameScene()<SKPhysicsContactDelegate>@end

@implementation GameScene {
    Shooter *shooter;
    CGPoint center;
    float _bulletInterval;
    CFTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    NSTimeInterval _colorInterval;
    NSTimeInterval _timeSinceRoundStart;
    NSMutableArray *brickPoints;
    NSMutableArray *brickHeights;
    NSArray *colors;
    SKLabelNode *scoreLbl;
    SKLabelNode *timeLbl;
    SKAction *shiftBricksInward;
    NSArray *morphAnimations;
    NSMutableArray *morphBulletLayers;
    int score;
    int currentColorIndex;
    NSInteger numBricksPerLayer[NUM_LAYERS];
    BrickManager *manager;
}

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
      //  self.backgroundColor = [UIColor grayBackgroundColor];
        self.physicsWorld.contactDelegate = self;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = EDGE_CATEGORY_BITMASK;
        self.physicsBody.contactTestBitMask = BULLET_CATEGORY_BITMASK;
        center = CGPointMake(self.size.width / 2, self.size.height / 2);
        colors = [[BrickColors sharedBrickArray] brickColors];
        
        shooter = [[Shooter alloc] initWithSize:40];
        shooter.position = center;
        shooter.zPosition = 100;
        shooter.name = @"shooter";
        [self addChild:shooter];
        manager = [[BrickManager alloc] initWithScene:self];
        [self setUpGameStructure];
        [self setUpCurrentGame];

        _colorInterval = 4.01;

    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint curr = [[touches anyObject] locationInNode:self];
    CGFloat angle = atan2(curr.y - center.y, curr.x - center.x);
    shooter.zRotation = angle - M_PI_2;
    //[self generateCollisionBricks];
    SKNode *node = [self nodeAtPoint:curr];
    NSLog(@"%@", node.name);
}

-(void)update:(CFTimeInterval)currentTime {
    _dt = (_lastUpdateTime) ? currentTime - _lastUpdateTime : 0;
    _lastUpdateTime = currentTime;
    _timeSinceRoundStart += _dt;
    _bulletInterval += _dt;
    _colorInterval += _dt;
    int timePassed = (int)(_timeSinceRoundStart / 1);
    timeLbl.text = [NSString stringWithFormat:@"%i", SECS_PER_ROUND - timePassed];
    if (timePassed == SECS_PER_ROUND) {
            [self transitionToNextRound];
    }
    if (_colorInterval > 4.0) {
        currentColorIndex = arc4random_uniform([colors count]);
        [shooter changeColorTo:[colors objectAtIndex:currentColorIndex]];
        _colorInterval = 0;
    }
    if (_bulletInterval > 0.15) { //add new regular bullet
        _bulletInterval = 0;
        Bullet *bullet = [[Bullet alloc] initRegularBulletWithPosition:center withColorIndex:currentColorIndex];
        bullet.physicsBody.velocity = CGVectorMake(120 * cos(shooter.zRotation + M_PI_2), 120 * sin(shooter.zRotation + M_PI_2));
        [self addChild:bullet];
    }

}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    Bullet *bulletToRemove = (contact.bodyA.categoryBitMask == BULLET_CATEGORY_BITMASK) ? (Bullet *)contact.bodyA.node : (Bullet *)contact.bodyB.node;
    if (collision == (BRICK_CATEGORY_BITMASK | BULLET_CATEGORY_BITMASK)) {
        Brick *brick = (contact.bodyA.categoryBitMask == BRICK_CATEGORY_BITMASK) ? (Brick *)contact.bodyA.node : (Brick *)contact.bodyB.node;
        if ([bulletToRemove getColorIndex] == [brick getColorIndex]) {
            [brick runAction:[brick enlargeAction]];
        }
        if (brick.xScale > 1.9) {
            [brick removeAllActions];
            [brick removeFromParent];
            scoreLbl.text = [NSString stringWithFormat:@"score %i", ++score];
        }
    }
    [bulletToRemove runAction:[SKAction sequence:@[ [SKAction removeFromParent]]]];
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    if ((collision == (EDGE_CATEGORY_BITMASK | BULLET_CATEGORY_BITMASK)) || (collision == (BRICK_CATEGORY_BITMASK | BULLET_CATEGORY_BITMASK))) {
        
    }
}

// this method is only called once when the game first plays. Subsequent plays will already have the structure saved.
- (void)setUpGameStructure {
    brickPoints = manager.brickPoints;
    brickHeights = manager.brickHeights;
    shiftBricksInward = manager.shiftBricksInwardAction;
    morphAnimations = manager.morphAnimations;
    morphBulletLayers = manager.morphBulletShapeLayers;
    [self addScoreLabel];
}

- (void)setUpCurrentGame {
    [self addBeginningBricksAtPoints];
    [self resetProperties];
    numBricksPerLayer[0] = numBricksPerLayer[1] = 16;
}

- (void)transitionToNextRound {
    timeLbl.text = [NSString stringWithFormat:@"30"];
    _timeSinceRoundStart = 0;
    [self runAction:[SKAction group:@[shiftBricksInward, [SKAction sequence:@[[SKAction runAction:[SKAction scaleTo:0.7 duration:0.3] onChildWithName:@"shooter"], [SKAction group:@[[SKAction runAction:[SKAction sequence:@[[SKAction scaleTo:2.0 duration:0.3], [SKAction scaleTo:1.0 duration:0.5]]] onChildWithName:@"shooter"], [self addMorphBullets]]]]]]]];
    numBricksPerLayer[INNER] = numBricksPerLayer[MIDDLE];
    numBricksPerLayer[MIDDLE] = numBricksPerLayer[OUTER];
    numBricksPerLayer[OUTER] = 16;
}



// add two outer layers of bricks to the scene at the beginning of the game. The innermost layer is empty.
- (void)addBeginningBricksAtPoints {
    for (int i = 0; i < [brickPoints count] - 1; i++) {
        NSMutableArray *layer = (NSMutableArray *)[brickPoints objectAtIndex:i];
        for (int j = 0; j < [layer count]; j++) {
            int colorIndex = arc4random_uniform([colors count]);
            Brick *brick = [[Brick alloc] initWithPosition:[[layer objectAtIndex:j] CGPointValue] height:[[brickHeights objectAtIndex:(2 * i) + ((j > 5) ? 1 : 0)] floatValue] withColorIndex:colorIndex];
            brick.name = [NSString stringWithFormat:@"brick%i", ((16  * i) + j)];
            if (j <= 5) {
                brick.zRotation = M_PI_2;
            }
            brick.zPosition = 100;
            [self addChild:brick];
        }
    }
}

// add the time and score label
- (void)addScoreLabel {
    scoreLbl = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-UltraLight"];
    scoreLbl.fontSize = 40.0;
    scoreLbl.text = [NSString stringWithFormat:@"score        "];
    scoreLbl.position = CGPointMake((0.1 * self.size.width) + (scoreLbl.frame.size.width / 2), (0.875 * self.size.height) + (scoreLbl.frame.size.height / 2));
    [self addChild:scoreLbl];
    
    timeLbl = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-UltraLight"];
    timeLbl.fontSize = 60.0;
    timeLbl.position = CGPointMake((0.9 * self.size.width) - (timeLbl.frame.size.width / 2), (0.875 * self.size.height) + (scoreLbl.frame.size.height / 2));
    [self addChild:timeLbl];
}

- (void)resetProperties {
    _timeSinceRoundStart = 0;
    timeLbl.text = [NSString stringWithFormat:@"%i", SECS_PER_ROUND];
    scoreLbl.text = [NSString stringWithFormat:@"score %i", 0];
}


        




@end
