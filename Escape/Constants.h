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
extern int const EDGE_CATEGORY_BITMASK;
extern int const BRICK_CATEGORY_BITMASK;
extern int const BULLET_CATEGORY_BITMASK;
extern int const BULLET_RADIUS;
extern int const NUM_BRICKS_PER_LAYER;
typedef enum {
    OUTER,
    MIDDLE,
    INNER,
    NUM_LAYERS
} LayerNames;
#endif /* Constants_h */
