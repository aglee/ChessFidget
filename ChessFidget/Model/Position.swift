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
	var enPassantableGridPoint: GridPointXY? = nil
	var castlingFlags = CastlingFlags()

	var canCastleKingSide: Bool {
		return castlingFlags.canCastle(whoseTurn, .kingSide)
	}

	var canCastleQueenSide: Bool {
		return castlingFlags.canCastle(whoseTurn, .queenSide)
	}

	var validMoves: [Move] {
		return MoveGenerator(position: self).allValidMoves
	}

	mutating func makeMove(_ move: Move) {
		makeMove(from: move.start, to: move.end, type: move.type)
	}

	// Assumes the move is valid for the current player and current board and is correctly described by the moveType.
	mutating func makeMove(from startPoint: GridPointXY, to endPoint: GridPointXY, type moveType: MoveType) {
		// Update the board.
		board.makeMove(from: startPoint, to: endPoint, type: moveType)

		// Update en passant info.
		if case .pawnTwoSquares = moveType {
			enPassantableGridPoint = endPoint
		} else {
			enPassantableGridPoint = nil
		}

		// Update castling flags.
		if startPoint.y == whoseTurn.homeRow {
			if startPoint.x == 0 {
				castlingFlags.disableCastling(whoseTurn, .queenSide)
			} else if startPoint.x == 4 {
				castlingFlags.disableCastling(whoseTurn)
			} else if startPoint.x == 7 {
				castlingFlags.disableCastling(whoseTurn, .kingSide)
			}
		}

		// It's the other player's turn now.
		whoseTurn = whoseTurn.opponent
	}
}

