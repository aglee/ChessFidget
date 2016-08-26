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
	var selectedSquare: Square? = nil {
		didSet {
			needsDisplay = true
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

	func rectForSquare(_ square: Square) -> NSRect {
		return rectForSquare(square.x, square.y)
	}

	func squareContaining(_ localPoint: NSPoint) -> Square? {
		if squareWidth == 0.0 || squareHeight == 0.0 {
			return nil
		}

		let point = NSPointToCGPoint(localPoint)

		if !boardRect.contains(point) {
			return nil
		}

		return Square(Int(floor((point.x - boardRect.origin.x) / squareWidth)),
		              Int(floor((point.y - boardRect.origin.y) / squareHeight)))
	}

	// MARK: - NSView methods

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		drawBackground()
		drawGrid()
		drawPieces()
		highlightSelectedSquare()
	}

	// MARK: - NSResponder methods

	override func mouseDown(with event: NSEvent) {
		let localPoint = convert(event.locationInWindow, from: nil)
		if let square = squareContaining(localPoint) {
			if selectedSquare != nil && square == selectedSquare! {
				// Clicking the selected square unselects it.
				selectedSquare = nil
			} else {
				selectedSquare = square
			}
		} else {
			selectedSquare = nil
		}
	}

	// MARK: - Private methods called by drawRect

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

	private func highlightSelectedSquare() {
		if let square = selectedSquare {
			NSColor.blue.set()
			NSFrameRectWithWidth(rectForSquare(square), 6)
		}
	}
}
