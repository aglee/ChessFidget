//
//  BoardViewController.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

class BoardViewController: NSViewController {
	
	var game: Game? {
		didSet {
			if game !== oldValue, let boardView = view as? BoardView {
				boardView.game = game
				boardView.overlayText = nil
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let squareness = NSLayoutConstraint(item: view,
		                                    attribute: .width,
		                                    relatedBy: .equal,
		                                    toItem: view,
		                                    attribute: .height,
		                                    multiplier: 1.0,
		                                    constant: 0.0)
		view.addConstraint(squareness)  // TODO: Do this in IB.
	}

}
