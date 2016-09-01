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

	var game: Game?

	convenience init(game: Game) {
		self.init(windowNibName: "GameWindowController")
		self.game = game
	}

	// MARK: - NSWindowController methods
	
    override func windowDidLoad() {
        super.windowDidLoad()

		boardViewController.game = game
		boardViewController.boardView.game = game
    }
    
}
