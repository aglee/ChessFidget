//
//  MoveType.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

enum MoveType {
	case pawnOneSquare
	case pawnTwoSquares
	case captureEnPassant
	case pawnPromotion(pieceType: PieceType)

	case castleKingSide
	case castleQueenSide

	case plain
}

enum MoveError: String {
	case fromSquareMustContainPiece
	case pieceBelongsToWrongPlayer

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

struct Move {
	let fromSquare: Square
	let toSquare: Square
	let moveType: MoveType

	init(from fromSquare: Square, to toSquare: Square, moveType: MoveType) {
		self.fromSquare = fromSquare
		self.toSquare = toSquare
		self.moveType = moveType
	}
}
