//
//  NSFont+Extensions.swift
//  ChessFidget
//
//  Created by Andy Lee on 9/6/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Cocoa

// Tweaked and converted to Swift from Peter Hosey's logic at <http://stackoverflow.com/a/7274302>.
extension NSFont {
	func sizedToFit(string: String, into area: CGSize, padding: CGFloat = 10.0) -> NSFont
	{
		//use standard size to prevent error accrual
		guard let sampleFont = NSFont(descriptor: self.fontDescriptor, size: 12.0) else {
			Swift.print("wtf")
			return self
		}
		let sampleSize = string.size(withAttributes:[NSFontAttributeName: sampleFont])
		let scale = scaleToAspectFit(source: sampleSize, into: area, padding: padding)

		return NSFont(descriptor: self.fontDescriptor, size: scale * sampleFont.pointSize)!
	}

	// MARK: - Private methods

	private func scaleToAspectFit(source: CGSize, into: CGSize, padding: CGFloat) -> CGFloat
	{
		return min((into.width - padding)/source.width, (into.height - padding)/source.height)
	}
	
}

