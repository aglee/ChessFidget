//
//  Position.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

/**
Used (along with other logic) to determine whether a player can castle.

The default initializer uses the settings that are in effect at the beginning of a game.
*/
struct CastlingFlags {
	var queensRookDidMove: Bool = false
	var kingsRookDidMove: Bool = false
	var kingDidMove: Bool = false
}

/**
The default initializer uses the settings that are in effect at the beginning of a game.
*/
struct PositionMeta {
	var whoseTurn: PieceColor = .White
	var castlingFlags: [PieceColor : CastlingFlags] = [ .White: CastlingFlags(),
	                                                    .Black: CastlingFlags() ]
	var squareWithTwoSquarePawn: Square? = nil
}

/**
Represents the state of a game, including all information needed to determine whether any proposed move is legal.

The default initializer uses the settings that are in effect at the beginning of a game.
*/
class Position {
	// MARK: - Properties

	var board: Board
	var meta: PositionMeta

	init() {
		board = Board()
		meta = PositionMeta()
	}

	init(board: Board, meta: PositionMeta) {
		self.board = board
		self.meta = meta
	}

	mutating func play(move: Move) {
		let pieceMoved = board[move.fromSquare]!

		// Update the board.
		board[move.toSquare] = board[move.fromSquare]
		board[move.fromSquare] = nil

		// Update the meta.
		if pieceMoved.type == .King {
			meta.castlingFlags[pieceMoved.color]?.kingDidMove = true
		} else if pieceMoved.type == .Rook {
			if move.fromSquare.x == 0 {
				meta.castlingFlags[pieceMoved.color]?.queensRookDidMove = true
			} else if move.fromSquare.x == 7 {
				meta.castlingFlags[pieceMoved.color]?.kingsRookDidMove = true
			}
		}
		switch meta.whoseTurn {
		case .White:
			meta.whoseTurn = .Black
		case .Black:
			meta.whoseTurn = .White
		}
	}
	
}

