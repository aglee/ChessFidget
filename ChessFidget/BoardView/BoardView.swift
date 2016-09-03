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

	// BoardView uses these to decide what to display and how to react to user inputs.
	private enum StateOfPlay {
		case initializing
		case awaitingHumanMove
		case awaitingComputerMove
		case awaitingPromotionSelection
		case gameIsOver
	}

	// MARK: - Properties - game play

	var game: Game? {
		didSet {
			if let game = game {
				validMoves = MoveGenerator(position: game.position).moves
			}
		}
	}
	private var stateOfPlay: StateOfPlay = .awaitingHumanMove { //.initializing {  //TODO: fix
		didSet {
			Swift.print("state of play is now \(stateOfPlay)")
			guard stateOfPlay != oldValue
				else { return }

			switch stateOfPlay {
			case .awaitingComputerMove:
				makeMoveOnBehalfOfComputer()
			default:
				break
			}
			needsDisplay = true
		}
	}
	var selectedSquare: Square? {
		didSet {
			needsDisplay = true
		}
	}
	private var validMoves = MoveLookup()

	// MARK: Properties - appearance

	var backgroundColor = NSColor.white
	var whiteSquareColor = NSColor.yellow
	var blackSquareColor = NSColor.brown
	var pieceIcons = PieceIconSet()

	// MARK: Properties - geometry

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

	// MARK: - Geometry

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
		guard let clickedSquare = squareContaining(localPoint: localPoint)
			else { return }

		switch stateOfPlay {
		case .awaitingHumanMove:
			handleClickWhileAwaitingHumanMove(clickedSquare)
		default:
			break
		}
	}

	// MARK: - Private methods -- user interaction

	private func handleClickWhileAwaitingHumanMove(_ clickedSquare: Square) {
		assert(stateOfPlay == .awaitingHumanMove, "This method should only be called when the state of play is '\(StateOfPlay.awaitingHumanMove)")

		guard let game = game
			else { return }

		if selectedSquare == nil {
			if game.position.board[clickedSquare]?.color == game.position.whoseTurn {
				selectedSquare = clickedSquare
			}
		} else {
			if clickedSquare != selectedSquare! {
				if tryProposedHumanMove(from: selectedSquare!, to: clickedSquare) {
					// TODO: We're currently hardwired to alternate turns between the human and the computer.
					if validMoves.allMoves().count == 0 {
						stateOfPlay = .gameIsOver
					} else {
						stateOfPlay = .awaitingComputerMove
					}
				}
			}
			selectedSquare = nil
		}
	}

	private func tryProposedHumanMove(from fromSquare: Square, to toSquare: Square) -> Bool {
		assert(stateOfPlay == .awaitingHumanMove, "This method should only be called when the state of play is '\(StateOfPlay.awaitingHumanMove)")

		guard let move = validMoves.move(from: fromSquare, to: toSquare)
			else { return false }

		// TODO: Before making the move, if the move type is .pawnPromotion, ask the user to select a piece type to promote to, and modify move.moveType accordingly.  Currently pawns are always promoted to queens.
		makeMove(move)

		return true
	}

	private func makeMoveOnBehalfOfComputer() {
		assert(stateOfPlay == .awaitingComputerMove, "This method should only be called when the state of play is '\(StateOfPlay.awaitingComputerMove)")

		let moveArray = validMoves.allMoves()
		let moveIndex = Int(arc4random_uniform(UInt32(moveArray.count)))
		let move = moveArray[moveIndex]
		makeMove(move)

		// TODO: We're currently hardwired to alternate turns between the human and the computer.
		if validMoves.allMoves().count == 0 {
			stateOfPlay = .gameIsOver
		} else {
			stateOfPlay = .awaitingHumanMove
		}
	}

	// The given move MUST be valid.
	private func makeMove(_ move: Move) {
		guard let game = game
			else { return }

		game.position.makeMove(move)

		// Recalculate the set of valid moves given the new state of the board.
		validMoves = MoveGenerator(position: game.position).moves
		Swift.print(validMoves.allMoves().map({ "\($0.fromSquare)-\($0.toSquare)" }).sorted())
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
