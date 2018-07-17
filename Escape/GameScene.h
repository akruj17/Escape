//
//  GameScene.h
//  Escape
//
//  Created by Arjun Kunjilwar on 6/15/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameOverProtocol.h"

@interface GameScene : SKScene
@property (nonatomic, weak) id<GameOverProtocol> gameOverDelegate;
- (void)transitionToHomeMode;
- (void)setUpCurrentGame;
- (void)startSecondChanceGame;
@end
