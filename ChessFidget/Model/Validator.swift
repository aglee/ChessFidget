//
//  Validator.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

struct Validator {
	let position: Position

	func canMove(from: Square, to: Square) -> Bool {
		if !playerHasPiece(at: from) {
			return false
		}
		return true
	}

	// MARK: - Private functions

	private func playerHasPiece(at square: Square) -> Bool {
		if let piece = position.board[square] {
			return piece.color == position.meta.whoseTurn
		} else {
			return false
		}
	}
	
}


