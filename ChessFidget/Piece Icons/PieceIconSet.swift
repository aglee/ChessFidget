//
//  PieceIconSet.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

struct PieceIconSet {
	private static var defaultIconSet = PieceIconSet()

	static func defaultSet() -> PieceIconSet {
		return defaultIconSet
	}

	func icon(_ color: PieceColor, _ type: PieceType) -> NSImage {
		let name = imageName(color, type)
		let image = NSImage(named: name)
		return image!
	}

	func icon(_ piece: Piece) -> NSImage {
		return icon(piece.color, piece.type)
	}

	// MARK: - Private methods

	private func imageName(_ color: PieceColor, _ type: PieceType) -> String {
		switch color {
		case .White:
			switch type {
			case .pawn: return "wp"
			case .knight: return "wn"
			case .bishop: return "wb"
			case .rook: return "wr"
			case .king: return "wk"
			case .queen: return "wq"
			}
		case .Black:
			switch type {
			case .pawn: return "bp"
			case .knight: return "bn"
			case .bishop: return "bb"
			case .rook: return "br"
			case .king: return "bk"
			case .queen: return "bq"
			}
		}
	}
}
