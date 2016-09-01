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

