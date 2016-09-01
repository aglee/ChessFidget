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

	// Assumes the move is valid for the current player and current board and is correctly described by the moveType.
	mutating func move(from fromSquare: Square, to toSquare: Square, moveType: MoveType) {
		// In all cases we move the piece that's at fromSquare to toSquare.
		board.blindlyMove(from: fromSquare, to: toSquare)

		// Do additional moving/removing/replacing as needed for special cases.
		switch moveType {
		case .captureEnPassant:
			// Remove the pawn being captured.
			board[fromSquare.x, toSquare.y] = nil

		case .pawnPromotion(let promotionType):
			// Replace the pawn with the piece it's being promoted to.
			board[toSquare] = Piece(whoseTurn, promotionType)

		case .castleKingSide:
			// Move the king's rook.
			board.blindlyMove(from: Square(x: 7, y: whoseTurn.homeRow),
			                  to: Square(x: 5, y: whoseTurn.homeRow))

		case .castleQueenSide:
			// Move the queen's rook.
			board.blindlyMove(from: Square(x: 0, y: whoseTurn.homeRow),
			                  to: Square(x: 3, y: whoseTurn.homeRow))

		default: break
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

