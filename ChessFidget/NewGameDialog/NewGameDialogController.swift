//
//  NewGameDialogController.swift
//  ChessFidget
//
//  Created by Andy Lee on 5/17/25.
//  Copyright © 2025 Andy Lee. All rights reserved.
//

import Cocoa

class NewGameDialogController: NSWindowController {
	
	@IBOutlet var pieceColorsRadioContainer: NSView!
	@IBOutlet var boardOptionsRadioContainer: NSView!
	@IBOutlet var enginesRadioContainer: NSView!
	
	var selectedPieceColor: PieceColor {
		get { pieceColorsRadioContainer.tagOfSelectedButtonSubview() == 0 ? .black : .white }
		set { pieceColorsRadioContainer.selectButtonSubviewWithTag(newValue == .black ? 0 : 1) }
	}
	
	var selectedBoardArrangement: Int {
		get { boardOptionsRadioContainer.tagOfSelectedButtonSubview() ?? 0 }
		set { boardOptionsRadioContainer.selectButtonSubviewWithTag(newValue) }
	}
	
	var selectedEngineType: EngineType? {
		if let tag = enginesRadioContainer.tagOfSelectedButtonSubview() {
			return EngineType(rawValue: tag)
		} else {
			return nil
		}
	}
	
	init() {
		super.init(window: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Action methods

	/// Common action for radio buttons.
	@IBAction func selectPieceColor(_ sender: Any?) { }

	/// Common action for radio buttons.
	@IBAction func selectBoardArrangement(_ sender: Any?) { }
	
	/// Common action for radio buttons.
	@IBAction func selectEngine(_ sender: Any?) { }
	
	@IBAction func ok(_ sender: Any?) {
		guard let window else { return }
		window.sheetParent?.endSheet(window, returnCode: .OK)
		window.close()
	}
	
	@IBAction func cancel(_ sender: Any?) {
		guard let window else { return }
		window.sheetParent?.endSheet(window, returnCode: .cancel)
		window.close()
	}
	
	// MARK: - NSWindowController methods

	/// This gets called if we do `init(window: nil)`.
	override var windowNibName : NSNib.Name? {
		return NSNib.Name(rawValue: "NewGameDialogController")
	}
    
}
