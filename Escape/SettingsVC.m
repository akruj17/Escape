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


@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
