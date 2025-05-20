//
//  MoveGenerator.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

/// Calculates all valid moves from a given position.
struct MoveGenerator {
	let position: Position

	var allValidMoves: [Move] = []

	init(position: Position) {
		self.position = position
		addValidMoves()
	}

	// MARK: - Private methods

	// Finds all valid moves and add them to the allValidMoves array.
	private mutating func addValidMoves() {
		// Scan the board for pieces owned by the current player.
		for x in 0...7 {
			for y in 0...7 {
				addValidMovesWithStartPoint(GridPointXY(x, y))
			}
		}

		// Look for special-case moves.
		addEnPassantCaptures()
		if !position.board.isInCheck(position.whoseTurn) {
			addKingSideCastlingIfValid()
			addQueenSideCastlingIfValid()
		}
	}

	private mutating func addValidMovesWithStartPoint(_ startPoint: GridPointXY) {
		guard let piece = position.board[startPoint] else { return }
		guard piece.color == position.whoseTurn else { return }

		if piece.type == .pawn {
			addPawnForwardMoves(from: startPoint)
			addRegularPawnCaptures(from: startPoint)
		} else {
			for vector in piece.type.movement.vectors {
				addNonPawnMovesAlongVector(from: startPoint, vector: vector, canRepeat: piece.type.movement.canRepeat)
			}
		}
	}

	private mutating func addPawnForwardMoves(from startPoint: GridPointXY) {
		let forward = position.whoseTurn.forwardDirection

		// Can the pawn move one square forward?
		let oneSquareForward = startPoint + (0, forward)
		guard Board.isWithinBounds(oneSquareForward) && position.board[oneSquareForward] == nil
			else { return }
		if oneSquareForward.y == position.whoseTurn.queeningRow {
			addPawnPromotionMoves(from: startPoint, to: oneSquareForward)
		} else {
			addMoveIfNoCheck(startPoint, oneSquareForward, .plainMove)
		}

		// Can the pawn move two squares forward?
		if startPoint.y == position.whoseTurn.homeRowForPawns {
			let twoSquaresForward = oneSquareForward + (0, forward)
			if Board.isWithinBounds(twoSquaresForward) && position.board[twoSquaresForward] == nil {
				addMoveIfNoCheck(startPoint, twoSquaresForward, .pawnTwoSquares)
			}
		}
	}

	private mutating func addRegularPawnCaptures(from startPoint: GridPointXY) {
		let forward = position.whoseTurn.forwardDirection
		for dx in [-1, 1] {
			guard let endPoint = validGridPointOrNil(startPoint + (dx, forward))
				else { continue }
			guard position.board[endPoint]?.color == position.whoseTurn.opponent
				else { continue }
			if endPoint.y == position.whoseTurn.queeningRow {
				addPawnPromotionMoves(from: startPoint, to: endPoint)
			} else {
				addMoveIfNoCheck(startPoint, endPoint, .plainMove)
			}
		}
	}

	private mutating func addEnPassantCaptures() {
		guard let enPassantableGridPoint = position.enPassantableGridPoint
			else { return }

		let forward = position.whoseTurn.forwardDirection
		for dx in [-1, 1] {
			guard let startPoint = validGridPointOrNil(enPassantableGridPoint + (dx, 0))
				else { continue }
			guard let piece = position.board[startPoint]
				else { continue }
			guard piece == Piece(position.whoseTurn, .pawn)
				else { continue }
			let endPoint = enPassantableGridPoint + (0, forward)
			if position.board[endPoint] == nil {
				addMoveIfNoCheck(startPoint, endPoint, .captureEnPassant)
			}
		}
	}
	
	private mutating func addPawnPromotionMoves(from startPoint: GridPointXY, to endPoint: GridPointXY) {
		if !position.board.blindMoveWouldLeaveKingInCheck(from: startPoint, to: endPoint) {
			addConfirmedValidMove(startPoint, endPoint, .pawnPromotion(type: .promoteToQueen))
			addConfirmedValidMove(startPoint, endPoint, .pawnPromotion(type: .promoteToRook))
			addConfirmedValidMove(startPoint, endPoint, .pawnPromotion(type: .promoteToBishop))
			addConfirmedValidMove(startPoint, endPoint, .pawnPromotion(type: .promoteToKnight))
		}
	}

	private mutating func addNonPawnMovesAlongVector(from startPoint: GridPointXY, vector: VectorXY, canRepeat: Bool) {
		assert(vector.dx != 0 || vector.dy != 0, "Piece movement can't have a zero-length vector.")
		var endPoint = startPoint
		while true {
			endPoint = endPoint + vector
			if !Board.isWithinBounds(endPoint) {
				break
			}

			if let piece = position.board[endPoint] {
				if piece.color == position.whoseTurn.opponent {
					// Capturing a piece.
					addMoveIfNoCheck(startPoint, endPoint, .plainMove)
				}
				break
			} else {
				// Moving to an empty square.
				addMoveIfNoCheck(startPoint, endPoint, .plainMove)
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
		let kingHome = GridPointXY(4, position.whoseTurn.homeRow)
		guard position.board[kingHome] == Piece(position.whoseTurn, .king)
			else { return }
		guard position.board[7, position.whoseTurn.homeRow] == Piece(position.whoseTurn, .rook)
			else { return }

		// The squares between the king and the rook must be empty.
		for vector in [(1, 0), (2, 0)] {
			if position.board[kingHome + vector] != nil {
				return
			}
		}

		// The two squares the king would cross must not put it in check.
		for vector in [(1, 0), (2, 0)] {
			if position.board.blindMoveWouldLeaveKingInCheck(from: kingHome, to: kingHome + vector) {
				return
			}
		}

		// If we got this far, the move is valid.
		addConfirmedValidMove(kingHome, kingHome + (2, 0), .castleKingSide)
	}

	private mutating func addQueenSideCastlingIfValid() {
		// The king and rook must not have moved yet.
		guard position.canCastleQueenSide
			else { return }
		let kingHome = GridPointXY(4, position.whoseTurn.homeRow)
		guard position.board[kingHome] == Piece(position.whoseTurn, .king)
			else { return }
		guard position.board[0, position.whoseTurn.homeRow] == Piece(position.whoseTurn, .rook)
			else { return }

		// The squares between the king and the rook must be empty.
		for vector in [(-1, 0), (-2, 0), (-3, 0)] {
			if position.board[kingHome + vector] != nil {
				return
			}
		}

		// The two squares the king would cross must not put it in check.
		for vector in [(-1, 0), (-2, 0)] {
			if position.board.blindMoveWouldLeaveKingInCheck(from: kingHome, to: kingHome + vector) {
				return
			}
		}

		// If we got this far, the move is valid.
		addConfirmedValidMove(kingHome, kingHome + (-2, 0), .castleQueenSide)
	}

	private mutating func addMoveIfNoCheck(_ startPoint: GridPointXY, _ endPoint: GridPointXY, _ moveType: MoveType) {
		if !position.board.moveWouldLeaveKingInCheck(from: startPoint, to: endPoint, type: moveType) {
			addConfirmedValidMove(startPoint, endPoint, moveType)
		}
	}

	private mutating func addConfirmedValidMove(_ startPoint: GridPointXY, _ endPoint: GridPointXY, _ moveType: MoveType) {
		allValidMoves.append(Move(from: startPoint, to: endPoint, type: moveType))
	}

	private func validGridPointOrNil(_ gridPoint: GridPointXY) -> GridPointXY? {
		return Board.isWithinBounds(gridPoint) ? gridPoint : nil
	}
}

