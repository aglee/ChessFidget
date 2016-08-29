//
//  Game.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

class Game {
	var position: Position = Position()
	var moves: [Move] = []

	func addMove(_ move: Move) {
		moves.append(move)
		position.play(move: move)
	}
}


