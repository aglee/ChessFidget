//
//  Player.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/18/17.
//  Copyright © 2017 Andy Lee. All rights reserved.
//

import Foundation

/// Abstract base class representing a player in a chess game.
/// Upon generating the move it wants to play, the player must call
/// `applyGeneratedMove` on its `owningGame`.
class Player {
	/// Don't set this.  `Game` will set it for each `Player` passed to its
	/// `init` method.
	weak var owningGame: Game?
	private(set) var name: String
	var isHuman: Bool { fatalError("Must override property 'isHuman'.") }

	init(name: String) {
		self.name = name
	}

	/// Called when the player's opponent has made a move.
	func opponentDidMove(_ move: Move) { }
}
