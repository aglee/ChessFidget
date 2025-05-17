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
	/// Don't set this.  `Game` will set it for each `Player` passed to its
	/// `init` method.
	weak var owningGame: Game?
	private(set) var name: String
	var isHuman: Bool { false }

	init(name: String) {
		self.name = name
	}

	/// If the player is non-human, it must generate a move and call `applyGeneratedMove()` on its
	/// `owningGame`.
	func beginTurn() {
		if !isHuman { fatalError("Must override 'beginTurn()'.") }
	}
}
