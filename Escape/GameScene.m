//
//  GameScene.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/15/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "GameScene.h"
#import "Shooter.h"
#import "Bullet.h"
#import "Brick.h"
#import "Constants.h"
#import "BrickColors.h"
#import "UIColor+ColorExtensions.h"
#import "BrickManager.h"

@interface GameScene()<SKPhysicsContactDelegate>@end

@implementation GameScene {
    Shooter *shooter;
    CGPoint center;
    float _bulletInterval;
    CFTimeInterval _lastUpdateTime;
    NSTimeInterval _dt, _colorInterval, _timeSinceRoundStart;
    NSArray *colors;
    SKLabelNode *scoreLbl, *timeLbl, *pauseMessage;
    int score, currentColorIndex, roundNum;
    int numBricksPerLayer[NUM_LAYERS];
    BrickManager *manager;
    SKAction *transitionAnimation, *addMorphAction;
    NSMutableArray *specialActions, *threadActions;
    Modes currMode;
    SKNode *homeLayer, *pauseLayer, *gameLayer;
}

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.physicsWorld.contactDelegate = self;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = EDGE;
        center = CGPointMake(self.size.width / 2, self.size.height / 2);
        colors = [[BrickColors sharedBrickArray] brickColors];
        //set up layers
        [self setUpHomeLayer];
        [self setUpPauseLayer];
        [self setUpGameLayer];
        [self setUpShooter];
        //start game specific actions
        [self setUpCurrentGame];
        [self transitionToHomeMode];
        _colorInterval = 4.01;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint curr = [[touches anyObject] locationInNode:self];
    CGFloat angle = atan2(curr.y - center.y, curr.x - center.x);
    shooter.zRotation = angle - M_PI_2;
    if (currMode == HOME) {
        NSString *itemTapped = [self nodeAtPoint:curr].name;
        if ([itemTapped isEqualToString:@"play"]) {
            [self transitionToGameMode];
        } else if ([itemTapped isEqualToString:@"leaderboard"]) {
            [_gameOverDelegate leaderBoardClicked];
        } else if ([itemTapped isEqualToString:@"settings"]) {
            [_gameOverDelegate settingsClicked];
        }
    } else if (currMode == GAME_ABOUT_TO_START) {
        currMode = GAME_PLAY;
    } else if (currMode == GAME_PLAY) {
        if ([[self nodeAtPoint:curr].name isEqualToString:@"pauseBtn"]) {
            [self addChild:pauseLayer];
            currMode = GAME_PAUSED;
            [self enumerateChildNodesWithName:@"bullet" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
                ((Bullet *)node).velocity = node.physicsBody.velocity;
                node.physicsBody.velocity = CGVectorMake(0, 0);
            }];
        } else {
            NSArray *childs = [gameLayer children];
            for (int i = 0; i < [childs count]; i++) {
                NSLog(@"%@", ((SKNode *)[childs objectAtIndex:i]).name);
            }
        }
    } else if (currMode == GAME_PAUSED) {
        [pauseLayer removeFromParent];
        [self enumerateChildNodesWithName:@"bullet" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            node.physicsBody.velocity = ((Bullet *)node).velocity;
        }];
        currMode = GAME_PLAY;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    if (currMode == HOME || currMode == GAME_PLAY) {
        _dt = (_lastUpdateTime) ? currentTime - _lastUpdateTime : 0;
        _lastUpdateTime = currentTime;
        _bulletInterval += _dt;
        _colorInterval += _dt;
        if (_colorInterval > 4.0) {
            do {
                currentColorIndex  = (int)arc4random_uniform(NUM_BRICK_COLORS);
            } while ([manager numBricksWithColorIndex:currentColorIndex] == 0);
            [shooter changeColorTo:currentColorIndex];
            _colorInterval = 0;
        }
        if (_bulletInterval > 0.15) { //add new regular bullet
            _bulletInterval = 0;
            Bullet *bullet = [[Bullet alloc] initRegularBulletWithColorIndex:currentColorIndex];
            bullet.position = center;
            bullet.physicsBody.velocity = CGVectorMake(150 * cos(shooter.zRotation + M_PI_2), 150 * sin(shooter.zRotation + M_PI_2));
            [self addChild:bullet];
        }
        if (currMode == GAME_PLAY) {
            _timeSinceRoundStart += _dt;
            int timePassed = (int)(_timeSinceRoundStart / 1);
            timeLbl.text = [NSString stringWithFormat:@"%i", SECS_PER_ROUND - timePassed];
            if (timePassed == SECS_PER_ROUND) {
                currMode = GAME_STOPPED;
                if (numBricksPerLayer[INNER] > 0) {
                    [self runAction:manager.inwardBricksCollideAction];
                    [_gameOverDelegate presentGameOverViewWithScore:score];
                } else {
                [manager removeInnerLayer];
                    [self transitionToNextRound];
                }
            }
        }
       
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    if (collision == (BRICK | SHOOTER)) {
        [manager breakBlock:((contact.bodyA.categoryBitMask == BRICK) ? (Brick *)contact.bodyA.node : (Brick *)contact.bodyB.node)];
    } else {
        Bullet *bulletToRemove = (contact.bodyA.categoryBitMask == BULLET) ? (Bullet *)contact.bodyA.node : (Bullet *)contact.bodyB.node;
        if (collision == (BRICK | BULLET)) {
            Brick *brick = (contact.bodyA.categoryBitMask == BRICK) ? (Brick *)contact.bodyA.node : (Brick *)contact.bodyB.node;
            if ([bulletToRemove getColorIndex] == [brick getColorIndex]) {
                [brick runAction:[brick enlargeAction]];
                if (brick.xScale > 1.9) {
                    int layerNum = [[brick.name substringFromIndex:5] intValue] / 16;
                    numBricksPerLayer[layerNum]--;
                    [manager removeBrick:brick];
                    scoreLbl.text = [NSString stringWithFormat:@"%i", ++score];
                }
            }
        } else {
            SKNode *homeElement = (contact.bodyA.categoryBitMask == HOME_ELEMENT) ? (SKSpriteNode *)contact.bodyA.node : (SKSpriteNode *)contact.bodyB.node;
            if (![homeElement actionForKey:@"downScale"]) {
                if ([homeElement xScale] >= 1.0) {
                    [homeElement runAction:[SKAction scaleTo:0.6 duration:0.5] withKey:@"downScale"];
                } else {
                    [homeElement runAction:[SKAction scaleTo:homeElement.xScale + 0.02 duration:0.2]];
                }
            }

        }
        [bulletToRemove runAction:[SKAction sequence:@[ [SKAction removeFromParent]]]];
    }
}

- (void)setUpCurrentGame {
    _timeSinceRoundStart = _lastUpdateTime = 0;
    timeLbl.text = [NSString stringWithFormat:@"%i", SECS_PER_ROUND];
    scoreLbl.text = [NSString stringWithFormat:@"%i", 0];
    roundNum = 0;
    numBricksPerLayer[OUTER] = numBricksPerLayer[MIDDLE] = 16;
    numBricksPerLayer[INNER] = 0;
    specialActions = [[NSMutableArray alloc] init];
    threadActions = [[NSMutableArray alloc] init];
    [manager addBeginningBricksAtPoints];
}

- (void)transitionToNextRound {
    timeLbl.text = [NSString stringWithFormat:@" "];
    roundNum++;
    _timeSinceRoundStart = _lastUpdateTime = 0;
    NSMutableArray *sequence = [[NSMutableArray alloc] initWithObjects:transitionAnimation, [SKAction waitForDuration:2.0], [SKAction runBlock:^{
        self->currMode = GAME_PLAY;
    }], [SKAction waitForDuration:1.0],nil];
    specialActions = threadActions;
    [sequence addObjectsFromArray:specialActions];
    [sequence addObject:[SKAction waitForDuration:5.0]];
    
    [self runAction:[SKAction sequence:sequence] completion:^{
        self->addMorphAction = [self->manager addMorphBullets];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int numActions = (self->roundNum > 5) ? 2 : 1;
            NSMutableArray *layers = [[NSMutableArray alloc] initWithArray:@[@(OUTER), @(MIDDLE), @(INNER)]];
            [self->threadActions removeAllObjects];
            for (int i = 0; i < numActions; i++) {
                int actionType = arc4random_uniform(4);
                int layerNum = [[layers objectAtIndex:arc4random_uniform((int)[layers count])] intValue];
                NSLog(@"testing action %i on layer %i", actionType, layerNum);
                [layers removeObject:@(layerNum)];
                SKAction *action;
                switch (actionType) {
                    case 0: //change colors
                        action = [self->manager changeBrickColorsRound:layerNum];
                        break;
                    case 1: //bricks switch side
                        action = [self->manager bricksSwitchSides:layerNum];
                        break;
                    case 2: //hide bricks
                        action = [self->manager hideBricks:layerNum];
                        break;
                    case 3: //bricks always rotate
                        action = [self->manager bricksAlwaysRotating:layerNum];
                }
                [self->threadActions addObject:action];
            }
        });
    }];
    numBricksPerLayer[INNER] = numBricksPerLayer[MIDDLE];
    numBricksPerLayer[MIDDLE] = numBricksPerLayer[OUTER];
    numBricksPerLayer[OUTER] = 16;
}
     
- (void)setUpShooter {
    shooter = [[Shooter alloc] initWithSize:40];
    shooter.position = center;
    shooter.name = @"shooter";
    shooter.zPosition = 90;
    [self addChild:shooter];
}

// the game scene will function as both the title screen and actual gameplay.
- (void)setUpHomeScreen {
    NSArray *namesAndPos = @[@"escape", @130, @0.8, @"play", @90, @0.275];
    for (int i = 0; i < [namesAndPos count] / 3; i++) {
        SKLabelNode *label = [SKLabelNode labelNodeWithText:[namesAndPos objectAtIndex:(3 * i)]];
        label.fontSize = [[namesAndPos objectAtIndex:(3 * i) + 1] floatValue];
        label.numberOfLines = 2;
        label.fontName = @"HelveticaNeue-UltraLight";
        SKTexture *texture = [[SKView new] textureFromNode:label];
        texture.filteringMode = SKTextureFilteringNearest;
        SKSpriteNode *el = [SKSpriteNode spriteNodeWithTexture:texture];
        el.position = CGPointMake(self.size.width / 2, self.size.height * [[namesAndPos objectAtIndex:(3 * i) + 2] floatValue]);
        el.name = [namesAndPos objectAtIndex:(3 * i)];
        [el setScale:0.6];
        el.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:el.frame.size];
        el.physicsBody.dynamic = NO;
        el.physicsBody.categoryBitMask = HOME_ELEMENT;
        [self addChild:el];
    }
    namesAndPos = @[@"leaderboard", @0.28, @"settings", @0.72];
    for (int i = 0; i < [namesAndPos count] / 2; i++) {
        SKSpriteNode *el = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[namesAndPos objectAtIndex:(2 * i)]]];
        el.size = CGSizeMake(80, 80);
        el.position = CGPointMake([[namesAndPos objectAtIndex:(2 * i) + 1] floatValue] * self.size.width, self.size.height * 0.18);
        el.name = [namesAndPos objectAtIndex:(2 * i)];
        [el setScale:0.6];
        el.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:el.frame.size];
        el.physicsBody.dynamic = NO;
        el.physicsBody.categoryBitMask = HOME_ELEMENT;
        [self addChild:el];
    }

    [self transitionToHomeMode];
}

- (void)setUpHomeLayer {
    homeLayer = [SKNode node];
    NSArray *namesAndPos = @[@"escape", @130, @0.8, @"play", @90, @0.275];
    for (int i = 0; i < [namesAndPos count] / 3; i++) {
        SKLabelNode *label = [SKLabelNode labelNodeWithText:[namesAndPos objectAtIndex:(3 * i)]];
        label.fontSize = [[namesAndPos objectAtIndex:(3 * i) + 1] floatValue];
        label.numberOfLines = 2;
        label.fontName = @"HelveticaNeue-UltraLight";
        SKTexture *texture = [[SKView new] textureFromNode:label];
        texture.filteringMode = SKTextureFilteringNearest;
        SKSpriteNode *el = [SKSpriteNode spriteNodeWithTexture:texture];
        el.position = CGPointMake(self.size.width / 2, self.size.height * [[namesAndPos objectAtIndex:(3 * i) + 2] floatValue]);
        el.name = [namesAndPos objectAtIndex:(3 * i)];
        [el setScale:0.6];
        el.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:el.frame.size];
        el.physicsBody.dynamic = NO;
        el.physicsBody.categoryBitMask = HOME_ELEMENT;
        el.physicsBody.contactTestBitMask = BULLET;
        [homeLayer addChild:el];
    }
    namesAndPos = @[@"leaderboard", @0.28, @"settings", @0.72];
    for (int i = 0; i < [namesAndPos count] / 2; i++) {
        SKSpriteNode *el = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[namesAndPos objectAtIndex:(2 * i)]]];
        el.size = CGSizeMake(80, 80);
        el.position = CGPointMake([[namesAndPos objectAtIndex:(2 * i) + 1] floatValue] * self.size.width, self.size.height * 0.18);
        el.name = [namesAndPos objectAtIndex:(2 * i)];
        [el setScale:0.6];
        el.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:el.frame.size];
        el.physicsBody.dynamic = NO;
        el.physicsBody.categoryBitMask = HOME_ELEMENT;
        el.physicsBody.contactTestBitMask = BULLET;
        [homeLayer addChild:el];
    }
}

- (void)setUpPauseLayer {
    pauseLayer = [SKNode node];
    SKShapeNode *background = [SKShapeNode shapeNodeWithRectOfSize:self.size];
    background.position = center;
    background.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    [pauseLayer addChild:background];
    SKLabelNode *pauseLbl = [SKLabelNode labelNodeWithText:@"Tap anywhere to resume"];
    pauseLbl.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    pauseLbl.position = center;
    pauseLbl.name = @"pauseLbl";
    [pauseLayer addChild:pauseLbl];
    pauseLayer.zPosition = 100;
}

// add the time and score label
- (void)setUpGameLayer {
    //add labels and pause button
    gameLayer = [SKNode node];
    gameLayer.name = @"gameLayer";
    scoreLbl = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    scoreLbl.fontSize = 50.0;
    scoreLbl.position = CGPointMake(0.5 * self.size.width, 0.93 * self.size.height);
    scoreLbl.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    scoreLbl.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [gameLayer addChild:scoreLbl];
    timeLbl = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    timeLbl.fontSize = 60.0;
    timeLbl.position = CGPointMake(0.90 * self.size.width, (0.93 * self.size.height));
    timeLbl.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    timeLbl.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [gameLayer addChild:timeLbl];
    SKSpriteNode *pauseBtn = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"pause"]];
    pauseBtn.size = CGSizeMake(0.1 * self.size.width, 0.1 * self.size.width);
    pauseBtn.position = CGPointMake(0.1 * self.size.width, (0.93 * self.size.height) - (pauseBtn.size.height / 2));
    pauseBtn.anchorPoint = CGPointZero;
    pauseBtn.name = @"pauseBtn";
    [gameLayer addChild:pauseBtn];
    //initialize the brick manager, and make references to the transition animations
    manager = [[BrickManager alloc] initWithGameLayer:gameLayer andParentScene:self];
    addMorphAction = [manager addMorphBullets];
    transitionAnimation = [SKAction group:@[[SKAction runAction:manager.shiftBricksInwardAction onChildWithName:@"gameLayer"], [SKAction sequence:@[[SKAction runAction:[SKAction scaleTo:0.7 duration:0.3] onChildWithName:@"shooter"], [SKAction group:@[[SKAction runAction:[SKAction sequence:@[[SKAction scaleTo:2.0 duration:0.3], [SKAction scaleTo:1.0 duration:0.5]]] onChildWithName:@"shooter"], addMorphAction]]]]]];
}

- (void)transitionToHomeMode {
    if (gameLayer) {
        [gameLayer removeFromParent];
    }
    [self addChild:homeLayer];
    currMode = HOME;
}

- (void)transitionToGameMode {
    if (homeLayer) {
        [homeLayer removeFromParent];
    }
    [self addChild:gameLayer];
    currMode = GAME_ABOUT_TO_START;
    [self removeAllBullets];
}

- (void)removeAllBullets {
    [self enumerateChildNodesWithName:@"bullet" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        [node removeAllActions];
        [node removeFromParent];
    }];
}

// after watching an ad, the player can continue the game
- (void)startSecondChanceGame {
    [manager removeInnerLayer];
    _timeSinceRoundStart = _lastUpdateTime = 0;
}

@end
