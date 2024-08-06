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

public extension Bitmap {
	/// Draw a line around the border of this bitmap
	/// - Parameter stroke: The type of border line to draw
	func drawBorder(stroke: Stroke = Stroke(color: .standard.black, lineWidth: 1)) {
		let rect = self.bounds.insetBy(dx: stroke.lineWidth / 2.0, dy: stroke.lineWidth / 2.0)
		let path = CGPath(rect: rect, transform: nil)
		self.stroke(path, stroke)
	}

	/// Create a new bitmap by drawing a line around the border of this bitmap
	/// - Parameters:
	///   - stroke: The type of border line to draw
	///   - expanding: If true, expands the size of the resulting bitmap to include the border width
	/// - Returns: A new bitmap
	func drawingBorder(
		stroke: Stroke = Stroke(color: .standard.black, lineWidth: 1),
		expanding: Bool = false
	) throws -> Bitmap {
		var copy: Bitmap
		if expanding {
			let newS = CGSize(
				width: self.size.width + (stroke.lineWidth * 2),
				height: self.size.height + (stroke.lineWidth * 2)
			)
			copy = try self.adjustingSize(to: newS)
		}
		else {
			copy = try self.copy()
		}
		copy.drawBorder(stroke: stroke)
		return copy
	}
}
