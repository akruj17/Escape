//
//  RestartView.m
//  Escape
//
//  Created by Arjun Kunjilwar on 7/10/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#import "RestartView.h"

@interface RestartView()
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *highscore;
@end

@implementation RestartView 

- (void)setScore:(int)score Highscore:(int)highscore {
    [_score setText:[NSString stringWithFormat:@"%i", score]];
    [_highscore setText:[NSString stringWithFormat:@"%i", highscore]];
}

@end
