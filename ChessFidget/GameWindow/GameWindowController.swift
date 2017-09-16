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
			computerPlaysRandomlyCheckbox.state =
				game.computerPlaysRandomly ? .on : .off
		}
	}

	init(game: Game) {
		self.game = game
		super.init(window: nil)  // Passing nil causes windowNibName to be used.
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Action methods

	@IBAction func resetGameWithHumanPlayingWhite(_: AnyObject?) {
		resetGame(humanPlays: .white)
	}

	@IBAction func resetGameWithHumanPlayingBlack(_: AnyObject?) {
		resetGame(humanPlays: .black)
	}

	// MARK: - NSWindowController methods
	
	// This gets called when we do the init(window: nil).
	override var windowNibName : NSNib.Name? {
		return NSNib.Name(rawValue: "GameWindowController")
	}

    override func windowDidLoad() {
        super.windowDidLoad()
		boardViewController.game = game
		computerPlaysRandomlyCheckbox.state = (game.computerPlaysRandomly ? .on : .off)
    }

	// MARK: - Private methods
    
	private func resetGame(humanPlays pieceColor: PieceColor) {
		game = Game(humanPlays: pieceColor,
		            computerPlaysRandomly: (computerPlaysRandomlyCheckbox.state == .on))
		boardViewController.game = game
	}

}
