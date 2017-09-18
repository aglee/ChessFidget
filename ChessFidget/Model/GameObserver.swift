//
//  GameObserver.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

/// Basically a delegate, but different from typical delegates in that a Game
/// can have multiple GameObservers.
protocol GameObserver {
	func gameDidApplyMove(_ game: Game, move: Move, player: Player)
	func gameDidEnd(_ game: Game, reason: ReasonGameIsOver)
}

