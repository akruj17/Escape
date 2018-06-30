//
//  BrickManager.h
//  Escape
//
//  Created by Arjun Kunjilwar on 6/30/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SpriteKit;

@interface BrickManager : NSObject
@property (readonly) NSMutableArray *brickPoints;
@property (readonly) NSMutableArray *brickHeights;
@property (readonly) SKAction *shiftBricksInwardAction;
@property (readonly) SKAction *inwardBricksCollideAction;
@property (readonly) NSArray *morphAnimations;
@property (readonly) NSMutableArray *morphBulletShapeLayers;
- (instancetype)initWithScene:(SKScene *)parentScene;


@end
