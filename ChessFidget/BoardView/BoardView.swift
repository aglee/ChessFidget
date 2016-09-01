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

	var game: Game?
	var backgroundColor = NSColor.white
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
			needsDisplay = true  //TODO: Use KVC.
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
	}

	// MARK: - NSResponder methods

	override func mouseDown(with event: NSEvent) {
		let localPoint = convert(event.locationInWindow, from: nil)
		if let clickedSquare = squareContaining(localPoint: localPoint) {
			if selectedSquare == nil {
				if game?.position.board[clickedSquare]?.color == game?.position.whoseTurn {
					selectedSquare = clickedSquare
				}
			} else {
				if clickedSquare != selectedSquare {
					tryMove(to: clickedSquare)
				}
				selectedSquare = nil
			}
		}
	}

	// MARK: - Private methods -- user interaction

	private func tryMove(to toSquare: Square) {
		guard let game = game else {
			return
		}
		guard let selectedSquare = selectedSquare else {
			return
		}

		// Bail if the move would be illegal.
		let validator = MoveValidator(position: game.position, fromSquare: selectedSquare, toSquare: toSquare)
		if case .invalid(let reason) = validator.validateMove() {
			Swift.print("Invalid move: \(selectedSquare)-\(toSquare). \(reason)")
			return
		}

		// TODO: Ask the user for promotion info if necessary.
		let promotion: PieceType? = nil

		// Play the move.
		game.position.move(from: selectedSquare, to: toSquare, promotion: promotion)
		self.selectedSquare = nil
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
}
