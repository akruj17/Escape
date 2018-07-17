//
//  Entity.m
//  Escape
//
//  Created by Arjun Kunjilwar on 7/16/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "Entity.h"
#import "BrickColors.h"

@implementation Entity

- (NSMutableArray *)generateTextureArrayOfShape:(SKShapeNode *)shape {
    SKShapeNode *genShape = shape;
    NSArray *colors = [[BrickColors sharedBrickArray] brickColors];
    NSMutableArray *textures = [[NSMutableArray alloc] init];
    SKView *textureView = [SKView new];
    SKTexture *texture = nil;
    for (int i = 0; i < [colors count]; i++) {
        genShape.strokeColor = [colors objectAtIndex:i];
        genShape.fillColor = [colors objectAtIndex:i];
        texture = [textureView textureFromNode:genShape];
        texture.filteringMode = SKTextureFilteringNearest;
        [textures addObject:texture];
    }
    return textures;
}

- (int)getColorIndex {
    NSLog(@"GOjijijG");
    return self.colorIndex;
}

@end
