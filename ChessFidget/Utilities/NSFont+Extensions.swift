//
//  NSFont+Extensions.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/6/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

extension NSFont {
	/// Adjusts the font size so that the given string will fit into an area of
	/// the given size with the given padding.  Based on
	/// [an answer from Peter Hosey](http://stackoverflow.com/a/7274302) on
	/// Stack Overflow.
	func sizedToFit(string: String, into area: CGSize, padding: CGFloat = 10.0) -> NSFont? {
		// Use standard size to prevent error accrual.
		guard let sampleFont = NSFont(descriptor: self.fontDescriptor, size: 12.0) else {
			return nil
		}
		let sampleSize = string.size(withAttributes:[NSAttributedStringKey.font: sampleFont])
		let scale = scaleToAspectFit(source: sampleSize, into: area, padding: padding)
		return NSFont(descriptor: self.fontDescriptor, size: scale * sampleFont.pointSize)
	}

	// MARK: - Private methods

	/// What scaling factor will snugly fit the source in the destination?
	private func scaleToAspectFit(source: CGSize, into: CGSize, padding: CGFloat) -> CGFloat {
		return min((into.width - padding)/source.width, (into.height - padding)/source.height)
	}
}

