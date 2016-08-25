//
//  PieceIconSet.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

struct PieceIconSet {
	func icon(_ color: PieceColor, _ type: PieceType) -> NSImage {
		let name = imageName(color, type)
		let image = NSImage(named: name)
		return image!
	}

	func icon(_ piece: Piece) -> NSImage {
		return icon(piece.color, piece.type)
	}

	// MARK: Private functions

	private func imageName(_ color: PieceColor, _ type: PieceType) -> String {
		switch color {
		case .White:
			switch type {
			case .Pawn: return "wp"
			case .Knight: return "wn"
			case .Bishop: return "wb"
			case .Rook: return "wr"
			case .King: return "wk"
			case .Queen: return "wq"
			}
		case .Black:
			switch type {
			case .Pawn: return "bp"
			case .Knight: return "bn"
			case .Bishop: return "bb"
			case .Rook: return "br"
			case .King: return "bk"
			case .Queen: return "bq"
			}
		}
	}
}
