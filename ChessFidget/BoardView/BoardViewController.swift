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

	var game: Game?

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
			boardView.needsDisplay = true
		}
	}

	var boardView: BoardView {
		get {
			return view as! BoardView
		}
	}

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
			// TODO: Before making the move, if the move type is .pawnPromotion, ask the user to select a piece type to promote to, and modify move.type accordingly.  Currently pawns are always promoted to queens.
			makeMove(Move(from: startSquare, to: endSquare, type: moveType))

			// TODO: We're currently hardwired to alternate turns between the human and the computer.
			if currentlyValidMoves().count == 0 {
				stateOfPlay = .gameIsOver
			} else {
				stateOfPlay = .awaitingComputerMove
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

		let moveIndex = Int(arc4random_uniform(UInt32(validMoves.count)))
		makeMove(validMoves[moveIndex])

		let newValidMoves = currentlyValidMoves()
		if newValidMoves.count == 0 {
			stateOfPlay = .gameIsOver
		} else {
			// TODO: We're currently hardwired to alternate turns between the human and the computer.
			stateOfPlay = .awaitingHumanMove
		}
	}

	func currentlyValidMoves() -> [Move] {
		guard let game = game
			else { return [] }
		return game.position.validMoves
	}

	// Assumes the given move is valid for the current position.
	private func makeMove(_ move: Move) {
		guard let game = game
			else { return }

		game.position.makeMove(move)

		// Print for debugging.
		Swift.print(currentlyValidMoves().map({ "\($0.start)-\($0.end)" }).sorted())
	}
	
}
