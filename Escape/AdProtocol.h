//
//  AdProtocol.h
//  Escape
//
//  Created by Arjun Kunjilwar on 7/3/18.
//  Copyright © 2018 Arjun Kunjilwar. All rights reserved.
//

#ifndef AdProtocol_h
#define AdProtocol_h

@protocol AdPresenterProtocol
@required
- (void)presentVideoAd;
- (void)presentRestartView;
- (void)switchToHomeMode;
@end

#endif /* AdProtocol_h */

