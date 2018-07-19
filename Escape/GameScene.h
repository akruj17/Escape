//
//  GameScene.h
//  Escape
//
//  Created by Arjun Kunjilwar on 6/15/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameSceneProtocol.h"
#import "Constants.h"

@interface GameScene : SKScene
@property (nonatomic, weak) id<GameSceneProtocol> gameDelegate;
- (void)transitionToHomeMode;
- (void)transitionToGameMode;
- (void)transitionToPauseMode;
- (void)setUpCurrentGame;
- (void)startSecondChanceGame;
- (int)getCurrentMode;
@end
