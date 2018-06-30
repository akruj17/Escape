//
//  Brick.h
//  Escape
//
//  Created by Arjun Kunjilwar on 6/16/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BrickColors.h"

@interface Brick : SKSpriteNode
- (instancetype)initWithPosition:(CGPoint)position height:(float)height withColorIndex:(int)colorIndex;
- (SKAction *)enlargeAction;
- (int)getColorIndex;
@end
