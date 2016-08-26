//
//  Board.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Foundation

struct Board {
	private var contents: [Piece?] = Array<Piece?>(repeating: nil, count: 64)

	init(newGame: Bool = true) {
		if newGame {
			placePiecesForNewGame()
		}
	}

	mutating func removeAllPieces() {
		contents = Array<Piece?>(repeating: nil, count: 64)
	}

	mutating func setUpNewGame() {
		removeAllPieces()
		placePiecesForNewGame()
	}

	// MARK: - Subscripting

	subscript(_ x: Int, _ y: Int) -> Piece? {
		get {
			assert(indexIsValid(x, y), "Index out of range")
			return contents[(y * 8) + x]
		}
		set {
			assert(indexIsValid(x, y), "Index out of range")
			contents[(y * 8) + x] = newValue
		}
	}

	subscript(_ square: Square) -> Piece? {
		get {
			return self[square.x, square.y]
		}
		set {
			self[square.x, square.y] = newValue
		}
	}

	// MARK: - Private functions

	private func indexIsValid(_ x: Int, _ y: Int) -> Bool {
		return x >= 0 && x < 8 && y >= 0 && y < 8
	}

	mutating func placePiecesForNewGame() {
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

