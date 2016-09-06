//
//  BoardView.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

// TODO: Add an option to display the board flipped.
class BoardView: NSView {

	// MARK: Properties - game play

	var game: Game?
	var selectedSquare: Square? {
		didSet {
			needsDisplay = true
		}
	}
	var overlayText: String? = nil {
		didSet {
			needsDisplay = true
		}
	}

	// MARK: Properties - appearance

	var backgroundColor = NSColor.white
	var whiteSquareColor = NSColor.yellow
	var blackSquareColor = NSColor.brown
	var overlayTextBackgroundColor = NSColor(calibratedWhite: 0.75, alpha: 1.0)

	var overlayTextColor = NSColor.red
	var overlayTextFont = NSFont(name: "Helvetica", size: 40.0)

	var pieceIcons = PieceIconSet.defaultSet()

	// MARK: Properties - geometry

	private var boardRect: NSRect {
		get {
			return bounds.insetBy(dx: 12.0, dy: 12.0)
		}
	}
	private var squareWidth: CGFloat {
		get {
			return boardRect.size.width / 8.0
		}
	}
	private var squareHeight: CGFloat {
		get {
			return boardRect.size.height / 8.0
		}
	}

	// MARK: - Geometry

	private func rectForSquare(_ x: Int, _ y: Int) -> NSRect {
		return NSRect(x: boardRect.origin.x + CGFloat(x) * squareWidth,
		              y: boardRect.origin.y + CGFloat(y) * squareHeight,
		              width: squareWidth,
		              height: squareHeight);
	}

	private func rectForSquare(_ square: Square) -> NSRect {
		return rectForSquare(square.x, square.y)
	}

	func squareContaining(localPoint: NSPoint) -> Square? {
		if squareWidth == 0.0 || squareHeight == 0.0 {
			return nil
		}

		let point = NSPointToCGPoint(localPoint)

		if !boardRect.contains(point) {
			return nil
		}

		return Square(x: Int(floor((point.x - boardRect.origin.x) / squareWidth)),
		              y: Int(floor((point.y - boardRect.origin.y) / squareHeight)))
	}

	// MARK: - NSView methods

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		drawBackground()
		drawGrid()
		drawPieces()
		drawHighlightOnSelectedSquare()
		drawOverlayText()
	}

	// MARK: - Private methods  -- drawing

	private func drawBackground() {
		backgroundColor.set()
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

	private func drawHighlightOnSelectedSquare() {
		if let square = selectedSquare {
			NSColor.blue.set()
			NSFrameRectWithWidth(rectForSquare(square), 6)
		}
	}

	private func drawOverlayText() {
		guard let overlayText = overlayText
			else { return }
		if overlayText.characters.count == 0 {
			return
		}

		let overlayRect = bounds.insetBy(fraction: 0.1).insetBy(widthFraction: 0, heightFraction: 0.375)
		let rr = NSBezierPath(roundedRect: overlayRect, xRadius: 8.0, yRadius: 8.0)
		overlayTextBackgroundColor.set()
		rr.fill()

		let paraStyle = NSMutableParagraphStyle()
		paraStyle.alignment = .center
		let font = overlayTextFont ?? NSFont.systemFont(ofSize: 30)
		guard let scaledFont = font.sizedToFit(string: overlayText, into: overlayRect.size) else {
			Swift.print("ERROR: Could not scale font for drawing overlay text.")
			return
		}
		let textAttributes: [String: Any] = [NSFontAttributeName : scaledFont,
		                                      NSForegroundColorAttributeName: overlayTextColor,
		                                      NSParagraphStyleAttributeName: paraStyle]
		overlayText.draw(in: overlayRect, withAttributes: textAttributes)
	}

}

