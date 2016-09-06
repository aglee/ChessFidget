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
		case .White:
			switch pieceType {
			case .Pawn: return "♙"
			case .Knight: return "♘"
			case .Bishop: return "♗"
			case .Rook: return "♖"
			case .King: return "♔"
			case .Queen: return "♕"
			}
		case .Black:
			switch pieceType {
			case .Pawn: return "♟"
			case .Knight: return "♞"
			case .Bishop: return "♝"
			case .Rook: return "♜"
			case .King: return "♚"
			case .Queen: return "♛"
			}
		}
	}
}

