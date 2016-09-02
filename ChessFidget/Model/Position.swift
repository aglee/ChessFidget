//
//  Position.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

/**
Represents the state of a game, including all information needed to determine whether any proposed move is legal.

The default initializer uses the settings that are in effect at the beginning of a game.
*/
struct Position {
	var board = Board()
	var whoseTurn = PieceColor.White
	var enPassantableSquare: Square? = nil
	var castlingFlags = CastlingFlags()
	var canCastleKingSide: Bool {
		get {
			return castlingFlags.canCastle(whoseTurn, .kingSide)
		}
	}
	var canCastleQueenSide: Bool {
		get {
			return castlingFlags.canCastle(whoseTurn, .queenSide)
		}
	}

	// Assumes the move is valid for the current player and current board and is correctly described by the moveType.
	mutating func move(from fromSquare: Square, to toSquare: Square, moveType: MoveType) {
		// Update the board.
		board.move(from: fromSquare, to: toSquare, moveType: moveType)

		// Update en passant info.
		if case .pawnTwoSquares = moveType {
			enPassantableSquare = toSquare
		} else {
			enPassantableSquare = nil
		}

		// Update castling flags.
		if fromSquare.y == whoseTurn.homeRow {
			if fromSquare.x == 0 {
				castlingFlags.disableCastling(whoseTurn, .queenSide)
			} else if fromSquare.x == 4 {
				castlingFlags.disableCastling(whoseTurn)
			} else if fromSquare.x == 7 {
				castlingFlags.disableCastling(whoseTurn, .kingSide)
			}
		}

		// It's the other player's turn now.
		whoseTurn = whoseTurn.opponent
	}
}

