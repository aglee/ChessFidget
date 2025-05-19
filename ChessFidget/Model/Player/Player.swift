//
//  Player.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/18/17.
//  Copyright © 2017 Andy Lee. All rights reserved.
//

import Foundation

/// Abstract base class representing a player in a chess game.
class Player {
	/// Don't set this -- let the `Game` object set it.
	weak var game: Game?
	var name: String
	var isHuman: Bool { fatalError("Must override 'isHuman'.") }

	init(name: String) {
		self.name = name
	}

	/// If the player is non-human, it must generate a move and call `applyMove()` on its `game`.
	func beginTurn() {
		if !isHuman { fatalError("Must override 'beginTurn()'.") }
	}
}

