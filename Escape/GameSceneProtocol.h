//
//  GameSceneProtocol.h
//  Escape
//
//  Created by Arjun Kunjilwar on 7/18/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#ifndef GameSceneProtocol_h
#define GameSceneProtocol_h

@protocol GameSceneProtocol
@required
- (void)moveToGameOverWithScore:(int)score;
- (void)leaderBoardClicked;
- (void)settingsClicked;
@end

#endif /* GameSceneProtocol_h */
