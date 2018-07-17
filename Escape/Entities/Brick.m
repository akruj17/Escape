//
//  Brick.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/16/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "Brick.h"
#import "Constants.h"

@implementation Brick

static BOOL generatedTextures;
static NSArray *fragmentTextures;
static NSArray *coloredTextures;
static int animatingIndex;

- (instancetype)initWithPosition:(CGPoint)position height:(float)height withColorIndex:(int)index {
    if (self = [super init]) {
        if (!generatedTextures) {
            coloredTextures = [self generateTextureArrayOfShape:[SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(BRICK_WIDTH, OUTER_LAYER_VERTICAL_BRICK_HEIGHT)]];
            fragmentTextures = [self generateTextureArrayOfShape:[SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(2, 2)]];
            generatedTextures = YES;
        }
        self.colorIndex = index;
        self.size = CGSizeMake(BRICK_WIDTH, height);
        self.texture = [coloredTextures objectAtIndex:index];
        [self runAction:[SKAction resizeToHeight:height duration:0]];
        self.position = position;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(BRICK_WIDTH, height)];
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.linearDamping = 0;
        self.physicsBody.friction = 0;
        self.physicsBody.collisionBitMask = SHOOTER;
        self.physicsBody.categoryBitMask = BRICK;
        self.physicsBody.contactTestBitMask = SHOOTER | BULLET;
    }
    return self;
}

- (SKAction *)enlargeAction{
    static SKAction *enlarge;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        enlarge = [SKAction scaleXBy:pow(2.0, 0.1) y:pow(1.2, 0.1) duration:0.2];
    });
    return enlarge;
}

- (int)getColorIndex {
    return (int)[coloredTextures indexOfObject:self.texture];
}

- (SKTexture *)getFragmentTexture {
    return [fragmentTextures objectAtIndex:self.colorIndex];
}

+ (SKAction *)iterateThroughColors { //total frame time 7.5 seconds
    static NSMutableArray *actions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = [[NSMutableArray alloc] init];
        for (int i = 0; i < 5; i++) {
            NSMutableArray *colorSequence = [[NSMutableArray alloc] init];
            for (int j = 0; j < 5; j++) {
                [colorSequence addObject:[coloredTextures objectAtIndex: (i + j) % 5]];
            }
            [actions addObject:[SKAction repeatActionForever:[SKAction group:@[[SKAction animateWithTextures:colorSequence timePerFrame:1.5], [SKAction repeatAction:[SKAction sequence:@[[SKAction waitForDuration:1.5], [SKAction runBlock:^{
                animatingIndex = (animatingIndex + 1);
            }]]] count:5]]]]];
        }
    });
    return (SKAction *)[actions objectAtIndex:arc4random_uniform(5)];
}



@end
