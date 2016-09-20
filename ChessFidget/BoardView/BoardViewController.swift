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
			game?.gameObserver = self
			boardView.game = game
			game?.startPlay()
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
		boardView.addConstraint(squareness);
	}

	// MARK: - NSResponder methods

	override func mouseDown(with event: NSEvent) {
		let viewPoint = boardView.convert(event.locationInWindow, from: nil)
		guard let clickedGridPoint = boardView.gridPointForSquareContaining(viewPoint: viewPoint)
			else { return }

		if game?.gameState == .awaitingHumanMove {
			handleClickWhileAwaitingHumanMove(clickedGridPoint)
		}
	}

	// MARK: - GameObserver methods

	func gameDidChangeState(_ game: Game, oldValue: GameState) {
		if game.gameState == .gameIsOver {
			boardView.overlayText = "Game Over"
		} else {
			boardView.overlayText = nil
		}
	}

	func gameDidMakeMove(_ game: Game, move: Move) {
		if game.position.whoseTurn == game.humanPlayerPieceColor {
			boardView.lastComputerMove = move
		} else {
			boardView.lastComputerMove = nil
		}
	}

	// MARK: - Private methods

	private func handleClickWhileAwaitingHumanMove(_ clickedGridPoint: GridPointXY) {
		game?.assertExpectedGameState(.awaitingHumanMove);

		guard let game = game
			else { return }

		if boardView.selectedGridPoint == nil {
			if game.position.board[clickedGridPoint]?.color == game.position.whoseTurn {
				boardView.selectedGridPoint = clickedGridPoint
			}
		} else {
			if clickedGridPoint != boardView.selectedGridPoint! {
				tryProposedHumanMove(from: boardView.selectedGridPoint!, to: clickedGridPoint)
				boardView.selectedGridPoint = nil
			}
		}
	}

	private func tryProposedHumanMove(from startPoint: GridPointXY, to endPoint: GridPointXY) {
		game?.assertExpectedGameState(.awaitingHumanMove);

		guard let game = game
			else { return }

		let validator = MoveValidator(position: game.position, startPoint: startPoint, endPoint: endPoint)

		switch validator.validateMove() {
		case .invalid(let reason):
			Swift.print("Invalid move \(startPoint.squareName)-\(endPoint.squareName): \(reason)")
		case .valid(let moveType):
			if case .pawnPromotion = moveType {
				// Ask the user what piece type to promote the pawn to.
				let sheetController = PromotionSheetController()
				sheetController.setPieceColorForIcons(game.position.whoseTurn)
				boardView.window?.beginSheet(sheetController.window!, completionHandler: {
					(_: NSModalResponse) in
					// The reference to sheetController within the closure prevents it from being dealloc'ed by ARC.
					let moveType: MoveType = .pawnPromotion(type: sheetController.selectedPromotionType)
					game.makeHumanMove(Move(from: startPoint, to: endPoint, type: moveType))
				})
			} else {
				game.makeHumanMove(Move(from: startPoint, to: endPoint, type: moveType))
			}
		}
	}

}
