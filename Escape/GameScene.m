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

@interface GameScene()<SKPhysicsContactDelegate>@end

@implementation GameScene {
    Shooter *shooter;
    CGPoint center;
    float _bulletInterval;
    CFTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
}

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.physicsWorld.contactDelegate = self;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = 1 << 0;
        self.physicsBody.contactTestBitMask = 1 << 1;
        center = CGPointMake(self.size.width/2, self.size.height/2);
        
        shooter = [[Shooter alloc] initWithSize:60];
        shooter.position = center;
        shooter.zPosition = 100;
        [self addChild:shooter];
        
        Brick *brick = [[Brick alloc] initWithPosition:CGPointMake(100, 100)];
        [self addChild:brick];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint curr = [[touches anyObject] locationInNode:self];
    CGFloat angle = atan2(curr.y - center.y, curr.x - center.x);
    shooter.zRotation = angle - M_PI_2;
}

-(void)update:(CFTimeInterval)currentTime {
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    _bulletInterval += _dt;
    if (_bulletInterval > 0.15) {
        _bulletInterval = 0;
        Bullet *bullet = [[Bullet alloc] initWithPosition:center];
        bullet.physicsBody.velocity = CGVectorMake(120 * cos(shooter.zRotation + M_PI_2), 120 * sin(shooter.zRotation + M_PI_2));
        [self addChild:bullet];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    if (collision == (1 | 2)) {
        Bullet *bulletToRemove = (contact.bodyA.categoryBitMask == 2) ? (Bullet *)contact.bodyA.node : (Bullet *)contact.bodyB.node;
        [bulletToRemove runAction:[SKAction sequence:@[[SKAction waitForDuration:0.3], [SKAction
                                                                                        removeFromParent]]]];
    }
}

@end
