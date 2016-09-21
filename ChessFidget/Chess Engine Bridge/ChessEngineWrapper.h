//
//  ChessEngineWrapper.h
//
//  Created by Andy Lee on 9/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Game;

/**
 * Wrapper around an instance of MBCEngine.  Why add this layer of indirection?
 * Mainly to make bridging with Swift easier.  ChessEngineWrapper.h is easily
 * #imported in ChessFidget-Bridging-Header.h without my having to fix a bunch
 * of compiler errors.
 *
 * Communicates with the backend chess engine via NSNotifications.  Posts
 * notifications to send commands to the backend engine.  Observes notifications
 * to receive responses.
 */
@interface ChessEngineWrapper : NSObject

@property (weak) Game *game;
@property int maxSearchDepth;
@property int maxSecondsPerMove;
@property BOOL shouldThinkWhileHumanIsThinking;

// MARK: - Factory methods

+ (instancetype)chessEngineWithComputerPlayingBlack;
+ (instancetype)chessEngineWithComputerPlayingWhite;

// MARK: - Communicating with the chess engine

/** moveString should be like "d2d4", or "a7a8q". */
- (void)sendEngineHumanMove:(NSString *)moveString;

@end
