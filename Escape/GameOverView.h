//
//  GameOverView.h
//  Escape
//
//  Created by Arjun Kunjilwar on 7/3/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdProtocol.h"

@interface GameOverView : UIView
- (instancetype)initWithFrame:(CGRect)frame belowLayer:(CALayer *)layer;
@property (nonatomic, weak) id<AdPresenterProtocol> delegate;
- (void) presentWithoutAnimation;
- (void) presentWithAnimation;

@end
