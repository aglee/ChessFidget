//
//  HumanPlayer.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/18/17.
//  Copyright © 2017 Andy Lee. All rights reserved.
//

import Foundation

class HumanPlayer: Player {
	override var isHuman: Bool { true }

	init() { super.init(name: "Human") }

	override func beginTurn() {	}
}
