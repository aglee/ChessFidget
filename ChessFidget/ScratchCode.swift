//
//  ScratchCode.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Foundation

extension Board {
	func text() -> String {
		var text = ""

		for y in stride(from:7, through:0, by: -1) {
			for x in 0...7 {
				text.append(Board.pieceCharacter(self[x, y]))
			}
			if y > 0 {
				text.append("\n")
			}
		}

		return text
	}

	// MARK: - Private functions

	private static func pieceCharacter(_ piece: Piece?) -> Character {
		if let piece = piece {
			switch piece.color {
			case .White:
				switch piece.type {
				case .Pawn: return "♙"
				case .Knight: return "♘"
				case .Bishop: return "♗"
				case .Rook: return "♖"
				case .King: return "♔"
				case .Queen: return "♕"
				}
			case .Black:
				switch piece.type {
				case .Pawn: return "♟"
				case .Knight: return "♞"
				case .Bishop: return "♝"
				case .Rook: return "♜"
				case .King: return "♚"
				case .Queen: return "♛"
				}
			}
		} else {
			return "•"
		}
	}
}


