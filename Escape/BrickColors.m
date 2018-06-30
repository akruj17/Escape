//
//  BrickColors.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/21/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "BrickColors.h"
#import "UIColor+ColorExtensions.h"

@implementation BrickColors

@synthesize brickColors;
static BrickColors *sharedInstance;


+ (BrickColors *)sharedBrickArray {
    if (sharedInstance == nil) {
        sharedInstance = [[BrickColors alloc] init];
        sharedInstance.brickColors =  @[[UIColor redBrickColor], [UIColor blueBrickColor], [UIColor greenBrickColor], [UIColor yellowBrickColor], [UIColor orangeBrickColor]];
    }
    return sharedInstance;
}


@end
