//
//  Piece.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

enum PieceColor {
	case Black, White
}

enum PieceType {
	case Pawn, Knight, Bishop, Rook, Queen, King
}

struct Piece {
	let color: PieceColor
	let type: PieceType

	init(_ color: PieceColor, _ type: PieceType) {
		self.color = color
		self.type = type
	}
}

