//
//  Bullet.h
//  Escape
//
//  Created by Arjun Kunjilwar on 6/16/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BrickColors.h"

@interface Bullet : SKSpriteNode
- (instancetype) initRegularBulletWithPosition:(CGPoint)position withColorIndex:(int)index;
- (instancetype) initMorphBulletWithPosition:(CGPoint)position withColorIndex:(int)index;
- (int)getColorIndex;
@end
