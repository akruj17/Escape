//
//  GameOverView.h
//  Escape
//
//  Created by Arjun Kunjilwar on 7/3/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameOverViewProtocol.h"

@interface GameOverView : UIView
- (instancetype)initWithFrame:(CGRect)frame belowLayer:(CALayer *)layer;
@property (nonatomic, weak) id<GameOverViewProtocol> delegate;
- (void) presentWithoutAnimation;
- (void) presentWithAnimation;
- (void) resetProperties;
- (void)pauseAnimation;
-(void)resumeAnimation;
@end
