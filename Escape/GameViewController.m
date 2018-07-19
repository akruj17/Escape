//
//  GameViewController.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/15/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "GameOverView.h"
#import "RestartView.h"
#import "GameSceneProtocol.h"
@import GoogleMobileAds;
@import GameKit;

@interface GameViewController()<CAAnimationDelegate, GameSceneProtocol, GameOverViewProtocol, GADBannerViewDelegate, GADRewardBasedVideoAdDelegate, GADInterstitialDelegate, GKGameCenterControllerDelegate>
@property(nonatomic, strong) GADBannerView *bannerView;
@property(nonatomic, strong) GADInterstitial *interstitial;
@property (weak, nonatomic) IBOutlet SKView *sceneView;
@property (weak, nonatomic) IBOutlet RestartView *restartScreen;
- (IBAction)homeButtonPressed:(id)sender;
- (IBAction)restartButtonPressed:(id)sender;
@end

@implementation GameViewController {
    BOOL initialized; //used to prevent reloading of the scene
    BOOL gcEnabled; //stores whether user is logged into game center
    NSString *gcDefaultLeaderBoard;
    NSString *LEADERBOARD_ID;
    GameOverView *gameOver;
    int score;
    BOOL secondChanceOccured, completedVideo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    LEADERBOARD_ID = @"com.scores.colorescape";
    //initialize the bottom banner view.
    self.bannerView = [[GADBannerView alloc]
                       initWithAdSize:kGADAdSizeSmartBannerPortrait];
    [self addBannerViewToView:self.bannerView];

    self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    self.bannerView.rootViewController = self;
    self.bannerView.delegate = self;
    [self.bannerView loadRequest:[GADRequest request]];
    //initialize the reward video
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request] withAdUnitID:@"ca-app-pub-3940256099942544/1712485313"];

    //initialize the interstitial ad
    self.interstitial = [self createAndLoadInterstitial];
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (_sceneView && !initialized) {
        GameScene *scene = [GameScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        scene.gameDelegate = self;
        [_sceneView presentScene:scene];
        initialized = YES;
        gameOver = [[GameOverView alloc] initWithFrame:self.view.frame belowLayer:_restartScreen.layer];
        gameOver.delegate = self;
        gameOver.tag = 1;
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)addBannerViewToView:(UIView *)bannerView {
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bannerView];
    [self.view addConstraints:@[
        [NSLayoutConstraint constraintWithItem:bannerView
            attribute:NSLayoutAttributeBottom
            relatedBy:NSLayoutRelationEqual
            toItem:self.bottomLayoutGuide
            attribute:NSLayoutAttributeTop
            multiplier:1
            constant:0],
        [NSLayoutConstraint constraintWithItem:bannerView
            attribute:NSLayoutAttributeCenterX
            relatedBy:NSLayoutRelationEqual
            toItem:self.view
            attribute:NSLayoutAttributeCenterX
            multiplier:1
            constant:0]
        ]];
}

- (void)leaderBoardClicked {
    __weak GKLocalPlayer *currPlayer = [GKLocalPlayer localPlayer];
    __weak typeof(self) weakSelf = self;
    [currPlayer setAuthenticateHandler:^(UIViewController * _Nullable viewController, NSError * _Nullable error) {
        if (viewController) {
            [weakSelf presentViewController:viewController animated:true completion:nil];
        } else if (currPlayer.isAuthenticated) {
            self->gcEnabled = YES;
            [currPlayer loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString * _Nullable leaderboardIdentifier, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error);
                } else {
                    self->gcDefaultLeaderBoard = leaderboardIdentifier;
                }
            }];
        } else {
            self->gcEnabled = false;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Game Center is not installed" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:NO completion:nil];
        }
    }];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)checkGCLeaderboard {
    GKGameCenterViewController *gcVC = [[GKGameCenterViewController alloc] init];
    gcVC.gameCenterDelegate = self;
    gcVC.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcVC.leaderboardIdentifier = LEADERBOARD_ID;
    [self presentViewController:gcVC animated:TRUE completion:nil];
}

- (void)moveToGameOverWithScore:(int)score {
    [self.view insertSubview:gameOver belowSubview:_restartScreen];
    self->score = score;
    if ([[GADRewardBasedVideoAd sharedInstance] isReady] && !secondChanceOccured) { // present the continue option
        [gameOver presentWithAnimation];
        secondChanceOccured = YES;
    } else {
        [gameOver presentWithoutAnimation];
    }
}

- (void)moveToRestartView {
    _restartScreen.hidden = NO;
    _restartScreen.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        self->_restartScreen.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (self.interstitial.isReady) {
            [self.interstitial presentFromRootViewController:self];
        }
    }];
    // submit to gamecenter if higher score
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    int highscore = 0;
    if ([preferences objectForKey:@"highscore"]) {
        highscore = (int)[preferences integerForKey:@"highscore"];
    }
    if (score > highscore) {
        GKScore *bestScore = [[GKScore alloc] initWithLeaderboardIdentifier:LEADERBOARD_ID];
        bestScore.value = score;
        [GKScore reportScores:@[bestScore] withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"%@", error);
            }
        }];
        [preferences setInteger:score forKey:@"highscore"];
        [preferences synchronize];
        highscore = score;
    }
    [_restartScreen setScore:score Highscore:highscore];
    GameScene *scene = (GameScene *)_sceneView.scene;
    [[scene childNodeWithName:@"gameLayer"] removeFromParent];
    [scene setUpCurrentGame];
    // reset video ad properties
    secondChanceOccured = NO;
    completedVideo = NO;
}

- (void)continueButtonPressed {
    [gameOver pauseAnimation];
    [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self];
}

- (void)pauseGame {
    GameScene *scene = (GameScene *)_sceneView.scene;
    if ([scene getCurrentMode] == GAME_PLAY) {
        [scene transitionToPauseMode];
    }
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    if (!completedVideo) {
        [gameOver resumeAnimation];
    }
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request] withAdUnitID:@"ca-app-pub-3940256099942544/1712485313"];

}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward {
    GameScene *scene = (GameScene *)_sceneView.scene;
    [gameOver resetProperties];
    [gameOver removeFromSuperview];
    completedVideo = YES;
    _restartScreen.hidden = YES;
    [scene startSecondChanceGame];
}

- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3940256099942544/4411468910"];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];
    return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    self.interstitial = [self createAndLoadInterstitial];
}

- (void)settingsClicked {
    [self performSegueWithIdentifier:@"toSettings" sender:nil];
}

- (void)cleanUpGameOverView {
    _restartScreen.hidden = YES;
    [gameOver resetProperties];
    [gameOver removeFromSuperview];
}

- (IBAction)homeButtonPressed:(id)sender {
    GameScene *scene = (GameScene *)_sceneView.scene;
    [scene transitionToHomeMode];
    [self cleanUpGameOverView];
}

- (IBAction)restartButtonPressed:(id)sender {
    [self cleanUpGameOverView];
    GameScene *scene = (GameScene *)_sceneView.scene;
    [scene transitionToGameMode];
}

@end
