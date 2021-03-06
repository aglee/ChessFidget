//
//  BoardView.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

// TODO: Add an option to flip the board at any time regardless of which color the user is playing.
class BoardView: NSView {

	// MARK: Properties - game play

	var game: Game? {
		didSet {
			lastComputerMove = nil
			needsDisplay = true
			needsLayout = true  // Because the BoardView may need to re-reckon things if isFlipped changes depending on which color the human player is in the new value of game.

			// TODO: Seems the above isn't enough to force proper redraw when the flippedness changes, hence the fudging below.
			let sv = superview
			removeFromSuperview()
			sv?.addSubview(self)
		}
	}
	var selectedGridPoint: GridPointXY? {
		didSet {
			needsDisplay = true
		}
	}
	var lastComputerMove: Move?
	var overlayText: String? {
		didSet {
			needsDisplay = true
		}
	}

	// MARK: Properties - appearance

	var backgroundColor = NSColor.white
	var whiteSquareColor = NSColor.yellow
	var blackSquareColor = NSColor.brown
	var selectedSquareHighlightColor = NSColor.blue
	var lastComputerMoveHighlightColor = NSColor.red
	var borderWidthForHighlightingSquares: CGFloat = 4.0
	var overlayTextBackgroundColor = NSColor(calibratedWhite: 0.75, alpha: 0.5)

	var overlayTextColor = NSColor.blue
	var overlayTextFont: NSFont = BoardView.defaultOverlayTextFont()

	private static func defaultOverlayTextFont() -> NSFont {
		let font = NSFont(name: "Helvetica", size: 40.0) ?? NSFont.systemFont(ofSize: 30)
		return NSFontManager.shared.convert(font, toHaveTrait: NSFontTraitMask.boldFontMask)
	}

	var pieceIcons = PieceIconSet.defaultSet()

	// MARK: Properties - geometry

	private var boardRect: NSRect {
		return bounds.insetBy(dx: 12.0, dy: 12.0)
	}
	private var squareWidth: CGFloat {
		return boardRect.size.width / 8.0
	}
	private var squareHeight: CGFloat {
		return boardRect.size.height / 8.0
	}

	// MARK: - Geometry

	private func rectForSquareAtGridPoint(_ x: Int, _ y: Int) -> NSRect {
		return NSRect(x: boardRect.origin.x + CGFloat(x) * squareWidth,
		              y: boardRect.origin.y + CGFloat(y) * squareHeight,
		              width: squareWidth,
		              height: squareHeight);
	}

	private func rectForSquareAtGridPoint(_ gridPoint: GridPointXY) -> NSRect {
		return rectForSquareAtGridPoint(gridPoint.x, gridPoint.y)
	}

	// viewPoint is in the receiver's coordinate system.
	func gridPointForSquareContaining(viewPoint: NSPoint) -> GridPointXY? {
		if squareWidth == 0.0 || squareHeight == 0.0 {
			return nil
		}

		let point = NSPointToCGPoint(viewPoint)

		if !boardRect.contains(point) {
			return nil
		}

		return GridPointXY(Int(floor((point.x - boardRect.origin.x) / squareWidth)),
		               Int(floor((point.y - boardRect.origin.y) / squareHeight)))
	}

	// MARK: - NSView methods

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		drawBackground()
		drawGrid()
		drawPieces()
		drawHighlightOnSelectedSquare()
		drawHighlightOnLastComputerMove()
		drawOverlayText()
	}

	override var isFlipped: Bool {
		guard let game = game
			else { return false }
		return game.humanPlayerPieceColor == .black
	}

	// MARK: - Private methods  -- drawing

	private func drawBackground() {
		backgroundColor.set()
		bounds.fill()
	}

	private func drawGrid() {
		whiteSquareColor.set()
		boardRect.fill()

		blackSquareColor.set()
		for x in 0...7 {
			for y in 0...7 {
				if (x+y) % 2 == 0 {
					rectForSquareAtGridPoint(x, y).fill()
				}
			}
		}
	}

	private func drawPieces() {
		for x in 0...7 {
			for y in 0...7 {
				if let piece = game?.position.board[x, y] {
					let icon = pieceIcons.icon(piece)
					icon.draw(in: rectForSquareAtGridPoint(x, y).insetBy(fraction: 0.1))
				}
			}
		}
	}

	private func drawHighlightOnSelectedSquare() {
		if let gridPoint = selectedGridPoint {
			selectedSquareHighlightColor.set()
			rectForSquareAtGridPoint(gridPoint).frame(withWidth: borderWidthForHighlightingSquares)
		}
	}

	private func drawHighlightOnLastComputerMove() {
		if let move = lastComputerMove {
			lastComputerMoveHighlightColor.set()
			rectForSquareAtGridPoint(move.end).frame(withWidth: borderWidthForHighlightingSquares)
		}
	}

	private func drawOverlayText() {
		guard let overlayText = overlayText
			else { return }
		if overlayText.characters.count == 0 {
			return
		}

		let overlayRect = bounds.insetBy(fraction: 0.05).insetBy(widthFraction: 0, heightFraction: 0.375)
		let roundedRectPath = NSBezierPath(roundedRect: overlayRect, xRadius: 8.0, yRadius: 8.0)
		overlayTextBackgroundColor.set()
		roundedRectPath.fill()

		let stringBoundingRect = overlayRect.insetBy(dx: 8.0, dy: 0)
		guard let scaledFont = overlayTextFont.sizedToFit(string: overlayText, into: stringBoundingRect.size) else {
			Swift.print("ERROR: Could not scale font for drawing overlay text.")
			return
		}
		let stringWidth = overlayText.size(withAttributes:[NSAttributedStringKey.font: scaledFont]).width
		let stringHeight = scaledFont.capHeight - scaledFont.descender
		let stringRect = stringBoundingRect.insetBy(dx: (stringBoundingRect.size.width - stringWidth)/2,
		                                            dy: (stringBoundingRect.size.height - stringHeight)/2)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		let textAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: scaledFont,
		                                                    NSAttributedStringKey.foregroundColor: overlayTextColor,
		                                                    NSAttributedStringKey.paragraphStyle: paragraphStyle]
		overlayText.draw(at: stringRect.origin, withAttributes: textAttributes)
	}

}

