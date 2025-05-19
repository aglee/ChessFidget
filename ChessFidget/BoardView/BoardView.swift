//
//  BoardView.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

class BoardView: NSView {

	// MARK: Properties - game play
	
	var game: Game? {
		didSet {
			needsDisplay = true
			needsLayout = true  // Because the BoardView may need to re-reckon things if isFlipped changes depending on which color the human player is in the new value of game.
			if let game = game {
				displayBlackPOV = (game.blackPlayer.isHuman && !game.whitePlayer.isHuman)
			}

			// TODO: Seems the above isn't enough to force proper redraw when the flippedness changes, hence the fudging below.
			let sv = superview
			removeFromSuperview()
			sv?.addSubview(self)
		}
	}
	var displayBlackPOV = false { didSet { needsDisplay = true } }
	var selectedGridPoint: GridPointXY? { didSet { needsDisplay = true } }
	var overlayText: String? { didSet { needsDisplay = true } }

	// MARK: - Properties - styling

	var backgroundColor = NSColor.white
	var whiteSquareColor = NSColor.yellow
	var blackSquareColor = NSColor.brown
	var selectedSquareHighlightColor = NSColor.blue
	var lastMoveHighlightColor = NSColor.red
	var borderWidthForHighlightingSquares: CGFloat = 4.0
	var overlayTextBackgroundColor = NSColor(calibratedWhite: 0.75, alpha: 0.5)

	var overlayTextColor = NSColor.blue
	var overlayTextFont: NSFont = BoardView.defaultOverlayTextFont()

	private static func defaultOverlayTextFont() -> NSFont {
		let font = NSFont(name: "Helvetica", size: 40.0) ?? NSFont.systemFont(ofSize: 30)
		return NSFontManager.shared.convert(font, toHaveTrait: NSFontTraitMask.boldFontMask)
	}

	var pieceIcons = PieceIconSet.defaultSet()

	// MARK: - Geometry
	
	private var boardRect: NSRect { bounds.insetBy(dx: 12.0, dy: 12.0) }
	private var squareWidth: CGFloat { boardRect.size.width / 8.0 }
	private var squareHeight: CGFloat { boardRect.size.height / 8.0 }

	override var isFlipped: Bool { return displayBlackPOV }
	
	private func rectForSquareAtGridPoint(_ x: Int, _ y: Int) -> NSRect {
		let x = displayBlackPOV ? 7 - x : x
		return NSRect(x: boardRect.origin.x + CGFloat(x) * squareWidth,
		              y: boardRect.origin.y + CGFloat(y) * squareHeight,
		              width: squareWidth,
		              height: squareHeight)
	}

	private func rectForSquareAtGridPoint(_ gridPoint: GridPointXY) -> NSRect {
		return rectForSquareAtGridPoint(gridPoint.x, gridPoint.y)
	}

	/// The given point is in the receiver's coordinate system.
	func gridPointForSquareContaining(_ localPoint: NSPoint) -> GridPointXY? {
		if squareWidth == 0.0 || squareHeight == 0.0 {
			return nil
		}

		let point = NSPointToCGPoint(localPoint)

		if !boardRect.contains(point) {
			return nil
		}

		let x = Int(floor((point.x - boardRect.origin.x) / squareWidth))
		return GridPointXY(displayBlackPOV ? 7 - x : x,
						   Int(floor((point.y - boardRect.origin.y) / squareHeight)))
	}

	// MARK: - Mouse events

	override func mouseDown(with event: NSEvent) {
		super.mouseDown(with: event)
		
		guard game?.completionState == .awaitingMove else { return }
		guard let clickedGridPoint = gridPointForMouseEvent(event) else { return }
		
		mouseDownGridPoint = clickedGridPoint
		mouseStillDownGridPoint = clickedGridPoint
		if gridPointIsOccupiedByTheActivePlayer(clickedGridPoint) {
//			print(";;; mouseDown -- setting selectedGridPoint to \(mouseDownGridPoint.squareName)")
			selectedGridPoint = mouseDownGridPoint
		}
	}
	
	override func mouseDragged(with event: NSEvent) {
		super.mouseDragged(with: event)
		if let mouseDownGridPoint {
			mouseStillDownGridPoint = gridPointForMouseEvent(event)
			if mouseStillDownGridPoint != mouseDownGridPoint && gridPointIsOccupiedByTheActivePlayer(mouseDownGridPoint) {
//				print(";;; mouseDragged -- setting selectedGridPoint to \(mouseDownGridPoint.squareName)")
				selectedGridPoint = mouseDownGridPoint
			}
		}
	}
	
	override func mouseUp(with event: NSEvent) {
		super.mouseUp(with: event)

		mouseStillDownGridPoint = nil
		if let mouseDownGridPoint,
		   let mouseUpGridPoint = gridPointForMouseEvent(event),
		   let game,
		   case .awaitingMove = game.completionState
		{
			if mouseDownGridPoint == mouseUpGridPoint {
				// The user CLICKED a single square.
				if let selectedGridPoint {
					if mouseUpGridPoint == selectedGridPoint {
						// Clicking the already selected square keeps it selected.
//						print(";;; mouseUp -- clicked already-selected square -- no change")
					} else {
						// Clicking a square other than the already selected square means
						// the user is proposing a move.
						applyMoveIfPossible(from: selectedGridPoint, to: mouseUpGridPoint)
//						print(";;; mouseUp -- clicked square other than the selected one -- proposed move, unsetting selectedGridPoint")
						self.selectedGridPoint = nil
					}
				} else {
					if gridPointIsOccupiedByTheActivePlayer(mouseUpGridPoint) {
						// There is no selected square, and the one that was clicked is
						// valid to be selected, so select it.
//						print(";;; mouseUp -- setting selectedGridPoint to \(mouseUpGridPoint.squareName)")
						self.selectedGridPoint = mouseUpGridPoint
					} else {
						// Ignore clicks on empty squares and squares occupied by the
						// opponent's pieces.
//						print(";;; mouseUp -- clicked on a nonstarter square -- no change")
					}
				}
			} else {
				// The user DRAGGED from one square to a different square.  If the first
				// square was a valid square to start a move with, propose the move.
				applyMoveIfPossible(from: mouseDownGridPoint, to: mouseUpGridPoint)
//				print(";;; mouseUp -- dragged to second square -- proposed move, unsetting selectedGridPoint")
				selectedGridPoint = nil
			}
		}
		mouseDownGridPoint = nil
	}

	private var mouseDownGridPoint: GridPointXY? { didSet { needsDisplay = true } }
	private var mouseStillDownGridPoint: GridPointXY? { didSet { needsDisplay = true } }
	
	private func gridPointForMouseEvent(_ event: NSEvent) -> GridPointXY? {
		let localPoint = convert(event.locationInWindow, from: nil)
		return gridPointForSquareContaining(localPoint)
	}

	private func gridPointIsOccupiedByTheActivePlayer(_ gridPoint: GridPointXY) -> Bool {
		guard let piece = game?.position.board[gridPoint] else { return false }
		return piece.color == game?.position.whoseTurn
	}

	private let promotionSheetController = PromotionSheetController()

	private func applyMoveIfPossible(from startPoint: GridPointXY, to endPoint: GridPointXY) {
		guard let game, let window else { return }

		func applyMove(_ move: Move) {
			game.applyMove(move)
			if case .gameOver(let reason) = game.completionState {
				overlayText = reason.rawValue
			}
			needsDisplay = true
		}

		switch game.validateMove(from: startPoint, to: endPoint) {
		case .invalid(let reason):
			print(";;; Invalid move \(startPoint.squareName)-\(endPoint.squareName): \(reason)")
		case .valid(let moveType):
			if case .pawnPromotion = moveType {
				// Ask the user what piece type to promote the pawn to.
				promotionSheetController.setPieceColorForIcons(game.position.whoseTurn)
				window.beginSheet(promotionSheetController.window!) { [weak self] _ in
					guard let self else { return }
					let moveType: MoveType = .pawnPromotion(type: promotionSheetController.selectedPromotionType)
					applyMove(Move(from: startPoint, to: endPoint, type: moveType))
				}
			} else {
				applyMove(Move(from: startPoint, to: endPoint, type: moveType))
			}
		}
	}

	// MARK: - Drawing

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		drawBackground()
		drawPieces()
		drawSquareHighlights()
		drawOverlayText()
	}

	private func drawBackground() {
		backgroundColor.set()
		bounds.fill()

		(displayBlackPOV ? blackSquareColor : whiteSquareColor).set()
		boardRect.fill()

		(displayBlackPOV ? whiteSquareColor : blackSquareColor).set()
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

	private func drawSquareHighlights() {
		if let lastMove = game?.moveHistory.last {
			lastMoveHighlightColor.set()
			rectForSquareAtGridPoint(lastMove.start).frame(withWidth: borderWidthForHighlightingSquares)
			rectForSquareAtGridPoint(lastMove.end).frame(withWidth: borderWidthForHighlightingSquares)
		}

		if let selectedGridPoint {
			selectedSquareHighlightColor.set()
			rectForSquareAtGridPoint(selectedGridPoint).frame(withWidth: borderWidthForHighlightingSquares)
		}

		if let mouseStillDownGridPoint {
			selectedSquareHighlightColor.set()
			if let selectedGridPoint {
				rectForSquareAtGridPoint(selectedGridPoint).frame(withWidth: borderWidthForHighlightingSquares)
			}
			rectForSquareAtGridPoint(mouseStillDownGridPoint).frame(withWidth: borderWidthForHighlightingSquares)
		}
	}

	private func drawOverlayText() {
		guard let overlayText = overlayText
			else { return }
		if overlayText.count == 0 {
			return
		}

		let overlayRect = bounds.insetBy(fraction: 0.05).insetBy(widthFraction: 0, heightFraction: 0.375)
		let roundedRectPath = NSBezierPath(roundedRect: overlayRect, xRadius: 8.0, yRadius: 8.0)
		overlayTextBackgroundColor.set()
		roundedRectPath.fill()

		let stringBoundingRect = overlayRect.insetBy(dx: 8.0, dy: 0)
		guard let scaledFont = overlayTextFont.sizedToFit(string: overlayText, into: stringBoundingRect.size) else {
			print(";;; ERROR: Could not scale font for drawing overlay text.")
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

