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

class Piece {
	let color: PieceColor
	let type: PieceType

	internal init(_ color: PieceColor, _ type: PieceType) {
		self.color = color
		self.type = type
	}
}

class Pawn: Piece {
	init(_ color: PieceColor) {
		super.init(color, .Pawn)
	}
}

