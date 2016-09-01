//
//  Validator.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

/**

Stages of move validation:

- **STAGE 1: Sanity-checking the fromSquare.**  Does the fromSquare contain a piece belonging to the player whose turn it is?
- **STAGE 2: Sanity-checking the toSquare.**  Is the toSquare a valid destination, ignoring whether it would violate king-vulnerability rules?
	- Each piece type has:
		- Zero or more "move vectors", which are pairs of the form (deltaX, deltaY).  Only Pawn has zero move vectors.
		- A flag indicating whether the piece can repeat its move vectors (true for Bishop, Rook, Queen; false for Pawn, Knight, King, though moot in the case of Pawn, which has no move vectors).
	- Special cases:
		- If the moving piece is a pawn, ANY of the following must be true:
			- It's a one-square advance into an empty square.
			- It's a two-square advance from the pawn's home square, not blocked by any pieces.
			- It's a capture, meaning ALL of the following are true:
				- The toSquare is one square ahead of fromSquare and one file away in either direction.
				- ANY of the following is true:
					- It's a plain diagonal capture: the toSquare contains a piece belonging to the opponent.
					- It's a capture en passant, meaning ALL the following are true:
						- The position's enPassantableSquare is non-nil.  (Note this implies the toSquare is empty, so we don't have to check that, though we could assert it if we want to be defensive.)
						- The toSquare is one rank ahead of the EP square.
						- The EP square is on the same rank as the fromSquare and one file away in either direction.
				- The toSquare is just ahead of the enPassantableSquare.
		- Castling:
			- It's a king-side castle.
			- It's a queen-side castle.
	- Check move vectors -- passes if ALL of the following are true:
		- The toSquare does not contain a piece belonging to the current player.
		- There is a path from fromSquare to toSquare along one of the piece's move vectors.
		- All squares on that path, excluding toSquare, are empty.
- **STAGE 3: Checking king-vulnerability.**  Would the move violate king-vulnerability rules?
	- The resulting position would not leave the king in check.
	- If it's a castle, ALL of the following must be true:
		- The king is not currently in check.
		- The king would not cross any squares attacked by the opponent.
- **STAGE 4: Specifying piece type for promotion.**

*/
extension Position {
	// "STAGE 1" as described above.
	func canSelect(square: Square) -> Bool {
		if let piece = board[square] {
			return piece.color == whoseTurn
		} else {
			return false
		}
	}

	// "STAGE 2" as described above.
	func canMove(from fromSquare: Square, to toSquare: Square) -> Bool {
		guard let piece = board[fromSquare] else {
			return false
		}
		if piece.color != whoseTurn {
			return false
		}

		// Special case: handle pawns separately from all other pieces.
		if piece.type == .Pawn {
			return canMovePawn(from: fromSquare, to: toSquare)
		}

		// Special case: castling.
		if canCastle(from: fromSquare, to: toSquare) {
			return true
		}

		// In all non-special cases, the piece must satisfy its move vectors.
		return checkVectors(from: fromSquare, to: toSquare)
	}

	// MARK: - Private functions

	private func canMovePawn(from fromSquare: Square, to toSquare: Square) -> Bool {
		// The fromSquare must contain a pawn owned by the current player.
		guard let piece = board[fromSquare] else {
			return false
		}
		if piece.color != whoseTurn || piece.type != .Pawn {
			return false
		}

		// Case 1: the pawn is moving within a file.
		if fromSquare.x == toSquare.x {
			// The destination square must be empty.
			if let _ = board[toSquare] {
				return false
			}

			// One-square advance.
			if toSquare.y == fromSquare.y + piece.color.forwardDirection {
				return true
			}

			// Two-square advance from the pawn's home square, not blocked by any pieces.
			if fromSquare.y == piece.color.pawnRow
				&& toSquare.y == fromSquare.y + (2 * piece.color.forwardDirection)
				&& board[fromSquare.x, fromSquare.y + piece.color.forwardDirection] == nil {
				return true
			}

			return false
		}

		// Case 2: the pawn is moving diagonally forward one square.
		if [-1, 1].contains(fromSquare.x - toSquare.x)
			&& fromSquare.y + piece.color.forwardDirection == toSquare.y {
			if board[toSquare] == nil {
				// Possibly a capture en passant.
				return enPassantableSquare?.x == toSquare.x && enPassantableSquare?.y == fromSquare.y
			} else if board[toSquare]!.color == piece.color.opponent {
				// Plain diagonal capture.
				return true
			}
		}

		// If we got this far, the move is invalid.
		return false
	}

	private func canCastle(from fromSquare: Square, to toSquare: Square) -> Bool {
		// Called by canCastle.  Assumes some checking has already been done.
		func canCastleKingSide(from fromSquare: Square, to toSquare: Square) -> Bool {
			// The king and the king's rook must not have moved yet.
			if castlingFlags().kingDidMove || castlingFlags().kingsRookDidMove {
				return false
			}

			// The king must be moving two squares to the right.
			let y = whoseTurn.homeRow
			if toSquare != Square(x: 6, y: y) {
				return false
			}

			// The squares between the king and the king's rook must be empty.
			if board[5, y] != nil || board[6, y] != nil {
				return false
			}

			// If we got this far, the move passes this test.
			return true
		}

		// Called by canCastle.  Assumes some checking has already been done.
		func canCastleQueenSide(from fromSquare: Square, to toSquare: Square) -> Bool {
			// The king and the queen's rook must not have moved yet.
			if castlingFlags().kingDidMove || castlingFlags().queensRookDidMove {
				return false
			}

			// The king must be moving two squares to the left.
			let y = whoseTurn.homeRow
			if toSquare != Square(x: 2, y: y) {
				return false
			}

			// The squares between the king and the king's rook must be empty.
			if board[1, y] != nil || board[2, y] != nil || board[3, y] != nil {
				return false
			}

			// If we got this far, the move passes this test.
			return true
		}



		// The fromSquare must contain a king owned by the current player.
		guard let piece = board[fromSquare] else {
			return false
		}
		if piece.color != whoseTurn || piece.type != .King {
			return false
		}

		// Not allowed to castle if currently in check.
		if board.isInCheck(piece.color) {
			return false
		}

		// Check the two cases: king-side castling and queen-side castling.
		if canCastleKingSide(from: fromSquare, to: toSquare) {
			return true
		}
		if canCastleQueenSide(from: fromSquare, to: toSquare) {
			return true
		}

		// If we got this far, the move is invalid.
		return false
	}

	private func checkVectors(from fromSquare: Square, to toSquare: Square) -> Bool {
		// The fromSquare must contain a non-pawn piece owned by the current player.
		guard let piece = board[fromSquare] else {
			return false
		}
		if piece.color != whoseTurn {
			return false
		}
		if piece.type == .Pawn {
			return false
		}

		// The toSquare must not contain a piece owned by the current player.
		if board[toSquare]?.color == whoseTurn {
			return false
		}

		// See if there exists an unobstructed line from the fromSquare to the toSquare along one of the moving piece's vectors.
		for vector in piece.type.movement.vectors {
			if board.pathIsClear(from: fromSquare, to: toSquare, vector: vector, canRepeat: piece.type.movement.canRepeat) {
				return true
			}
		}

		// If we got this far, the move is invalid.
		return false
	}

	private func moveWouldPutKingInCheck(from fromSquare: Square, to toSquare: Square) -> Bool {
		return false
	}
}

