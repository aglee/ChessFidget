//
//  EnginePlayer.swift
//  ChessFidget
//
//  Created by Andy Lee on 5/17/25.
//  Copyright © 2025 Andy Lee. All rights reserved.
//

import Foundation

enum EngineType: Int {
	case random = 0
	case sjeng = 1

	var engineClass: EnginePlayer.Type {
		return switch self {
		case .random: RandomMover.self
		case .sjeng: ChessEngine.self
		}
	}
}

class EnginePlayer: Player {
	override var isHuman: Bool { false }
	
	required convenience init() { fatalError("Must override 'init()'.") }
	
	static func newPlayer(_ engineType: EngineType) -> EnginePlayer {
		return engineType.engineClass.init()
	}
}
