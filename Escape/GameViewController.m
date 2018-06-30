//
//  GameViewController.m
//  Escape
//
//  Created by Arjun Kunjilwar on 6/15/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
@import GoogleMobileAds;

@interface GameViewController()
@property(nonatomic, strong) GADBannerView *bannerView;
@property(nonatomic, strong) GADInterstitial *interstitial;
@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // In this case, we instantiate the banner with desired ad size.
    self.bannerView = [[GADBannerView alloc]
                       initWithAdSize:kGADAdSizeSmartBannerPortrait];
    
    //[self addBannerViewToView:self.bannerView];
    
    self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
//    self.interstitial = [self createAndLoadInterstitial];
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    SKView *skView = (SKView *)self.view;
    if (!skView.scene) {
        GameScene *scene = [GameScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:scene];
        
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
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

@end
