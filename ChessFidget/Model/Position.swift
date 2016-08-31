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
class CastlingFlags {
	var queensRookDidMove: Bool = false
	var kingsRookDidMove: Bool = false
	var kingDidMove: Bool = false
}

/**
Represents the state of a game, including all information needed to determine whether any proposed move is legal.

The default initializer uses the settings that are in effect at the beginning of a game.
*/
class Position {
	var board = Board()
	var whoseTurn: PieceColor = .White
	let whiteCastlingFlags = CastlingFlags()
	let blackCastlingFlags = CastlingFlags()
	var enPassantableSquare: Square? = nil

	init(newGame: Bool = true) {
		if newGame {
			placePiecesForNewGame()
		}
	}

	func castlingFlags(_ color: PieceColor) -> CastlingFlags {
		switch color {
		case .White: return whiteCastlingFlags
		case .Black: return blackCastlingFlags
		}
	}

	func castlingFlags() -> CastlingFlags {
		return castlingFlags(whoseTurn)
	}

	func setUpNewGame() {
		board = Board()
		placePiecesForNewGame()
	}

	// Assumes the move is valid.
	func move(from fromSquare: Square, to toSquare: Square, promotion: PieceType? = nil) {
		// Update the pieces on the board.
		guard let piece = board[fromSquare] else {
			return
		}
		board[toSquare] = (promotion == nil ? piece : Piece(piece.color, promotion!))
		board[fromSquare] = nil

		// Update meta-info.
		enPassantableSquare = nil
		if piece.type == .Pawn {
			if toSquare.y == fromSquare.y + (2 * piece.color.forwardDirection) {
				enPassantableSquare = toSquare
			}
		} else if piece.type == .King {
			castlingFlags(piece.color).kingDidMove = true

			let y = piece.color.homeRow
			if fromSquare == Square(x: 4, y: y) {
				if toSquare == Square(x: 6, y: y) {
					// King-side castling.
					board[5, y] = board[7, y]
					board[7, y] = nil
				} else if toSquare == Square(x: 2, y: y) {
					// Queen-side castling.
					board[3, y] = board[0, y]
					board[0, y] = nil
				}
			}
		} else if piece.type == .Rook {
			if fromSquare.x == 0 {
				castlingFlags(piece.color).queensRookDidMove = true
			} else if fromSquare.x == 7 {
				castlingFlags(piece.color).kingsRookDidMove = true
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

		let pieceTypes: [PieceType] = [.Rook, .Knight, .Bishop, .Queen, .King, .Bishop, .Knight, .Rook]
		for (x, pieceType) in pieceTypes.enumerated() {
			board[x, 0] = Piece(.White, pieceType)
			board[x, 7] = Piece(.Black, pieceType)
		}
	}
}

