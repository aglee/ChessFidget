//
//  GameWindowController.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

/// Window in which a game of chess is played.
class GameWindowController: NSWindowController {
	@IBOutlet var boardViewController: BoardViewController!

	var game: Game

	init(game: Game) {
		self.game = game
		super.init(window: nil)  // Passing nil causes windowNibName to be used.
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Action methods

	private var newGameDialogController = NewGameDialogController()
	
	@IBAction func newGame(_: AnyObject?) {
		guard let window else { return }
		guard let dialogWindow = newGameDialogController.window else { return }
		window.beginSheet(dialogWindow) { [weak self] response in
			guard let self else { return }
			guard response == .OK else { return }
			guard let engineType = newGameDialogController.selectedEngineType else { return }
			let engine = EnginePlayer.newPlayer(engineType)
			let board = (newGameDialogController.selectedBoardArrangement == 1
						 ? Board.withMonaLisaPracticeLayout()
						 : Board.withClassicalLayout())
			if newGameDialogController.selectedPieceColor == .white {
				game = Game(white: HumanPlayer(), black: engine, board: board)
			} else {
				game = Game(white: engine, black: HumanPlayer(), board: board)
			}
			boardViewController.game = self.game
			game.startPlay()
		}
	}

	// MARK: - NSWindowController methods
	
	/// This gets called when we do `init(window: nil)`.
	override var windowNibName : NSNib.Name? {
		return NSNib.Name(rawValue: "GameWindowController")
	}

    override func windowDidLoad() {
        super.windowDidLoad()
		boardViewController.game = game
    }

}
