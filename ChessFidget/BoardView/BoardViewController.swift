//
//  BoardViewController.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

class BoardViewController: NSViewController {

	// Used to decide what to display and how to react to user inputs.
	private enum StateOfPlay {
		case initializing
		case awaitingHumanMove
		case awaitingComputerMove
		case awaitingPromotionSelection
		case gameIsOver
	}

	var game: Game? {
		didSet {
			boardView.game = game
			figureOutWhetherHumanOrComputerOrNobodyMovesNext()
		}
	}

	private var stateOfPlay: StateOfPlay = .initializing {
		didSet {
			Swift.print(stateOfPlay)

			guard stateOfPlay != oldValue
				else { return }

			boardView.overlayText = nil

			switch stateOfPlay {
			case .awaitingComputerMove:
				makeMoveOnBehalfOfComputer()
			case .gameIsOver:
				boardView.overlayText = "Game Over"
			default:
				break
			}
		}
	}

	var boardView: BoardView {
		return view as! BoardView
	}

//	var sheetController: PromotionSheetController? = nil

	// MARK: - NSViewController methods

	override func viewDidLoad() {
		super.viewDidLoad()

	}

	// MARK: - NSResponder methods

	override func mouseDown(with event: NSEvent) {
		let localPoint = boardView.convert(event.locationInWindow, from: nil)
		guard let clickedSquare = boardView.squareContaining(localPoint: localPoint)
			else { return }

		switch stateOfPlay {
		case .awaitingHumanMove:
			handleClickWhileAwaitingHumanMove(clickedSquare)
		default:
			break
		}
	}
	
	// MARK: - Private methods

	private func handleClickWhileAwaitingHumanMove(_ clickedSquare: Square) {
		assert(stateOfPlay == .awaitingHumanMove, "This method should only be called when the state of play is '\(StateOfPlay.awaitingHumanMove)")

		guard let game = game
			else { return }

		if boardView.selectedSquare == nil {
			if game.position.board[clickedSquare]?.color == game.position.whoseTurn {
				boardView.selectedSquare = clickedSquare
			}
		} else {
			if clickedSquare != boardView.selectedSquare! {
				tryProposedHumanMove(from: boardView.selectedSquare!, to: clickedSquare)
				boardView.selectedSquare = nil
			}
		}
	}

	private func tryProposedHumanMove(from startSquare: Square, to endSquare: Square) {
		assert(stateOfPlay == .awaitingHumanMove, "This method should only be called when the state of play is '\(StateOfPlay.awaitingHumanMove)")

		guard let game = game
			else { return }

		let validator = MoveValidator(position: game.position, startSquare: startSquare, endSquare: endSquare)

		switch validator.validateMove() {
		case .invalid(let reason):
			Swift.print("Invalid move \(startSquare)-\(endSquare): \(reason)")
		case .valid(let moveType):
			if case .pawnPromotion = moveType {
				// Ask the user what piece type to promote the pawn to.
				let sheetController = PromotionSheetController()
				sheetController.setPieceColorForIcons(game.position.whoseTurn)
				boardView.window?.beginSheet(sheetController.window!, completionHandler: {
					(_: NSModalResponse) in
					// The reference to sheetController within the closure prevents it from being dealloc'ed by ARC.
					let moveType: MoveType = .pawnPromotion(type: sheetController.selectedPromotionType)
					self.makeMove(Move(from: startSquare, to: endSquare, type: moveType))
				})
			} else {
				makeMove(Move(from: startSquare, to: endSquare, type: moveType))
			}
		}
	}

	private func makeMoveOnBehalfOfComputer() {
		assert(stateOfPlay == .awaitingComputerMove, "This method should only be called when the state of play is '\(StateOfPlay.awaitingComputerMove)")

		let validMoves = currentlyValidMoves()
		if validMoves.count == 0 {
			stateOfPlay = .gameIsOver
			return
		}

		// For now, just pick a random valid move.
		let moveIndex = Int(arc4random_uniform(UInt32(validMoves.count)))
		makeMove(validMoves[moveIndex])
	}

	func currentlyValidMoves() -> [Move] {
		guard let game = game
			else { return [] }
		return game.position.validMoves
	}

	// Apply the move to the game, position, and board.  Assumes the given move is valid for the current position.
	private func makeMove(_ move: Move) {
		guard let game = game
			else { return }

		print("\(move.start)-\(move.end) (\(move.type)) played by \(game.position.whoseTurn) (\(game.position.whoseTurn == game.humanPlayerPieceColor ? "Human" : "Computer"))")
		if game.position.whoseTurn == game.humanPlayerPieceColor {
			boardView.lastComputerMove = nil
		} else {
			boardView.lastComputerMove = move
		}
		game.position.makeMove(move)
		figureOutWhetherHumanOrComputerOrNobodyMovesNext()

		// Print for debugging.
		//Swift.print(currentlyValidMoves().map({ "\($0.start)-\($0.end)" }).sorted())
	}

	private func figureOutWhetherHumanOrComputerOrNobodyMovesNext() {
		guard let game = game
			else { return }
		
		if currentlyValidMoves().count == 0 {
			stateOfPlay = .gameIsOver
		} else if game.humanPlayerPieceColor == game.position.whoseTurn {
			stateOfPlay = .awaitingHumanMove
		} else {
			stateOfPlay = .awaitingComputerMove
		}
	}

}
