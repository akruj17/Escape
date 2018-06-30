//
//  UIColor+ColorExtensions.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/21/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "UIColor+ColorExtensions.h"

@implementation UIColor (ColorExtensions)

+ (UIColor *) greenBrickColor
{
    return [UIColor colorWithRed:162.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1.0];
}

+ (UIColor *) blueBrickColor
{
    return [UIColor colorWithRed:0/255.0 green:162.0/255.0 blue:255.0/255.0 alpha:1.0];
}

+ (UIColor *) redBrickColor
{
    return [UIColor colorWithRed:162.0/255.0 green:0/255.0 blue:255.0/255.0 alpha:1.0];
}
+ (UIColor *) yellowBrickColor
{
    return [UIColor colorWithRed:255.0/255.0 green:0/255.0 blue:162.0/255.0 alpha:1.0];
}

+ (UIColor *) orangeBrickColor
{
    return [UIColor colorWithRed:255.0/255.0 green:162.0/255.0 blue:0/255.0 alpha:1.0];
}

+ (UIColor *) grayLabelColor
{
    return [UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0];
}

+ (UIColor *) grayBackgroundColor
{
    return [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
}
@end
