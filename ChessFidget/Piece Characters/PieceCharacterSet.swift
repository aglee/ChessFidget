//
//  PieceCharacterSet.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/6/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

// TODO: Add a way to specify other sets of characters to use.
struct PieceCharacterSet {
	static var defaultSet = PieceCharacterSet()

	func character(_ pieceColor: PieceColor, _ pieceType: PieceType) -> Character {
		switch pieceColor {
		case .white:
			switch pieceType {
			case .pawn: return "♙"
			case .knight: return "♘"
			case .bishop: return "♗"
			case .rook: return "♖"
			case .king: return "♔"
			case .queen: return "♕"
			}
		case .black:
			switch pieceType {
			case .pawn: return "♟"
			case .knight: return "♞"
			case .bishop: return "♝"
			case .rook: return "♜"
			case .king: return "♚"
			case .queen: return "♛"
			}
		}
	}
}

