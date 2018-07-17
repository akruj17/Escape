//
//  Brick.h
//  Escape
//
//  Created by Arjun Kunjilwar on 6/16/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Entity.h"

@interface Brick : Entity
- (instancetype)initWithPosition:(CGPoint)position height:(float)height withColorIndex:(int)index;
- (SKAction *)enlargeAction;
- (SKTexture *)getFragmentTexture;
+ (SKAction *)iterateThroughColors;
@end
