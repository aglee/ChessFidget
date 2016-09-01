//
//  MoveValidator.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/31/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

enum MoveError: String {
	case fromSquareMustContainPiece
	case pieceBelongsToWrongPlayer

	case cannotCastleOutOfCheck
	case cannotCastleBecauseKingOrRookHasMoved
	case cannotCastleAcrossOccupiedSquare
	case castlingCannotMoveKingAcrossAttackedSquare

	case cannotLeaveKingInCheck

	case pieceDoesNotMoveThatWay
	case moveIsBlockedByOccupiedSquare
}

enum MoveType {
	case invalid(reason: MoveError)

	case pawnOneSquare
	case pawnTwoSquares
	case captureEnPassant
	case pawnPromotion(pieceType: PieceType)

	case castleKingSide
	case castleQueenSide

	case plain
}

struct MoveValidator {
	let position: Position
	let fromSquare: Square
	let toSquare: Square

	func validateMove() -> MoveType {
		// The fromSquare must contain a piece owned by the current player.
		guard let piece = position.board[fromSquare] else {
			return .invalid(reason: .fromSquareMustContainPiece)
		}
		if piece.color != position.whoseTurn {
			return .invalid(reason: .pieceBelongsToWrongPlayer)
		}
		if position.board[toSquare]?.color == position.whoseTurn {
			return .invalid(reason: .moveIsBlockedByOccupiedSquare)
		}

		// Special case: handle pawn moves completely separately.
		if piece.type == .Pawn {
			return validatePawnMove()
		}

		// Special case: the user is attempting to castle.
		if piece.type == .King
			&& fromSquare.x == 4
			&& fromSquare.y == position.whoseTurn.homeRow
			&& [2, 6].contains(toSquare.x)
			&& toSquare.y == position.whoseTurn.homeRow {

			if position.board.isInCheck(piece.color) {
				return .invalid(reason: .cannotCastleOutOfCheck)
			}

			if toSquare.x == 6 {
				return validateKingSideCastle()
			} else if toSquare.x == 2 {
				return validateQueenSideCastle()
			}
		}

		// In all non-special cases, the piece must satisfy its move vectors.
		if !checkVectors(movement: piece.type.movement) {
			return .invalid(reason: .pieceDoesNotMoveThatWay)
		}

		// Would the move leave the king in check?
		if moveWouldLeaveKingInCheck() {
			return .invalid(reason: .cannotLeaveKingInCheck)
		}

		// If we got this far, the move is a valid plain move.
		return .plain
	}

	// MARK: - Private functions

	private func validatePawnMove() -> MoveType {
		if fromSquare.x == toSquare.x {

			// Case 1: the pawn is moving within a file.

			// The destination square must be empty.
			if position.board[toSquare] != nil {
				return .invalid(reason: .moveIsBlockedByOccupiedSquare)
			}

			// One-square advance.
			if toSquare.y == fromSquare.y + position.whoseTurn.forwardDirection {
				if toSquare.y == position.whoseTurn.opponent.homeRow {
					return .pawnPromotion(pieceType: .Queen)
				} else {
					return .pawnOneSquare
				}
			}

			// Two-square advance from the pawn's home square, not blocked by any pieces.
			if fromSquare.y == position.whoseTurn.pawnRow
				&& toSquare.y == fromSquare.y + (2 * position.whoseTurn.forwardDirection) {
				if position.board[fromSquare.x, fromSquare.y + position.whoseTurn.forwardDirection] != nil {
					return .invalid(reason: .moveIsBlockedByOccupiedSquare)
				} else {
					return .pawnTwoSquares
				}
			}
		} else if [-1, 1].contains(fromSquare.x - toSquare.x)
			&& fromSquare.y + position.whoseTurn.forwardDirection == toSquare.y {

			// Case 2: the pawn is moving diagonally forward one square (must be a capture).

			if let capturedPiece = position.board[toSquare] {
				if capturedPiece.color != position.whoseTurn {
					// Plain diagonal capture.
					return .plain
				}
			} else if position.board[toSquare] == nil
				&& position.enPassantableSquare?.x == toSquare.x
				&& position.enPassantableSquare?.y == fromSquare.y {
				// Capture en passant.
				return .captureEnPassant
			}
		}

		// If we got this far, the move is invalid.
		return .invalid(reason: .pieceDoesNotMoveThatWay)
	}

	private func validateKingSideCastle() -> MoveType {
		// The king and rook must not have moved yet.
		if !position.castlingFlags.canCastle(position.whoseTurn, .kingSide) {
			return .invalid(reason: .cannotCastleBecauseKingOrRookHasMoved)
		}

		// The squares between the king and the rook must be empty.
		let y = position.whoseTurn.homeRow
		if position.board[5, y] != nil || position.board[6, y] != nil {
			return .invalid(reason: .cannotCastleAcrossOccupiedSquare)
		}

		// The squares the king would cross must not put it in check.
		if moveWouldLeaveKingInCheck(from: fromSquare, to: Square(x: fromSquare.x + 1, y: y)) {
			return .invalid(reason: .castlingCannotMoveKingAcrossAttackedSquare)
		}
		if moveWouldLeaveKingInCheck(from: fromSquare, to: Square(x: fromSquare.x + 2, y: y)) {
			return .invalid(reason: .castlingCannotMoveKingAcrossAttackedSquare)
		}

		// If we got this far, the move is valid.
		return .castleKingSide
	}

	private func validateQueenSideCastle() -> MoveType {
		// The king and rook must not have moved yet.
		if !position.castlingFlags.canCastle(position.whoseTurn, .queenSide) {
			return .invalid(reason: .cannotCastleBecauseKingOrRookHasMoved)
		}

		// The squares between the king and the rook must be empty.
		let y = position.whoseTurn.homeRow
		if position.board[1, y] != nil || position.board[2, y] != nil || position.board[3, y] != nil {
			return .invalid(reason: .cannotCastleAcrossOccupiedSquare)
		}

		// The squares the king would cross must not put it in check.
		if moveWouldLeaveKingInCheck(from: fromSquare, to: Square(x: fromSquare.x - 1, y: y)) {
			return .invalid(reason: .castlingCannotMoveKingAcrossAttackedSquare)
		}
		if moveWouldLeaveKingInCheck(from: fromSquare, to: Square(x: fromSquare.x - 2, y: y)) {
			return .invalid(reason: .castlingCannotMoveKingAcrossAttackedSquare)
		}

		// If we got this far, the move is valid.
		return .castleQueenSide
	}

	// See if there exists an unobstructed line from the fromSquare to the toSquare along one of the moving piece's vectors.
	private func checkVectors(movement: PieceMovement) -> Bool {
		for vector in movement.vectors {
			if position.board.pathIsClear(from: fromSquare, to: toSquare, vector: vector, canRepeat: movement.canRepeat) {
				return true
			}
		}
		return false
	}

	private func moveWouldLeaveKingInCheck(from fromSquare: Square, to toSquare: Square) -> Bool {
		var tempBoard = position.board
		tempBoard.blindlyMove(from: fromSquare, to: toSquare)
		return tempBoard.isInCheck(position.whoseTurn)
	}

	private func moveWouldLeaveKingInCheck() -> Bool {
		return moveWouldLeaveKingInCheck(from: fromSquare, to: toSquare);
	}
}

