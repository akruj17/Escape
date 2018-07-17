//
//  Shooter.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/15/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "Shooter.h"
#import "Constants.h"

@implementation Shooter {
    SKSpriteNode *shooter;
}

static BOOL generatedTextures;
static NSArray *coloredTextures;

- (instancetype) initWithSize:(CGFloat)size {
    if (self = [super init]) {
        if (!generatedTextures) {
            SKShapeNode *circle = [SKShapeNode shapeNodeWithCircleOfRadius:size/2];
            coloredTextures = [self generateTextureArrayOfShape:circle];
            generatedTextures = YES;
        }
        shooter = [SKSpriteNode spriteNodeWithTexture:[coloredTextures objectAtIndex:0]];
        [self addChild:shooter];
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:size/2];
        self.physicsBody.categoryBitMask = SHOOTER;
        self.physicsBody.contactTestBitMask = BRICK;
        self.physicsBody.collisionBitMask = BRICK;
        self.physicsBody.dynamic = NO;
    }
    return self;
}


- (void)changeColorTo:(int)newColorIndex {
    shooter.texture = [coloredTextures objectAtIndex:newColorIndex];
    self.colorIndex = newColorIndex;
}



@end
