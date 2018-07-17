//
//  GameOverProtocol.h
//  Escape
//
//  Created by Arjun Kunjilwar on 7/9/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#ifndef GameOverProtocol_h
#define GameOverProtocol_h

@protocol GameOverProtocol
@required
- (void)presentGameOverViewWithScore:(int)score;
- (void)leaderBoardClicked;
- (void)settingsClicked;
@end


#endif /* GameOverProtocol_h */
