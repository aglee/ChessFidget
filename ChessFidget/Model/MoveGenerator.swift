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
		let fromSquare = Square(x: x, y: y)
		guard let piece = position.board[fromSquare]
			else { return }
		guard piece.color == position.whoseTurn
			else { return }

		if piece.type == .Pawn {
			addPawnForwardMoves(from: fromSquare)
			addRegularPawnCaptures(from: fromSquare)
		} else {
			for vector in piece.type.movement.vectors {
				addMovesAlongVector(from: fromSquare, vector: vector, canRepeat: piece.type.movement.canRepeat)
			}
		}
	}

	private mutating func addPawnForwardMoves(from fromSquare: Square) {
		let forward = position.whoseTurn.forwardDirection

		// Can the pawn move one square forward?
		let oneSquareForward = fromSquare + (0, forward)
		guard position.board[oneSquareForward] == nil
			else { return }
		if oneSquareForward.y == position.whoseTurn.opponent.homeRow {
			addPawnPromotionMoves(from: fromSquare, to: oneSquareForward)
		} else {
			addMoveIfNoCheck(fromSquare, oneSquareForward, .pawnOneSquare)
		}

		// Can the pawn move two squares forward?
		if fromSquare.y == position.whoseTurn.pawnRow {
			let twoSquaresForward = oneSquareForward + (0, forward)
			if position.board[twoSquaresForward] == nil {
				addMoveIfNoCheck(fromSquare, twoSquaresForward, .pawnTwoSquares)
			}
		}
	}

	private mutating func addRegularPawnCaptures(from fromSquare: Square) {
		let forward = position.whoseTurn.forwardDirection
		for dx in [-1, 1] {
			guard let toSquare = validSquareOrNil(fromSquare + (dx, forward))
				else { continue }
			guard position.board[toSquare]?.color == position.whoseTurn.opponent
				else { continue }
			if toSquare.y == position.whoseTurn.opponent.homeRow {
				addPawnPromotionMoves(from: fromSquare, to: toSquare)
			} else {
				addMoveIfNoCheck(fromSquare, toSquare, .plain)
			}
		}
	}

	private mutating func addEnPassantCaptures() {
		guard let enPassantableSquare = position.enPassantableSquare
			else { return }

		let forward = position.whoseTurn.forwardDirection
		for dx in [-1, 1] {
			guard let fromSquare = validSquareOrNil(enPassantableSquare + (dx, 0))
				else { continue }
			guard let piece = position.board[fromSquare]
				else { continue }
			guard piece == Piece(position.whoseTurn, .Pawn)
				else { continue }
			let toSquare = enPassantableSquare + (0, forward)
			if position.board[toSquare] == nil {
				addMoveIfNoCheck(fromSquare, toSquare, .captureEnPassant)
			}
		}
	}
	
	private mutating func addPawnPromotionMoves(from fromSquare: Square, to toSquare: Square) {
		if !blindMoveWouldLeaveKingInCheck(from: fromSquare, to: toSquare) {
			addMoveConfirmedValid(fromSquare, toSquare, .pawnPromotion(pieceType: .Queen))
			addMoveConfirmedValid(fromSquare, toSquare, .pawnPromotion(pieceType: .Rook))
			addMoveConfirmedValid(fromSquare, toSquare, .pawnPromotion(pieceType: .Bishop))
			addMoveConfirmedValid(fromSquare, toSquare, .pawnPromotion(pieceType: .Knight))
		}
	}

	private mutating func addMovesAlongVector(from fromSquare: Square, vector: Vector, canRepeat: Bool) {
		assert(vector.dx != 0 || vector.dy != 0, "Piece movement can't have a zero-length vector.")
		var toSquare = fromSquare
		while true {
			toSquare = toSquare + vector
			if !Board.isWithinBounds(toSquare) {
				break
			}

			if let piece = position.board[toSquare] {
				if piece.color == position.whoseTurn.opponent {
					// Capturing a piece.
					addMoveIfNoCheck(fromSquare, toSquare, .plain)
				}
				break
			} else {
				// Moving to an empty square.
				addMoveIfNoCheck(fromSquare, toSquare, .plain)
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
			if blindMoveWouldLeaveKingInCheck(from: kingHomeSquare, to: kingHomeSquare + vector) {
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
			if blindMoveWouldLeaveKingInCheck(from: kingHomeSquare, to: kingHomeSquare + vector) {
				return
			}
		}

		// If we got this far, the move is valid.
		addMoveConfirmedValid(kingHomeSquare, kingHomeSquare + (-2, 0), .castleQueenSide)
	}

	private mutating func addMoveIfNoCheck(_ fromSquare: Square, _ toSquare: Square, _ moveType: MoveType) {
		if !moveWouldLeaveKingInCheck(from: fromSquare, to: toSquare, moveType: moveType) {
			addMoveConfirmedValid(fromSquare, toSquare, moveType)
		}
	}

	private mutating func addMoveConfirmedValid(_ fromSquare: Square, _ toSquare: Square, _ moveType: MoveType) {
		validMoves.add(move: Move(from: fromSquare, to: toSquare, moveType: moveType))
	}

	private func validSquareOrNil(_ sq: Square) -> Square? {
		return Board.isWithinBounds(sq) ? sq : nil
	}

	private func blindMoveWouldLeaveKingInCheck(from fromSquare: Square, to toSquare: Square) -> Bool {
		var tempBoard = position.board
		tempBoard.blindlyMove(from: fromSquare, to: toSquare)
		return tempBoard.isInCheck(position.whoseTurn)
	}

	private func moveWouldLeaveKingInCheck(from fromSquare: Square, to toSquare: Square, moveType: MoveType) -> Bool {
		var tempBoard = position.board
		tempBoard.makeMove(from: fromSquare, to: toSquare, moveType: moveType)
		return tempBoard.isInCheck(position.whoseTurn)
	}
}

