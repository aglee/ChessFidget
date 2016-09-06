//
//  NSRect+Extensions.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Foundation

extension NSRect {
	func insetBy(widthFraction: CGFloat, heightFraction: CGFloat) -> NSRect {
		return insetBy(dx: widthFraction * size.width, dy: heightFraction * size.height)
	}

	func insetBy(fraction: CGFloat) -> NSRect {
		return insetBy(dx: fraction * size.width, dy: fraction * size.height)
	}
}



