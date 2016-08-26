//
//  NSRect+Extensions.swift
//  ChessFidget
//
//  Created by Andy Lee on 8/25/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

import Foundation

extension NSRect {
	func insetBy(fraction: CGFloat) -> NSRect {
		return insetBy(dx: fraction * size.width, dy: fraction * size.height)
	}
}



