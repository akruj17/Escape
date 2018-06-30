//
//  Brick.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/16/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "Brick.h"
#import "Constants.h"

@implementation Brick {
    int colorIndex;
}

- (instancetype)initWithPosition:(CGPoint)position height:(float)height withColorIndex:(int)colorIndex {
    if (self = [super init]) {
        self.texture = [[self class] generateTextures:colorIndex];
        self->colorIndex = colorIndex;
        self.size = self.texture.size;
        [self runAction:[SKAction resizeToHeight:height duration:0.1]];
        self.position = position;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(BRICK_WIDTH, height)];
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.linearDamping = 0;
        self.physicsBody.friction = 0;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.categoryBitMask = BRICK_CATEGORY_BITMASK;
        self.physicsBody.contactTestBitMask = BULLET_CATEGORY_BITMASK;
    }
    return self;
}

+ (SKTexture *)generateTextures:(int)index {
    static NSMutableArray *textures;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKShapeNode *brick = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(BRICK_WIDTH, OUTER_LAYER_VERTICAL_BRICK_HEIGHT)];
        NSArray *colors = [[BrickColors sharedBrickArray] brickColors];
        textures = [[NSMutableArray alloc] init];
        for (int i = 0; i < [colors count]; i++) {
            brick.strokeColor = [colors objectAtIndex:i];
            brick.fillColor = [colors objectAtIndex:i];
            SKView *textureView = [SKView new];
            SKTexture *texture = nil;
            texture = [textureView textureFromNode:brick];
            texture.filteringMode = SKTextureFilteringNearest;
            [textures addObject:texture];
        }
    });
    return (SKTexture *)[textures objectAtIndex: index];
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
    return colorIndex;
}



@end
