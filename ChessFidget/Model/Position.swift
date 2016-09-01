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

	var whiteCanStillCastleKingSide = true
	var whiteCanStillCastleQueenSide = true
	var blackCanStillCastleKingSide = true
	var blackCanStillCastleQueenSide = true

	var canStillCastleKingSide: Bool {
		get {
			switch whoseTurn {
			case .White: return whiteCanStillCastleKingSide
			case .Black: return blackCanStillCastleKingSide
			}
		}
	}

	var canStillCastleQueenSide: Bool {
		get {
			switch whoseTurn {
			case .White: return whiteCanStillCastleQueenSide
			case .Black: return blackCanStillCastleQueenSide
			}
		}
	}

	// Assumes the move is valid.
	mutating func move(from fromSquare: Square, to toSquare: Square, promotion: PieceType? = nil) {
		// Update the pieces on the board.
		guard let piece = board[fromSquare] else {
			return
		}

		// Handle special cases.
		enPassantableSquare = nil
		if piece.type == .Pawn {
			if toSquare.y == fromSquare.y + (2 * piece.color.forwardDirection) {
				enPassantableSquare = toSquare
			} else if toSquare.x != fromSquare.x && board[toSquare] == nil {
				// This is a capture en passant.
				board[toSquare.x, fromSquare.y] = nil
			}
		} else if piece.type == .King {
			switch piece.color {
			case .White:
				whiteCanStillCastleKingSide = false
				whiteCanStillCastleQueenSide = false
			case .Black:
				blackCanStillCastleKingSide = false
				blackCanStillCastleQueenSide = false
			}

			let y = piece.color.homeRow
			if fromSquare == Square(x: 4, y: y) {
				if toSquare == Square(x: 6, y: y) {
					// This is king-side castling.
					board[5, y] = board[7, y]
					board[7, y] = nil
				} else if toSquare == Square(x: 2, y: y) {
					// This is queen-side castling.
					board[3, y] = board[0, y]
					board[0, y] = nil
				}
			}
		} else if piece.type == .Rook {
			if fromSquare.x == 0 {
				switch piece.color {
				case .White: whiteCanStillCastleQueenSide = false
				case .Black: blackCanStillCastleQueenSide = false
				}
			} else if fromSquare.x == 7 {
				switch piece.color {
				case .White: whiteCanStillCastleKingSide = false
				case .Black: blackCanStillCastleKingSide = false
				}
			}
		}

		// Move the main piece.  We do this *after* the above because this allows us to check for the case of an en passant capture by seeing if toSquare is empty.
		board[toSquare] = (promotion == nil ? piece : Piece(piece.color, promotion!))
		board[fromSquare] = nil
		whoseTurn = whoseTurn.opponent
	}
}

