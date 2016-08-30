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
Represents the state of a game, including all information needed to determine whether any proposed move is legal.

The default initializer uses the settings that are in effect at the beginning of a game.
*/
class Position {
	var board = Grid64<Piece?>(value: nil)
	var whoseTurn: PieceColor = .White
	var castlingFlags: [PieceColor : CastlingFlags] = [ .White: CastlingFlags(),
	                                                    .Black: CastlingFlags() ]
	var enPassantableSquare: Square? = nil

	init(newGame: Bool = true) {
		if newGame {
			placePiecesForNewGame()
		}
	}

	func setUpNewGame() {
		board.fill(value: nil)
		placePiecesForNewGame()
	}

	func play(move: Move) {
		let pieceMoved = board[move.fromSquare]!

		// Update the board.
		board[move.toSquare] = board[move.fromSquare]
		board[move.fromSquare] = nil

		// Update meta-info.
		if pieceMoved.type == .King {
			castlingFlags[pieceMoved.color]?.kingDidMove = true
		} else if pieceMoved.type == .Rook {
			if move.fromSquare.x == 0 {
				castlingFlags[pieceMoved.color]?.queensRookDidMove = true
			} else if move.fromSquare.x == 7 {
				castlingFlags[pieceMoved.color]?.kingsRookDidMove = true
			}
		}
		whoseTurn = whoseTurn.opponent
	}

	// MARK: - Private functions

	// Assumes the board is empty.
	private func placePiecesForNewGame() {
		for x in 0...7 {
			board[x, 1] = Piece(.White, .Pawn)
			board[x, 6] = Piece(.Black, .Pawn)
		}

		let types: [PieceType] = [.Rook, .Knight, .Bishop, .Queen, .King, .Bishop, .Knight, .Rook]
		for (index, pieceType) in types.enumerated() {
			board[index, 0] = Piece(.White, pieceType)
			board[index, 7] = Piece(.Black, pieceType)
		}
	}
}

