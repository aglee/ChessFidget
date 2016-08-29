//
//  Board.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

class Board: Grid64<Piece?> {
	init(newGame: Bool = true) {
		super.init(value: nil)

		if newGame {
			placePiecesForNewGame()
		}
	}

	func setUpNewGame() {
		fill(value: nil)
		placePiecesForNewGame()
	}

	// MARK: - Private functions

	private func placePiecesForNewGame() {
		for x in 0...7 {
			self[x, 1] = Piece(.White, .Pawn)
			self[x, 6] = Piece(.Black, .Pawn)
		}

		let types: [PieceType] = [.Rook, .Knight, .Bishop, .Queen, .King, .Bishop, .Knight, .Rook]
		for (index, pieceType) in types.enumerated() {
			self[index, 0] = Piece(.White, pieceType)
			self[index, 7] = Piece(.Black, pieceType)
		}
	}
}

