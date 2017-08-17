//
//  CastlingFlags.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

enum CastlingSide {
	case kingSide, queenSide
}

struct CastlingFlags {
	private var whiteCanStillCastleKingSide: Bool = true
	private var whiteCanStillCastleQueenSide: Bool = true
	private var blackCanStillCastleKingSide: Bool = true
	private var blackCanStillCastleQueenSide: Bool = true

	mutating func disableCastling(_ color: PieceColor) {
		self[color, .kingSide] = false
		self[color, .queenSide] = false
	}

	mutating func disableCastling(_ color: PieceColor, _ side: CastlingSide) {
		self[color, side] = false
	}

	func canCastle(_ color: PieceColor, _ side: CastlingSide) -> Bool {
		return self[color, side]
	}

	private subscript(_ color: PieceColor, _ side: CastlingSide) -> Bool {
		get {
			switch (color, side) {
			case (.white, .kingSide): return whiteCanStillCastleKingSide
			case (.white, .queenSide): return whiteCanStillCastleQueenSide
			case (.black, .kingSide): return blackCanStillCastleKingSide
			case (.black, .queenSide): return blackCanStillCastleQueenSide
			}
		}
		set {
			switch (color, side) {
			case (.white, .kingSide): whiteCanStillCastleKingSide = newValue
			case (.white, .queenSide): whiteCanStillCastleQueenSide = newValue
			case (.black, .kingSide): blackCanStillCastleKingSide = newValue
			case (.black, .queenSide): blackCanStillCastleQueenSide = newValue
			}
		}
	}
}

