//
//  BoardViewController.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

class BoardViewController: NSViewController {

	var game: Game?
	
	var boardView: BoardView {
		get {
			return view as! BoardView
		}
	}

	// MARK: NSViewController overrides

	override func viewDidLoad() {
		super.viewDidLoad()

	}

}
