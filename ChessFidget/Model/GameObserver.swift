//
//  GameObserver.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

// Quick and dirty property observation.
protocol GameObserver {
	func gameDidChangeStateOfPlay(_ game: Game, oldValue: Game.StateOfPlay)
	func gameDidMakeMove(_ game: Game, move: Move)
}

