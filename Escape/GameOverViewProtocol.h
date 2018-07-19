//
//  GameOverViewProtocol.h
//  Escape
//
//  Created by Arjun Kunjilwar on 7/17/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#ifndef GameOverViewProtocol_h
#define GameOverViewProtocol_h

@protocol GameOverViewProtocol
@required
- (void)continueButtonPressed;
- (void)moveToRestartView;
@end


#endif /* GameOverViewProtocol_h */
