//
//  Entity.h
//  Escape
//
//  Created by Arjun Kunjilwar on 7/16/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BrickColors.h"
#import "Constants.h"

@interface Entity : SKSpriteNode

@property int colorIndex;
- (NSMutableArray *)generateTextureArrayOfShape:(SKShapeNode *)shape;
- (instancetype)initWithSize;
- (int)getColorIndex;
@end
