//
//  GameWindowController.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

class GameWindowController: NSWindowController {

	@IBOutlet var boardViewController: BoardViewController!
	@IBOutlet var computerPlaysRandomlyCheckbox: NSButton!
	var game: Game {
		didSet {
			computerPlaysRandomlyCheckbox.state = (game.computerPlaysRandomly ? NSOnState : NSOffState)
		}
	}

	init(game: Game) {
		self.game = game

		// Passing window:nil causes windowNibName to be used.
		super.init(window: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Action methods

	@IBAction func resetGameWithHumanPlayingWhite(_: AnyObject?) {
		resetGame(humanPlayerPieceColor: .White)
	}

	@IBAction func resetGameWithHumanPlayingBlack(_: AnyObject?) {
		resetGame(humanPlayerPieceColor: .Black)
	}

	// MARK: - NSWindowController methods
	
	// This gets called when we do the init(window: nil).
	override var windowNibName : String! {
		return "GameWindowController"
	}

    override func windowDidLoad() {
        super.windowDidLoad()
		boardViewController.game = game
		computerPlaysRandomlyCheckbox.state = (game.computerPlaysRandomly ? NSOnState : NSOffState)
    }

	// MARK: - Private methods
    
	private func resetGame(humanPlayerPieceColor: PieceColor) {
		game = Game(humanPlayerPieceColor: humanPlayerPieceColor, computerPlaysRandomly: computerPlaysRandomlyCheckbox.state == NSOnState)
		boardViewController.game = game
	}

}
