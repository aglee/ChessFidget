//
//  GameObserver.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

/// Quick and dirty approximation of property observation.
protocol GameObserver {
	func gameDidChangeState(_ game: Game, oldValue: GameState)
	func gameDidMakeMove(_ game: Game, move: Move)
}

