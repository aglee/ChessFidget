//
//  NSRect+Extensions.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Foundation

extension NSRect {
	/// Example: if `widthFraction` is 0.1 the resulting rectangle will have its
	/// left and right edges each moved inward by 10% of the original width, so
	/// the width of the resulting rectangle will be 80% of the original.  You
	/// can pass negative values, which will cause the corresponding dimension
	/// to increase rather than decrease.
	func insetBy(widthFraction: CGFloat, heightFraction: CGFloat) -> NSRect {
		return insetBy(dx: widthFraction * size.width, dy: heightFraction * size.height)
	}

	/// Calls `insetBy(widthFraction:heightFraction:)`.
	func insetBy(fraction: CGFloat) -> NSRect {
		return insetBy(dx: fraction * size.width, dy: fraction * size.height)
	}
}



