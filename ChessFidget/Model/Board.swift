//
//  Board.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/29/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

struct Board {
	private var pieces: [Piece?] = Array<Piece?>(repeating: nil, count: 64)

	init(newGame: Bool = true) {
		for x in 0...7 {
			self[x, 1] = Piece(.White, .Pawn)
			self[x, 6] = Piece(.Black, .Pawn)
		}

		let pieceTypes: [PieceType] = [.Rook, .Knight, .Bishop, .Queen, .King, .Bishop, .Knight, .Rook]
		for (x, pieceType) in pieceTypes.enumerated() {
			self[x, 0] = Piece(.White, pieceType)
			self[x, 7] = Piece(.Black, pieceType)
		}
	}

	mutating func blindlyMove(from fromSquare: Square, to toSquare: Square) {
		self[toSquare] = self[fromSquare]
		self[fromSquare] = nil
	}

	static func isWithinBounds(_ x: Int, _ y: Int) -> Bool {
		return x >= 0 && x < 8 && y >= 0 && y < 8
	}

	static func isWithinBounds(_ sq: Square) -> Bool {
		return isWithinBounds(sq.x, sq.y)
	}

	// Excluding toSquare.
	func pathIsClear(from fromSquare: Square, to toSquare: Square, vector: Vector, canRepeat: Bool) -> Bool {
		var sq = fromSquare
		while true {
			sq = sq + vector

			if !Board.isWithinBounds(sq) {
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

	// MARK: - Making moves

	// Assumes the move is valid and is correctly described by moveType.
	mutating func move(from fromSquare: Square, to toSquare: Square, moveType: MoveType) {
		guard let piece = self[fromSquare] else {
			print("ERROR: There's no piece on the from-square.")
			return
		}

		// In all cases we move the piece that's at fromSquare to toSquare.
		self.blindlyMove(from: fromSquare, to: toSquare)

		// Do additional moving/removing/replacing as needed for special cases.
		switch moveType {
		case .captureEnPassant:
			// Remove the pawn being captured.
			self[toSquare.x, fromSquare.y] = nil

		case .pawnPromotion(let promotionType):
			// Replace the pawn with the piece it's being promoted to.
			self[toSquare] = Piece(piece.color, promotionType)

		case .castleKingSide:
			// Move the king's rook.
			self.blindlyMove(from: Square(x: 7, y: piece.color.homeRow),
			                 to: Square(x: 5, y: piece.color.homeRow))

		case .castleQueenSide:
			// Move the queen's rook.
			self.blindlyMove(from: Square(x: 0, y: piece.color.homeRow),
			                 to: Square(x: 3, y: piece.color.homeRow))

		default: break
		}
	}

	// MARK: - Subscripting

	subscript(_ x: Int, _ y: Int) -> Piece? {
		get {
			assert(Board.isWithinBounds(x, y), "Index out of range")
			return pieces[(y * 8) + x]
		}
		set {
			assert(Board.isWithinBounds(x, y), "Index out of range")
			pieces[(y * 8) + x] = newValue
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

	private func squareWithKing(_ color: PieceColor) -> Square? {
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
}

