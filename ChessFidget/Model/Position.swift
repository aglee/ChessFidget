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
class Position: Grid64<Piece?> {
	var meta: PositionMeta

	init(newGame: Bool = true) {
		meta = PositionMeta()
		super.init(value: nil)

		if newGame {
			placePiecesForNewGame()
		}
	}

	func setUpNewGame() {
		fill(value: nil)
		placePiecesForNewGame()
	}

	func play(move: Move) {
		let pieceMoved = self[move.fromSquare]!

		// Update the board.
		self[move.toSquare] = self[move.fromSquare]
		self[move.fromSquare] = nil

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

	// MARK: - Private functions

	// Assumes the board is empty.
	private func placePiecesForNewGame() {
		for x in 0...7 {
			self[x, 1] = Piece(.White, .Pawn)
			self[x, 6] = Piece(.Black, .Pawn)
		}

		let types: [PieceType] = [.Rook, .Knight, .Bishop, .Queen, .King, .Bishop, .Knight, .Rook]
		for (index, pieceType) in types.enumerated() {
			self[index, 0] = Piece(.White, pieceType)
			self[index, 7] = Piece(.Black, pieceType)
		}
	}
}

extension Position {
	// MARK: - Calculating which squares are under attack.

	func squaresAttacked(by attackingColor: PieceColor) -> BoardMask {
		let mask = BoardMask()
		self.forAllSquares { (square: Square) in
			if self[square]?.color == attackingColor {
				markAttackedSquares(mask: mask, attackingSquare: square)
			}
		}
		return mask
	}

	// MARK: - Private functions

	// Modifies mask to contain true for all squares attacked by attackingSquare.  "Attacked by" in the sense of "the enemy King is not allowed to move there".
	private func markAttackedSquares(mask: BoardMask, attackingSquare: Square) {
		guard let attackingPiece = self[attackingSquare] else {
			return
		}

		switch attackingPiece.type {
		case .Pawn: self.markSquaresAttackedByPawn(mask: mask, attackingSquare: attackingSquare)
		case .Knight: self.markSquaresAttackedByPawn(mask: mask, attackingSquare: attackingSquare)
		case .Bishop: self.markSquaresAttackedByPawn(mask: mask, attackingSquare: attackingSquare)
		case .Rook: self.markSquaresAttackedByPawn(mask: mask, attackingSquare: attackingSquare)
		case .Queen: self.markSquaresAttackedByPawn(mask: mask, attackingSquare: attackingSquare)
		case .King: self.markSquaresAttackedByPawn(mask: mask, attackingSquare: attackingSquare)
		}
	}

	private func markSquaresAttackedByPawn(mask: BoardMask, attackingSquare: Square) {
	}

	private func markSquaresAttackedByKnight(mask: BoardMask, attackingSquare: Square) {
	}

	private func markSquaresAttackedByBishop(mask: BoardMask, attackingSquare: Square) {
	}

	private func markSquaresAttackedByRook(mask: BoardMask, attackingSquare: Square) {
	}

	private func markSquaresAttackedByQueen(mask: BoardMask, attackingSquare: Square) {
	}

	private func markSquaresAttackedByKing(mask: BoardMask, attackingSquare: Square) {
	}
}

