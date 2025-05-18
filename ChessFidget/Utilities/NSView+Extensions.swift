//
//  NSView+Extensions.swift
//  ChessFidget
//
//  Created by Andy Lee on 5/17/25.
//  Copyright © 2025 Andy Lee. All rights reserved.
//

import AppKit

extension NSView {
	/// To be used with a view that has radio buttons as subviews.
	func tagOfSelectedButtonSubview() -> Int? {
		let buttons: [NSButton] = subviews.compactMap { $0 as? NSButton }
		let selectedButton = buttons.first { $0.state == .on }
		return selectedButton?.tag ?? nil
	}
	
	/// To be used with a view that has radio buttons as subviews.
	func buttonSubviewWithTag(_ tag: Int) -> NSButton? {
		subviews.compactMap { $0 as? NSButton }.first(where: { $0.tag == tag })
	}
	
	/// To be used with a view that has radio buttons as subviews.
	func selectButtonSubviewWithTag(_ tag: Int) {
		if let button = buttonSubviewWithTag(tag), button.state != .on {
			button.state = .on
		}
	}
}
