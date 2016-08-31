//
//  Board.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/29/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

struct Board {
	private var elements: [Piece?] = Array<Piece?>(repeating: nil, count: 64)

	func indexIsValid(_ x: Int, _ y: Int) -> Bool {
		return x >= 0 && x < 8 && y >= 0 && y < 8
	}

	func pathIsClear(from fromSquare: Square, to toSquare: Square, vector: Vector, canRepeat: Bool) -> Bool {
		var sq = fromSquare
		while true {
			sq = sq.plus(vector)

			if !self.indexIsValid(sq.x, sq.y) {
				return false
			} else if sq == toSquare {
				return true
			} else if self[sq] != nil {
				return false
			} else if !canRepeat {
				return false
			}
		}
	}

	// Assumes there is at most one square with a king of the given color.
	func squareWithKing(_ color: PieceColor) -> Square? {
		let king = Piece(color, .King)
		for x in 0...7 {
			for y in 0...7 {
				if let piece = self[x, y] {
					if piece == king {
						return Square(x: x, y: y)
					}
				}
			}
		}
		return nil
	}

	func isInCheck(_ color: PieceColor) -> Bool {
		guard let kingSquare = squareWithKing(color) else {
			return false
		}

		// Find all enemy pieces on the board and see if they attack the square the king is on.
		for x in 0...7 {
			for y in 0...7 {
				guard let piece = self[x, y] else {
					continue
				}
				if piece.color != color.opponent {
					continue
				}

				if piece.type == .Pawn {
					// Special handling for pawns.
					if [-1, 1].contains(x - kingSquare.x)
						&& kingSquare.y == y + piece.color.forwardDirection {
						return true
					}
				} else {
					// All other piece types.
					for vec in piece.type.movement.vectors {
						if pathIsClear(from: Square(x: x, y: y),
						               to: kingSquare,
						               vector: vec,
						               canRepeat: piece.type.movement.canRepeat) {
							return true
						}
					}
				}
			}
		}

		return false
	}

	// MARK: - Subscripting

	subscript(_ x: Int, _ y: Int) -> Piece? {
		get {
			assert(indexIsValid(x, y), "Index out of range")
			return elements[(y * 8) + x]
		}
		set {
			assert(indexIsValid(x, y), "Index out of range")
			elements[(y * 8) + x] = newValue
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
}

