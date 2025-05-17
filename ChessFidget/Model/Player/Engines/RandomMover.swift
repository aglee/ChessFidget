//
//  RandomMover.swift
//  ChessFidget
//
//  Created by Andy Lee on 5/17/25.
//  Copyright © 2025 Andy Lee. All rights reserved.
//

import Cocoa

class RandomMover: EnginePlayer {
	required init() {
		super.init(name: "Random Mover")
	}

	override func beginTurn() {
		guard let owningGame else { return }
		let validMoves = owningGame.position.validMoves
		guard !validMoves.isEmpty else { return }
		let moveIndex = Int(arc4random_uniform(UInt32(validMoves.count)))
		owningGame.applyMove(validMoves[moveIndex])
	}
}
