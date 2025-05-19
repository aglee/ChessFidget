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

	var selectedPromotionType: PromotionType = .promoteToQueen

	init() {
		super.init(window: nil)

		// Force the nib to be loaded, which will set all our IBOutlets.
		loadWindow()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setPieceColorForIcons(_ color: PieceColor) {
		let iconSet = PieceIconSet.defaultSet()

		queenImageView.image = iconSet.icon(color, .queen)
		rookImageView.image = iconSet.icon(color, .rook)
		bishopImageView.image = iconSet.icon(color, .bishop)
		knightImageView.image = iconSet.icon(color, .queen)
	}

	// MARK: - Action methods

	@IBAction func selectPromotionType(_ sender: NSButton) {
		guard let window else { return }

		if let type = PromotionType(rawValue: sender.tag) {
			selectedPromotionType = type
		}
		window.sheetParent?.endSheet(window, returnCode: NSApplication.ModalResponse.cancel)
		window.close()
	}

	// MARK: - NSWindowController methods

	// This gets called when we do the init(window: nil).
	override var windowNibName : NSNib.Name? {
		return NSNib.Name(rawValue: "PromotionSheetController")
	}

}
