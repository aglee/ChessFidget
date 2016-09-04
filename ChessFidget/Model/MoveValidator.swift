//
//  MoveValidator.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/31/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

struct MoveValidator {
	let position: Position
	let startSquare: Square
	let endSquare: Square

	func validateMove() -> MoveValidity {
		let validity = mostlyValidateMove()

		switch validity {
		case .invalid:
			return validity
		case .valid(let moveType):
			// Would the move leave the king in check?
			let move = Move(from: startSquare, to: endSquare, type: moveType)
			if position.board.moveWouldLeaveKingInCheck(move) {
				return .invalid(reason: .cannotLeaveKingInCheck)
			} else {
				return validity
			}
		}
	}

	// MARK: - Private methods

	private func mostlyValidateMove() -> MoveValidity {
		// The starting square must contain a piece owned by the current player.
		guard let piece = position.board[startSquare] else {
			return .invalid(reason: .startSquareMustContainPiece)
		}
		if piece.color != position.whoseTurn {
			return .invalid(reason: .pieceBelongsToWrongPlayer)
		}
		if position.board[endSquare]?.color == position.whoseTurn {
			return .invalid(reason: .moveIsBlockedByOccupiedSquare)
		}

		// Special case: handle pawn moves completely separately.
		if piece.type == .Pawn {
			return validatePawnMove()
		}

		// Special case: the user is attempting to castle.
		if piece.type == .King
			&& startSquare.x == 4
			&& startSquare.y == position.whoseTurn.homeRow
			&& [2, 6].contains(endSquare.x)
			&& endSquare.y == position.whoseTurn.homeRow {

			if position.board.isInCheck(piece.color) {
				return .invalid(reason: .cannotCastleOutOfCheck)
			}

			if endSquare.x == 6 {
				return validateKingSideCastle()
			} else if endSquare.x == 2 {
				return validateQueenSideCastle()
			}
		}

		// In all non-special cases, the piece must satisfy its move vectors.
		if !checkVectors(movement: piece.type.movement) {
			return .invalid(reason: .pieceDoesNotMoveThatWay)
		}

		// If we got this far, the move seems like a valid plain move -- but note again, we have not checked whether it would put the player in check.
		return .valid(type: .plain)
	}

	private func validatePawnMove() -> MoveValidity {
		if startSquare.x == endSquare.x {

			// Case 1: the pawn is moving within a file.

			// The destination square must be empty.
			if position.board[endSquare] != nil {
				return .invalid(reason: .moveIsBlockedByOccupiedSquare)
			}

			// One-square advance.
			if endSquare.y == startSquare.y + position.whoseTurn.forwardDirection {
				if endSquare.y == position.whoseTurn.opponent.homeRow {
					return .valid(type: .pawnPromotion(type: .promoteToQueen))
				} else {
					return .valid(type: .plain)
				}
			}

			// Two-square advance from the pawn's home square, not blocked by any pieces.
			if startSquare.y == position.whoseTurn.pawnRow
				&& endSquare.y == startSquare.y + (2 * position.whoseTurn.forwardDirection) {
				if position.board[startSquare.x, startSquare.y + position.whoseTurn.forwardDirection] != nil {
					return .invalid(reason: .moveIsBlockedByOccupiedSquare)
				} else {
					return .valid(type: .pawnTwoSquares)
				}
			}
		} else if [-1, 1].contains(startSquare.x - endSquare.x)
			&& startSquare.y + position.whoseTurn.forwardDirection == endSquare.y {

			// Case 2: the pawn is moving diagonally forward one square (must be a capture).

			if let capturedPiece = position.board[endSquare] {
				if capturedPiece.color != position.whoseTurn {
					// Plain diagonal capture.
					return .valid(type: .plain)
				}
			} else if position.board[endSquare] == nil
				&& position.enPassantableSquare?.x == endSquare.x
				&& position.enPassantableSquare?.y == startSquare.y {
				// Capture en passant.
				return .valid(type: .captureEnPassant)
			}
		}

		// If we got this far, the move is invalid.
		return .invalid(reason: .pieceDoesNotMoveThatWay)
	}

	private func validateKingSideCastle() -> MoveValidity {
		// The king and rook must not have moved yet.
		guard position.canCastleKingSide
			else { return .invalid(reason: .cannotCastleBecauseKingOrRookHasMoved) }

		let y = position.whoseTurn.homeRow
		let kingHomeSquare = Square(x: 4, y: position.whoseTurn.homeRow)
		guard position.board[kingHomeSquare] == Piece(position.whoseTurn, .King)
			else { return .invalid(reason: .cannotCastleBecauseKingOrRookHasMoved) }
		guard position.board[7, y] == Piece(position.whoseTurn, .Rook)
			else { return .invalid(reason: .cannotCastleBecauseKingOrRookHasMoved) }

		// The squares between the king and the rook must be empty.
		if position.board[5, y] != nil || position.board[6, y] != nil {
			return .invalid(reason: .cannotCastleAcrossOccupiedSquare)
		}

		// The squares the king would cross must not put it in check.
		if position.board.blindMoveWouldLeaveKingInCheck(from: startSquare, to: Square(x: startSquare.x + 1, y: y)) {
			return .invalid(reason: .castlingCannotMoveKingAcrossAttackedSquare)
		}
		if position.board.blindMoveWouldLeaveKingInCheck(from: startSquare, to: Square(x: startSquare.x + 2, y: y)) {
			return .invalid(reason: .castlingCannotMoveKingAcrossAttackedSquare)
		}

		// If we got this far, the move is valid.
		return .valid(type: .castleKingSide)
	}

	private func validateQueenSideCastle() -> MoveValidity {
		// The king and rook must not have moved yet.
		guard position.canCastleQueenSide
			else { return .invalid(reason: .cannotCastleBecauseKingOrRookHasMoved) }

		let y = position.whoseTurn.homeRow
		let kingHomeSquare = Square(x: 4, y: y)
		guard position.board[kingHomeSquare] == Piece(position.whoseTurn, .King)
			else { return .invalid(reason: .cannotCastleBecauseKingOrRookHasMoved) }
		guard position.board[0, y] == Piece(position.whoseTurn, .Rook)
			else { return .invalid(reason: .cannotCastleBecauseKingOrRookHasMoved) }

		// The squares between the king and the rook must be empty.
		if position.board[1, y] != nil || position.board[2, y] != nil || position.board[3, y] != nil {
			return .invalid(reason: .cannotCastleAcrossOccupiedSquare)
		}

		// The squares the king would cross must not put it in check.
		if position.board.blindMoveWouldLeaveKingInCheck(from: startSquare, to: Square(x: startSquare.x - 1, y: y)) {
			return .invalid(reason: .castlingCannotMoveKingAcrossAttackedSquare)
		}
		if position.board.blindMoveWouldLeaveKingInCheck(from: startSquare, to: Square(x: startSquare.x - 2, y: y)) {
			return .invalid(reason: .castlingCannotMoveKingAcrossAttackedSquare)
		}

		// If we got this far, the move is valid.
		return .valid(type: .castleQueenSide)
	}

	// See if there exists an unobstructed line from the starting square to the ending square along one of the moving piece's vectors.
	private func checkVectors(movement: PieceMovement) -> Bool {
		for vector in movement.vectors {
			if position.board.pathIsClear(from: startSquare, to: endSquare, vector: vector, canRepeat: movement.canRepeat) {
				return true
			}
		}
		return false
	}
}

