//
//  Bullet.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/16/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "Bullet.h"
#import "Constants.h"

@implementation Bullet {
    int colorIndex;
}

static SKTexture *currTexture;
static int currColorIndex;

- (instancetype)initRegularBulletWithPosition:(CGPoint)position withColorIndex:(int)index {
    if (self = [super init]) {
        self.texture = (currTexture == nil || (currColorIndex != index)) ? [[self class] generateTextureWithIndex:(index)] : currTexture;
        colorIndex = index;
        self.size = self.texture.size;
        self.position = position;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:5];
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.linearDamping = 0;
        self.physicsBody.friction = 0;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.categoryBitMask = BULLET_CATEGORY_BITMASK;
        self.physicsBody.contactTestBitMask = EDGE_CATEGORY_BITMASK | BRICK_CATEGORY_BITMASK;
    }
    return self;
}

- (instancetype) initMorphBulletWithPosition:(CGPoint)position withColorIndex:(int)index {
    if (self = [super init]) {
        self.texture = [[self class] generateTextureWithIndex:index];
        self.size = self.texture.size;
        self.position = position;
    }
    return self;
}

+ (SKTexture *)generateTextureWithIndex:(int)index {
    static NSMutableArray *textures;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKShapeNode *bullet = [SKShapeNode shapeNodeWithCircleOfRadius:5];
        NSArray *colors = [[BrickColors sharedBrickArray] brickColors];
        textures = [[NSMutableArray alloc] init];
        SKView *textureView = [SKView new];
        SKTexture *texture = nil;
        for (int i = 0; i < [colors count]; i++) {
            bullet.strokeColor = [colors objectAtIndex:i];
            bullet.fillColor = [colors objectAtIndex:i];
            texture = [textureView textureFromNode:bullet];
            texture.filteringMode = SKTextureFilteringNearest;
            [textures addObject:texture];
        }
    });
    currColorIndex = index;
    return currTexture = [textures objectAtIndex:index];
}

- (int)getColorIndex {
    return colorIndex;
}


@end
