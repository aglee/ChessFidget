//
//  MoveType.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

enum PromotionType {
	case promoteToKnight
	case promoteToBishop
	case promoteToRook
	case promoteToQueen

	var pieceType: PieceType {
		get {
			switch self {
			case .promoteToKnight: return .Knight
			case .promoteToBishop: return .Bishop
			case .promoteToRook: return .Rook
			case .promoteToQueen: return .Queen
			}
		}
	}
}

enum MoveType {
	case pawnOneSquare
	case pawnTwoSquares
	case captureEnPassant
	case pawnPromotion(type: PromotionType)

	case castleKingSide
	case castleQueenSide

	case plain
}

enum MoveError: String {
	case startSquareMustContainPiece
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
	let start: Square
	let end: Square
	let type: MoveType

	init(from start: Square, to end: Square, type: MoveType) {
		self.start = start
		self.end = end
		self.type = type
	}
}
