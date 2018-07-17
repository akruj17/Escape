//
//  Bullet.h
//  Escape
//
//  Created by Arjun Kunjilwar on 6/16/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Entity.h"

@interface Bullet : Entity
@property (nonatomic, assign) CGVector velocity;
- (instancetype) initRegularBulletWithColorIndex:(int)index;
- (instancetype) initMorphBulletWithColorIndex:(int)index;
@end
