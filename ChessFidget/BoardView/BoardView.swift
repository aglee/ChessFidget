//
//  BoardView.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

/**
For a first pass I will have the view own a Game instance
*/
class BoardView: NSView {

	var game: Game?
	var whiteSquareColor = NSColor.yellow
	var blackSquareColor = NSColor.brown
	var pieceIcons = PieceIconSet()
	var boardRect: NSRect {
		get {
			return bounds.insetBy(dx: 12.0, dy: 12.0)
		}
	}
	var squareWidth: CGFloat {
		get {
			return boardRect.size.width / 8.0
		}
	}
	var squareHeight: CGFloat {
		get {
			return boardRect.size.height / 8.0
		}
	}

	func rectForSquare(_ x: Int, _ y: Int) -> NSRect {
		return NSRect(x: boardRect.origin.x + CGFloat(x) * squareWidth,
		              y: boardRect.origin.y + CGFloat(y) * squareHeight,
		              width: squareWidth,
		              height: squareHeight);
	}

	// MARK: NSView methods

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		drawBackground()
		drawGrid()
		drawPieces()
	}

	// MARK: Private methods called by drawRect

	private func drawBackground() {
		NSColor.white.set()
		NSRectFill(bounds)
	}

	private func drawGrid() {
		whiteSquareColor.set()
		NSRectFill(boardRect)

		blackSquareColor.set()
		for x in 0...7 {
			for y in 0...7 {
				if (x+y) % 2 == 0 {
					NSRectFill(rectForSquare(x, y))
				}
			}
		}
	}

	private func drawPieces() {
		for x in 0...7 {
			for y in 0...7 {
				if let piece = game?.position.board[x, y] {
					let icon = pieceIcons.icon(piece)
					icon.draw(in: rectForSquare(x, y).insetBy(fraction: 0.1))
				}
			}
		}
	}
}
