//
//  BrickManager.h
//  Escape
//
//  Created by Arjun Kunjilwar on 6/30/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Brick.h"
#import "Constants.h"
@import SpriteKit;

@interface BrickManager : NSObject
@property (readwrite) NSMutableArray *brickPoints;
@property (readwrite) NSMutableArray *brickHeights;
@property (readwrite) SKAction *shiftBricksInwardAction;
@property (readwrite) SKAction *inwardBricksCollideAction;
@property (readwrite) NSArray *morphAnimations;
@property (readwrite) NSMutableArray *morphBulletShapeLayers;
- (instancetype)initWithGameLayer:(SKNode *)layer andParentScene:(SKScene *)scene;
- (void)addBeginningBricksAtPoints;
- (SKAction *)addMorphBullets;
- (void)breakBlock:(Brick *)brick;
- (SKAction *)changeBrickColorsRound:(LayerNames)layer;
- (SKAction *)bricksSwitchSides:(LayerNames)layer;
- (SKAction *)hideBricks:(LayerNames)layer;
- (SKAction *)bricksAlwaysRotating:(LayerNames)layer;
- (void)unhideBricks;
- (void)refreshBricks;
- (void)removeBrick:(Brick *)brick;
- (int)numBricksWithColorIndex:(int)index;
- (void)printNumBricks;
@end
