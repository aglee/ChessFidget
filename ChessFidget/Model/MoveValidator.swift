//
//  MoveValidator.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/31/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

/// Reasons a proposed move from a given start square to a given end square might be invalid.
enum MoveError: String {
	case startPointMustContainPiece
	case pieceOnstartPointBelongsToWrongPlayer

	case cannotCastleOutOfCheck
	case cannotCastleBecauseKingOrRookHasMoved
	case cannotCastleAcrossOccupiedSquare
	case castlingCannotMoveKingAcrossAttackedSquare

	case cannotLeaveKingInCheck

	case pieceDoesNotMoveThatWay
	case moveIsBlockedByOccupiedSquare
}

enum MoveValidity {
	case valid(type: MoveType)
	case invalid(reason: MoveError)
}

/// Checks the validity of a proposed move from a given start square to a given end square.
struct MoveValidator {
	let position: Position
	let startPoint: GridPointXY
	let endPoint: GridPointXY

	func validateMove() -> MoveValidity {
		let validity = mostlyValidateMove()

		switch validity {
		case .invalid:
			return validity
		case .valid(let moveType):
			// Would the move leave the king in check?
			if position.board.moveWouldLeaveKingInCheck(from: startPoint, to: endPoint, type: moveType) {
				return .invalid(reason: .cannotLeaveKingInCheck)
			} else {
				return validity
			}
		}
	}

	// MARK: - Private methods

	// Checks the validity of the move EXCEPT for whether it would leave the king in check.
	private func mostlyValidateMove() -> MoveValidity {
		// The starting square must contain a piece owned by the current player.
		guard let piece = position.board[startPoint] else {
			return .invalid(reason: .startPointMustContainPiece)
		}
		if piece.color != position.whoseTurn {
			return .invalid(reason: .pieceOnstartPointBelongsToWrongPlayer)
		}
		if position.board[endPoint]?.color == position.whoseTurn {
			return .invalid(reason: .moveIsBlockedByOccupiedSquare)
		}

		// Special case: handle pawn moves completely separately.
		if piece.type == .pawn {
			return validatePawnMove()
		}

		// Special case: the user is attempting to castle.
		if piece.type == .king
			&& startPoint.x == 4
			&& startPoint.y == position.whoseTurn.homeRow
			&& [2, 6].contains(endPoint.x)
			&& endPoint.y == position.whoseTurn.homeRow {

			if position.board.isInCheck(piece.color) {
				return .invalid(reason: .cannotCastleOutOfCheck)
			}

			if endPoint.x == 6 {
				return validateKingSideCastle()
			} else if endPoint.x == 2 {
				return validateQueenSideCastle()
			}
		}

		// In all non-special cases, the piece must satisfy its move vectors.
		if !checkVectors(movement: piece.type.movement) {
			return .invalid(reason: .pieceDoesNotMoveThatWay)
		}

		// If we got this far, the move seems like a valid plain move -- but note again, we have not checked whether it would put the player in check.
		return .valid(type: .plainMove)
	}

	private func validatePawnMove() -> MoveValidity {
		if startPoint.x == endPoint.x {

			// Case 1: the pawn is moving within a file.

			// The destination square must be empty.
			if position.board[endPoint] != nil {
				return .invalid(reason: .moveIsBlockedByOccupiedSquare)
			}

			// One-square advance.
			if endPoint.y == startPoint.y + position.whoseTurn.forwardDirection {
				if endPoint.y == position.whoseTurn.opponent.homeRow {
					return .valid(type: .pawnPromotion(type: .promoteToQueen))
				} else {
					return .valid(type: .plainMove)
				}
			}

			// Two-square advance from the pawn's home square, not blocked by any pieces.
			if startPoint.y == position.whoseTurn.pawnRow
				&& endPoint.y == startPoint.y + (2 * position.whoseTurn.forwardDirection) {
				if position.board[startPoint.x, startPoint.y + position.whoseTurn.forwardDirection] != nil {
					return .invalid(reason: .moveIsBlockedByOccupiedSquare)
				} else {
					return .valid(type: .pawnTwoSquares)
				}
			}
		} else if [-1, 1].contains(startPoint.x - endPoint.x)
			&& startPoint.y + position.whoseTurn.forwardDirection == endPoint.y {

			// Case 2: the pawn is moving diagonally forward one square.  It must be a capture -- either an en passant capture, a capture that leads to pawn promotion, or a plain old capture.

			if let capturedPiece = position.board[endPoint] {
				if capturedPiece.color != position.whoseTurn {
					if endPoint.y == position.whoseTurn.opponent.homeRow {
						return .valid(type: .pawnPromotion(type: .promoteToQueen))
					} else {
						return .valid(type: .plainMove)
					}
				}
			} else if position.board[endPoint] == nil
				&& position.enPassantableGridPoint?.x == endPoint.x
				&& position.enPassantableGridPoint?.y == startPoint.y {
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
		let kingHome = GridPointXY(4, position.whoseTurn.homeRow)
		guard position.board[kingHome] == Piece(position.whoseTurn, .king)
			else { return .invalid(reason: .cannotCastleBecauseKingOrRookHasMoved) }
		guard position.board[7, y] == Piece(position.whoseTurn, .rook)
			else { return .invalid(reason: .cannotCastleBecauseKingOrRookHasMoved) }

		// The squares between the king and the rook must be empty.
		if position.board[5, y] != nil || position.board[6, y] != nil {
			return .invalid(reason: .cannotCastleAcrossOccupiedSquare)
		}

		// The squares the king would cross must not put it in check.
		if position.board.blindMoveWouldLeaveKingInCheck(from: startPoint, to: GridPointXY(startPoint.x + 1, y)) {
			return .invalid(reason: .castlingCannotMoveKingAcrossAttackedSquare)
		}
		if position.board.blindMoveWouldLeaveKingInCheck(from: startPoint, to: GridPointXY(startPoint.x + 2, y)) {
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
		let kingHome = GridPointXY(4, y)
		guard position.board[kingHome] == Piece(position.whoseTurn, .king)
			else { return .invalid(reason: .cannotCastleBecauseKingOrRookHasMoved) }
		guard position.board[0, y] == Piece(position.whoseTurn, .rook)
			else { return .invalid(reason: .cannotCastleBecauseKingOrRookHasMoved) }

		// The squares between the king and the rook must be empty.
		if position.board[1, y] != nil || position.board[2, y] != nil || position.board[3, y] != nil {
			return .invalid(reason: .cannotCastleAcrossOccupiedSquare)
		}

		// The squares the king would cross must not put it in check.
		if position.board.blindMoveWouldLeaveKingInCheck(from: startPoint, to: GridPointXY(startPoint.x - 1, y)) {
			return .invalid(reason: .castlingCannotMoveKingAcrossAttackedSquare)
		}
		if position.board.blindMoveWouldLeaveKingInCheck(from: startPoint, to: GridPointXY(startPoint.x - 2, y)) {
			return .invalid(reason: .castlingCannotMoveKingAcrossAttackedSquare)
		}

		// If we got this far, the move is valid.
		return .valid(type: .castleQueenSide)
	}

	// See if there exists an unobstructed line from the start square to the end square along one of the moving piece's vectors.
	private func checkVectors(movement: PieceMovement) -> Bool {
		for vector in movement.vectors {
			if position.board.pathIsClear(from: startPoint, to: endPoint, vector: vector, canRepeat: movement.canRepeat) {
				return true
			}
		}
		return false
	}
}

