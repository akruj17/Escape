//
//  Brick.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/16/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "Brick.h"

@implementation Brick

- (instancetype)initWithPosition:(CGPoint)position {
    if (self = [super init]) {
        self.texture = [[self class] generateTexture];
        self.size = self.texture.size;
        self.position = position;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:5];
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.linearDamping = 0;
        self.physicsBody.friction = 0;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.categoryBitMask = 1 << 1;
        self.physicsBody.contactTestBitMask = 1 << 0;
    }
    return self;
}

+ (SKTexture *)generateTexture {
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKShapeNode *brick = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(20, 60)];
        brick.strokeColor = [UIColor whiteColor];
        brick.fillColor = [UIColor whiteColor];
        
        SKView *textureView = [SKView new];
        texture = [textureView textureFromNode:brick];
        texture.filteringMode = SKTextureFilteringNearest;
    });
    return texture;
}
@end
