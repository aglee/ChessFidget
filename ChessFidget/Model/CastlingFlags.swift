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
			case (.White, .kingSide): return whiteCanStillCastleKingSide
			case (.White, .queenSide): return whiteCanStillCastleQueenSide
			case (.Black, .kingSide): return blackCanStillCastleKingSide
			case (.Black, .queenSide): return blackCanStillCastleQueenSide
			}
		}
		set {
			switch (color, side) {
			case (.White, .kingSide): whiteCanStillCastleKingSide = newValue
			case (.White, .queenSide): whiteCanStillCastleQueenSide = newValue
			case (.Black, .kingSide): blackCanStillCastleKingSide = newValue
			case (.Black, .queenSide): blackCanStillCastleQueenSide = newValue
			}
		}
	}
}

