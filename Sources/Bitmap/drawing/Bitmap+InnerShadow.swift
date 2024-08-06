//
//  Copyright © 2024 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import CoreGraphics

// MARK: - Inner shadows

public extension Bitmap {
	/// Draw a path using an inner shadow
	/// - Parameters:
	///   - path: The path
	///   - fillColor: The color to fill the path, or nil for no color
	///   - shadow: The shadow definition
	func drawInnerShadow(_ path: CGPath, fillColor: CGColor? = nil, shadow: Bitmap.Shadow) {
		self.draw { ctx in
			if let fillColor = fillColor {
				ctx.setFillColor(fillColor)
				ctx.addPath(path)
				ctx.fillPath()
			}
			ctx.drawInnerShadow(in: path, shadowColor: shadow.color, offset: shadow.offset, blurRadius: shadow.blur)
		}
	}

	/// Create a new bitmap by drawing a path using an inner shadow
	/// - Parameters:
	///   - path: The path
	///   - fillColor: The color to fill the path, or nil for no color
	///   - shadow: The shadow definition
	/// - Returns: A new bitmap
	func drawingInnerShadow(_ path: CGPath, fillColor: CGColor? = nil, shadow: Bitmap.Shadow) throws -> Bitmap {
		let copy = try self.copy()
		copy.drawInnerShadow(path, fillColor: fillColor, shadow: shadow)
		return copy
	}
}
