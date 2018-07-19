//
//  SettingsVC.m
//  Escape
//
//  Created by Arjun Kunjilwar on 7/10/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "SettingsVC.h"

@interface SettingsVC ()

- (IBAction)backButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *soundsSwitch;


@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [_soundsSwitch setOn:[preferences boolForKey:@"playAudio"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonPressed:(id)sender {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setBool:_soundsSwitch.isOn forKey:@"playAudio"];
    [preferences synchronize];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
