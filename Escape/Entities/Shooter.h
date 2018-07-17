//
//  Shooter.h
//  Escape
//
//  Created by Arjun Kunjilwar on 6/15/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Entity.h"

@interface Shooter : Entity
- (instancetype) initWithSize:(CGFloat)size;
- (void)changeColorTo:(int)newColorIndex;
@end
