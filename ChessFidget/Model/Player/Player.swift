//
//  Player.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/18/17.
//  Copyright © 2017 Andy Lee. All rights reserved.
//

import Foundation

class Player {
	/// Don't set this.  `Game` will set it for each `Player` passed to its
	/// `init` method.
	weak var owningGame: Game?
	private(set) var name: String
	var isHuman: Bool { fatalError("Must override property 'isHuman'.") }

	init(name: String) {
		self.name = name
	}

	/// Subclasses must override.  Called when it becomes the receiver's turn.
	/// Implementation must begin generating a move asynchronously.  When the
	/// move has been generated, the player must call `applyGeneratedMove` on
	/// `owningGame`.
	func generateMove() { fatalError("generateMove must be overridden") }

	/// Called when the player's opponent has made a move.
	func opponentDidMove(_ move: Move) { }
}
