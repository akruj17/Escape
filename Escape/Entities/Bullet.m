//
//  Bullet.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/16/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "Bullet.h"
#import "Constants.h"

@implementation Bullet

static BOOL generatedTextures;
static NSArray *coloredTextures;
@synthesize velocity = _velocity;

- (instancetype)initRegularBulletWithColorIndex:(int)index {
    if (self = [self initBulletWithColorIndex:index]) {
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:5];
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.linearDamping = 0;
        self.physicsBody.friction = 0;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.categoryBitMask = BULLET;
        self.name = @"bullet";
    }
    return self;
}

- (instancetype) initMorphBulletWithColorIndex:(int)index {
    return [self initBulletWithColorIndex:index];
}

- (instancetype) initBulletWithColorIndex:(int)index {
    if (self = [super init]) {
        if (!generatedTextures) {
            SKShapeNode *circle = [SKShapeNode shapeNodeWithCircleOfRadius:5];
            coloredTextures = [self generateTextureArrayOfShape:circle];
            generatedTextures = YES;
        }
        SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithTexture:[coloredTextures objectAtIndex:index]];
        [self addChild:bullet];
        self.colorIndex = index;
    }
    return self;
}


@end
