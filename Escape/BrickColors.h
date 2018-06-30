//
//  BrickColors.h
//  Escape
//
//  Created by Arjun Kunjilwar on 6/21/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrickColors : NSObject

+ (BrickColors *)sharedBrickArray;   // class method to return the singleton object
@property (nonatomic, retain) NSArray *brickColors;

@end
