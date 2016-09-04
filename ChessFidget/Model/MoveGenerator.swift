//
//  MoveGenerator.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

struct MoveGenerator {
	let position: Position

	var validMoves = MoveLookup()

	init(position: Position) {
		self.position = position
		addValidMoves()
	}

	// MARK: - Private methods

	private mutating func addValidMoves() {
		// Scan the board for pieces owned by the current player.
		for x in 0...7 {
			for y in 0...7 {
				addValidMovesFromSquare(x, y)
			}
		}

		// Look for special-case moves.
		addEnPassantCaptures()
		addKingSideCastlingIfValid()
		addQueenSideCastlingIfValid()
	}

	private mutating func addValidMovesFromSquare(_ x: Int, _ y: Int) {
		let startSquare = Square(x: x, y: y)
		guard let piece = position.board[startSquare]
			else { return }
		guard piece.color == position.whoseTurn
			else { return }

		if piece.type == .Pawn {
			addPawnForwardMoves(from: startSquare)
			addRegularPawnCaptures(from: startSquare)
		} else {
			for vector in piece.type.movement.vectors {
				addMovesAlongVector(from: startSquare, vector: vector, canRepeat: piece.type.movement.canRepeat)
			}
		}
	}

	private mutating func addPawnForwardMoves(from startSquare: Square) {
		let forward = position.whoseTurn.forwardDirection

		// Can the pawn move one square forward?
		let oneSquareForward = startSquare + (0, forward)
		guard position.board[oneSquareForward] == nil
			else { return }
		if oneSquareForward.y == position.whoseTurn.opponent.homeRow {
			addPawnPromotionMoves(from: startSquare, to: oneSquareForward)
		} else {
			addMoveIfNoCheck(startSquare, oneSquareForward, .plain)
		}

		// Can the pawn move two squares forward?
		if startSquare.y == position.whoseTurn.pawnRow {
			let twoSquaresForward = oneSquareForward + (0, forward)
			if position.board[twoSquaresForward] == nil {
				addMoveIfNoCheck(startSquare, twoSquaresForward, .pawnTwoSquares)
			}
		}
	}

	private mutating func addRegularPawnCaptures(from startSquare: Square) {
		let forward = position.whoseTurn.forwardDirection
		for dx in [-1, 1] {
			guard let endSquare = validSquareOrNil(startSquare + (dx, forward))
				else { continue }
			guard position.board[endSquare]?.color == position.whoseTurn.opponent
				else { continue }
			if endSquare.y == position.whoseTurn.opponent.homeRow {
				addPawnPromotionMoves(from: startSquare, to: endSquare)
			} else {
				addMoveIfNoCheck(startSquare, endSquare, .plain)
			}
		}
	}

	private mutating func addEnPassantCaptures() {
		guard let enPassantableSquare = position.enPassantableSquare
			else { return }

		let forward = position.whoseTurn.forwardDirection
		for dx in [-1, 1] {
			guard let startSquare = validSquareOrNil(enPassantableSquare + (dx, 0))
				else { continue }
			guard let piece = position.board[startSquare]
				else { continue }
			guard piece == Piece(position.whoseTurn, .Pawn)
				else { continue }
			let endSquare = enPassantableSquare + (0, forward)
			if position.board[endSquare] == nil {
				addMoveIfNoCheck(startSquare, endSquare, .captureEnPassant)
			}
		}
	}
	
	private mutating func addPawnPromotionMoves(from startSquare: Square, to endSquare: Square) {
		if !position.board.blindMoveWouldLeaveKingInCheck(from: startSquare, to: endSquare) {
			addMoveConfirmedValid(startSquare, endSquare, .pawnPromotion(type: .promoteToQueen))
			addMoveConfirmedValid(startSquare, endSquare, .pawnPromotion(type: .promoteToRook))
			addMoveConfirmedValid(startSquare, endSquare, .pawnPromotion(type: .promoteToBishop))
			addMoveConfirmedValid(startSquare, endSquare, .pawnPromotion(type: .promoteToKnight))
		}
	}

	private mutating func addMovesAlongVector(from startSquare: Square, vector: Vector, canRepeat: Bool) {
		assert(vector.dx != 0 || vector.dy != 0, "Piece movement can't have a zero-length vector.")
		var end = startSquare
		while true {
			end = end + vector
			if !Board.isWithinBounds(end) {
				break
			}

			if let piece = position.board[end] {
				if piece.color == position.whoseTurn.opponent {
					// Capturing a piece.
					addMoveIfNoCheck(startSquare, end, .plain)
				}
				break
			} else {
				// Moving to an empty square.
				addMoveIfNoCheck(startSquare, end, .plain)
			}

			if !canRepeat {
				break
			}
		}
	}

	private mutating func addKingSideCastlingIfValid() {
		// The king and rook must not have moved yet.
		guard position.canCastleKingSide
			else { return }
		let kingHomeSquare = Square(x: 4, y: position.whoseTurn.homeRow)
		guard position.board[kingHomeSquare] == Piece(position.whoseTurn, .King)
			else { return }
		guard position.board[7, position.whoseTurn.homeRow] == Piece(position.whoseTurn, .Rook)
			else { return }

		// The squares between the king and the rook must be empty.
		for vector in [(1, 0), (2, 0)] {
			if position.board[kingHomeSquare + vector] != nil {
				return
			}
		}

		// The two squares the king would cross must not put it in check.
		for vector in [(1, 0), (2, 0)] {
			if position.board.blindMoveWouldLeaveKingInCheck(from: kingHomeSquare, to: kingHomeSquare + vector) {
				return
			}
		}

		// If we got this far, the move is valid.
		addMoveConfirmedValid(kingHomeSquare, kingHomeSquare + (2, 0), .castleKingSide)
	}

	private mutating func addQueenSideCastlingIfValid() {
		// The king and rook must not have moved yet.
		guard position.canCastleQueenSide
			else { return }
		let kingHomeSquare = Square(x: 4, y: position.whoseTurn.homeRow)
		guard position.board[kingHomeSquare] == Piece(position.whoseTurn, .King)
			else { return }
		guard position.board[0, position.whoseTurn.homeRow] == Piece(position.whoseTurn, .Rook)
			else { return }

		// The squares between the king and the rook must be empty.
		for vector in [(-1, 0), (-2, 0), (-3, 0)] {
			if position.board[kingHomeSquare + vector] != nil {
				return
			}
		}

		// The two squares the king would cross must not put it in check.
		for vector in [(-1, 0), (-2, 0)] {
			if position.board.blindMoveWouldLeaveKingInCheck(from: kingHomeSquare, to: kingHomeSquare + vector) {
				return
			}
		}

		// If we got this far, the move is valid.
		addMoveConfirmedValid(kingHomeSquare, kingHomeSquare + (-2, 0), .castleQueenSide)
	}

	private mutating func addMoveIfNoCheck(_ startSquare: Square, _ endSquare: Square, _ moveType: MoveType) {
		let move = Move(from: startSquare, to: endSquare, type: moveType)
		if !position.board.moveWouldLeaveKingInCheck(move) {
			addMoveConfirmedValid(startSquare, endSquare, moveType)
		}
	}

	private mutating func addMoveConfirmedValid(_ startSquare: Square, _ endSquare: Square, _ moveType: MoveType) {
		validMoves.add(move: Move(from: startSquare, to: endSquare, type: moveType))
	}

	private func validSquareOrNil(_ sq: Square) -> Square? {
		return Board.isWithinBounds(sq) ? sq : nil
	}
}

