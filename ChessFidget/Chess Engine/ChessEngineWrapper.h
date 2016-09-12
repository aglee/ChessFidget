//
//  ChessEngineWrapper.h
//  SjengFiddling
//
//  Created by Andy Lee on 9/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBCBoard.h"

@interface ChessEngineWrapper : NSObject
- (id)initWithComputerPlayingSide:(MBCSide)side;
- (void)sendMove:(NSString *)moveString;
@end
