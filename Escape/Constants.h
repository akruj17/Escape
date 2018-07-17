//
//  Constants.h
//  Escape
//
//  Created by Arjun Kunjilwar on 6/19/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

extern float const BRICK_WIDTH;
extern float const OUTER_LAYER_VERTICAL_BRICK_HEIGHT;
extern float const VERTICAL_SPACING;
extern float const HORIZONTAL_SPACING;
extern NSString *const LAYERING_POS_VALUES;
extern int const BULLET_RADIUS;
extern int const NUM_BRICKS_PER_LAYER;
extern int const NUM_HORIZONTAL_BRICKS_PER_LAYER;
extern int const NUM_VERTICAL_BRICKS_PER_LAYER;
extern int const SECS_PER_ROUND;
extern int const NUM_BRICK_COLORS;
typedef enum {
    OUTER,
    MIDDLE,
    INNER,
    NUM_LAYERS
} LayerNames;
typedef enum {
    EDGE = 1,
    BRICK = 1 << 1,
    BULLET = 1 << 2,
    SHOOTER = 1 << 3,
    HOME_ELEMENT = 1 << 4
} BitmaskCategories;
typedef enum {
    HOME,
    GAME_PLAY,
    GAME_ABOUT_TO_START,
    GAME_PAUSED,
    GAME_STOPPED
} Modes;
#endif /* Constants_h */
