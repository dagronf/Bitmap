//
//  Copyright © 2023 Darren Ford. All rights reserved.
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

// MARK: - Scroll

public extension Bitmap {
	/// Scroll directions
	enum ScrollDirection {
		/// Scroll down
		case down
		/// Scroll up
		case up
	}

	/// Scroll this bitmap
	/// - Parameter direction: The direction of scrolling to apply
	/// - Parameter rowNum: The number of row to scroll
	mutating func scroll(direction: ScrollDirection, rowNum: Int = 1) {
		let splitSize = self.width * 4 * rowNum
		var splitPosition = 0
		switch direction {
		case .down:
			splitPosition = self.rgbaBytes.count - splitSize
		case .up:
			splitPosition = splitSize
		}

		let topSlice = self.rgbaBytes[..<splitPosition]
		let bottomSlice = self.rgbaBytes[splitPosition...]
		self.bitmapData = RGBAData(width: self.width, height: self.height, rgbaBytes: Array(bottomSlice) + Array(topSlice))
	}

	/// Create a new bitmap by scrolling this bitmap
	/// - Parameter direction: The direction of scrolling to apply
	/// - Parameter rowNum: The number of row to scroll
	/// - Returns: A new image with the original image scrolled
	func scrolling(direction: ScrollDirection, rowNum: Int = 1) throws -> Bitmap {
		var copy = try self.copy()
		copy.scroll(direction: direction, rowNum: rowNum)
		return copy
	}
}
