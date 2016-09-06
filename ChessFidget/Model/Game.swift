//
//  Game.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

class Game {
	var position: Position = Position()

	// Game play alternates between the human player and the computer.
	var humanPlayerPieceColor: PieceColor

	init(humanPlayerPieceColor: PieceColor) {
		self.humanPlayerPieceColor = humanPlayerPieceColor
	}
}

