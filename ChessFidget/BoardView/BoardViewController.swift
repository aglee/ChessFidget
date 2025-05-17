//
//  BoardViewController.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

class BoardViewController: NSViewController, GameObserver {
	var game: Game? {
		willSet {
			game?.gameObserver = nil
		}
		didSet {
			if game !== oldValue {
				game?.gameObserver = self
				boardView.game = game
				boardView.overlayText = nil
			}
		}
	}

	var boardView: BoardView {
		return view as! BoardView
	}

	// MARK: - NSViewController methods

	override func viewDidLoad() {
		super.viewDidLoad()

		let squareness = NSLayoutConstraint(item: boardView,
		                                    attribute: .width,
		                                    relatedBy: .equal,
		                                    toItem: boardView,
		                                    attribute: .height,
		                                    multiplier: 1.0,
		                                    constant: 0.0)
		boardView.addConstraint(squareness)  // TODO: Do this in IB.
	}

	// MARK: - NSResponder methods

	override func mouseUp(with event: NSEvent) {
		let viewPoint = boardView.convert(event.locationInWindow, from: nil)
		guard let clickedGridPoint = boardView.gridPointForSquareContaining(viewPoint: viewPoint) else {
			super.mouseUp(with: event)
			return
		}

		if let gameState = game?.gameState {
			switch gameState {
			case .awaitingMove:
				handleClickWhileAwaitingHumanMove(clickedGridPoint)
			default:
				super.mouseUp(with: event)
			}
		}
	}

	// MARK: - GameObserver methods

	func gameDidApplyMove(_ game: Game, move: Move, player: Player) {
		if player.isHuman {
			boardView.lastComputerMove = nil
		} else {
			boardView.lastComputerMove = move
		}
	}

	func gameDidEnd(_ game: Game, reason: ReasonGameIsOver) {
		boardView.overlayText = reason.rawValue
	}

	// MARK: - Private methods

	private func handleClickWhileAwaitingHumanMove(_ clickedGridPoint: GridPointXY) {
		game?.assertExpectedGameState(.awaitingMove)

		guard let game = game
			else { return }

		if boardView.selectedGridPoint == nil {
			if game.position.board[clickedGridPoint]?.color == game.position.whoseTurn {
				boardView.selectedGridPoint = clickedGridPoint
			}
		} else {
			if clickedGridPoint != boardView.selectedGridPoint! {
				tryProposedMove(from: boardView.selectedGridPoint!, to: clickedGridPoint)
				boardView.selectedGridPoint = nil
			}
		}
	}

	private func tryProposedMove(from startPoint: GridPointXY, to endPoint: GridPointXY) {
		game?.assertExpectedGameState(.awaitingMove)
		guard let game = game
			else { return }
		let validator = MoveValidator(position: game.position,
		                              startPoint: startPoint,
		                              endPoint: endPoint)
		switch validator.validateMove() {
		case .invalid(let reason):
			Swift.print(";;; Invalid move \(startPoint.squareName)-\(endPoint.squareName): \(reason)")
		case .valid(let moveType):
			if case .pawnPromotion = moveType {
				// Ask the user what piece type to promote the pawn to.
				let sheetController = PromotionSheetController()
				sheetController.setPieceColorForIcons(game.position.whoseTurn)
				boardView.window?.beginSheet(sheetController.window!, completionHandler: {
					(_: NSApplication.ModalResponse) in
					// The reference to sheetController within the closure prevents it from being dealloc'ed by ARC.
					let moveType: MoveType = .pawnPromotion(type: sheetController.selectedPromotionType)
					game.applyMove(Move(from: startPoint, to: endPoint, type: moveType))
				})
			} else {
				game.applyMove(Move(from: startPoint, to: endPoint, type: moveType))
			}
		}
	}

}
