//
//  ChessEngineWrapper.h
//
//  Created by Andy Lee on 9/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Game;

@interface ChessEngineWrapper : NSObject

@property (weak) Game *game;
@property int maxSearchDepth;
@property int maxSecondsPerMove;

+ (instancetype)chessEngineWithComputerPlayingBlack;
+ (instancetype)chessEngineWithComputerPlayingWhite;

- (void)sendEngineHumanMove:(NSString *)moveString;

@end
