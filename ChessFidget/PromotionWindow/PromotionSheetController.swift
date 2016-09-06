//
//  PromotionSheetController.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/6/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

class PromotionSheetController: NSWindowController {

	@IBOutlet var queenImageView: NSImageView!
	@IBOutlet var rookImageView: NSImageView!
	@IBOutlet var bishopImageView: NSImageView!
	@IBOutlet var knightImageView: NSImageView!

	func usePieceIcons(color: PieceColor) {
		let iconSet = PieceIconSet.defaultSet()

		queenImageView.image = iconSet.icon(color, .Queen)
		rookImageView.image = iconSet.icon(color, .Rook)
		bishopImageView.image = iconSet.icon(color, .Bishop)
		knightImageView.image = iconSet.icon(color, .Queen)
	}

	// MARK: - Action methods

	@IBAction func selectPromotionType(_ sender: NSButton) {
		let promotionType = PromotionType(rawValue: sender.tag)
		print(promotionType)
	}

	// MARK: - NSWindowController methods

    override func windowDidLoad() {
        super.windowDidLoad()

    }
    
}
