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
			self[x, 1] = Piece(.white, .pawn)
			self[x, 6] = Piece(.black, .pawn)
		}

		let pieceTypes: [PieceType] = [.rook, .knight, .bishop, .queen, .king,
		                               .bishop, .knight, .rook]
		for (x, pieceType) in pieceTypes.enumerated() {
			self[x, 0] = Piece(.white, pieceType)
			self[x, 7] = Piece(.black, pieceType)
		}
	}

	// MARK: - Bounds checking

	static func isWithinBounds(_ x: Int, _ y: Int) -> Bool {
		return x >= 0 && x < 8 && y >= 0 && y < 8
	}

	static func isWithinBounds(_ gridPoint: GridPointXY) -> Bool {
		return isWithinBounds(gridPoint.x, gridPoint.y)
	}

	// MARK: - Evaluating moves

	// Excluding endPoint.
	func pathIsClear(from startPoint: GridPointXY,
	                 to endPoint: GridPointXY,
	                 vector: VectorXY,
	                 canRepeat: Bool) -> Bool {
		var gridPoint = startPoint
		while true {
			gridPoint = gridPoint + vector

			if !Board.isWithinBounds(gridPoint) {
				return false
			} else if gridPoint == endPoint {
				return true
			} else if self[gridPoint] != nil {
				return false
			} else if !canRepeat {
				return false
			}
		}
	}

	func isInCheck(_ color: PieceColor) -> Bool {
		guard let kingGridPoint = gridPointForSquareContainingKing(color) else {
			return false
		}

		// Find all enemy pieces on the board and see if they attack the square
		// the king is on.
		for x in 0...7 {
			for y in 0...7 {
				guard let piece = self[x, y] else {
					continue
				}
				if piece.color != color.opponent {
					continue
				}

				if piece.type == .pawn {
					// Special handling for pawns.
					if [-1, 1].contains(x - kingGridPoint.x)
						&& kingGridPoint.y == y + piece.color.forwardDirection {
						return true
					}
				} else {
					// All other piece types.
					for vec in piece.type.movement.vectors {
						if pathIsClear(from: GridPointXY(x, y),
						               to: kingGridPoint,
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

	/// Returns false if there is no piece at startPoint.
	func blindMoveWouldLeaveKingInCheck(from startPoint: GridPointXY,
	                                    to endPoint: GridPointXY) -> Bool {
		guard let piece = self[startPoint]
			else { return false }
		var tempBoard = self
		tempBoard.blindlyMove(from: startPoint, to: endPoint)
		return tempBoard.isInCheck(piece.color)
	}

	/// Returns false if there is no piece at startPoint.
	func moveWouldLeaveKingInCheck(from startPoint: GridPointXY,
	                               to endPoint: GridPointXY,
	                               type moveType: MoveType) -> Bool {
		guard let piece = self[startPoint]
			else { return false }
		var tempBoard = self
		tempBoard.makeMove(from: startPoint, to: endPoint, type: moveType)
		return tempBoard.isInCheck(piece.color)
	}
	
	// MARK: - Making moves

	mutating func makeMove(_ move: Move) {
		makeMove(from: move.start, to: move.end, type: move.type)
	}

	// Assumes the move is valid and is correctly described by moveType.
	mutating func makeMove(from startPoint: GridPointXY,
	                       to endPoint: GridPointXY,
	                       type moveType: MoveType) {
		guard let piece = self[startPoint] else {
			print("ERROR: There's no piece on the starting square.")
			return
		}

		// In all cases we move the piece that's at start to end.
		self.blindlyMove(from: startPoint, to: endPoint)

		// Do additional moving/removing/replacing as needed for special cases.
		switch moveType {
		case .captureEnPassant:
			// Remove the pawn being captured.
			self[endPoint.x, startPoint.y] = nil
		case .pawnPromotion(let promotionType):
			// Replace the pawn with the piece it's being promoted to.
			self[endPoint] = Piece(piece.color, promotionType.pieceType)
		case .castleKingSide:
			// Move the king's rook.
			self.blindlyMove(from: GridPointXY(7, piece.color.homeRow),
			                 to: GridPointXY(5, piece.color.homeRow))
		case .castleQueenSide:
			// Move the queen's rook.
			self.blindlyMove(from: GridPointXY(0, piece.color.homeRow),
			                 to: GridPointXY(3, piece.color.homeRow))
		default: break
		}
	}

	// MARK: - Subscripting

	subscript(_ x: Int, _ y: Int) -> Piece? {
		get {
			assert(Board.isWithinBounds(x, y), "Index out of bounds")
			return pieces[(y * 8) + x]
		}
		set {
			assert(Board.isWithinBounds(x, y), "Index out of bounds")
			pieces[(y * 8) + x] = newValue
		}
	}

	subscript(_ gridPoint: GridPointXY) -> Piece? {
		get {
			return self[gridPoint.x, gridPoint.y]
		}
		set {
			self[gridPoint.x, gridPoint.y] = newValue
		}
	}

	// MARK: - Private methods

	/// Move whatever piece is at startPoint (including nil) to endPoint.
	private mutating func blindlyMove(from startPoint: GridPointXY, to endPoint: GridPointXY) {
		self[endPoint] = self[startPoint]
		self[startPoint] = nil
	}

	private func gridPointForSquareContainingKing(_ color: PieceColor) -> GridPointXY? {
		let king = Piece(color, .king)
		for x in 0...7 {
			for y in 0...7 {
				if let piece = self[x, y] {
					if piece == king {
						return GridPointXY(x, y)
					}
				}
			}
		}
		return nil
	}
}

