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
		self.loadWindow()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setPieceColorForIcons(_ color: PieceColor) {
		let iconSet = PieceIconSet.defaultSet()

		queenImageView.image = iconSet.icon(color, .Queen)
		rookImageView.image = iconSet.icon(color, .Rook)
		bishopImageView.image = iconSet.icon(color, .Bishop)
		knightImageView.image = iconSet.icon(color, .Queen)
	}

	// MARK: - Action methods

	@IBAction func selectPromotionType(_ sender: NSButton) {
		if let type = PromotionType(rawValue: sender.tag) {
			selectedPromotionType = type
		}
		self.window!.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseCancel)
		self.window!.close()
	}

	// MARK: - NSWindowController methods

	// This gets called when we do the init(window: nil).
	override var windowNibName : String! {
		return "PromotionSheetController"
	}

	override func windowDidLoad() {
		super.windowDidLoad()

	}

}
