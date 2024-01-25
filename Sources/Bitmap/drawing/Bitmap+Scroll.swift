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

// MARK: - Scroll

public extension Bitmap {
	/// Scroll directions
	enum ScrollDirection {
		/// Scroll down
		case down
		/// Scroll up
		case up
	}

	/// Scroll the bitmap, wrapping the content around the boundary
	/// - Parameter direction: The direction of scrolling to apply
	/// - Parameter rowCount: The number of rows to scroll
	mutating func scroll(direction: ScrollDirection, rowCount: Int = 1) {
		// If the row count to scroll is zero, return early
		if rowCount == 0 { return }

		assert(rowCount >= 1)
		assert(rowCount < self.height)

		let splitSize = self.width * 4 * rowCount
		var splitPosition = 0
		switch direction {
		case .down:
			splitPosition = self.rgbaBytes.count - splitSize
		case .up:
			splitPosition = splitSize
		}

		let topSlice = Array(self.rgbaBytes[..<splitPosition])
		let bottomSlice = Array(self.rgbaBytes[splitPosition...])
		let all: [UInt8] = bottomSlice + topSlice

		self.bitmapData.setBytes(all)
	}

	/// Create a new bitmap by scrolling the bitmap, wrapping the content around the boundary
	/// - Parameter direction: The direction of scrolling to apply
	/// - Parameter rowNum: The number of rows to scroll
	/// - Returns: A new image with the original image scrolled
	func scrolling(direction: ScrollDirection, rowCount: Int = 1) throws -> Bitmap {
		var copy = try self.copy()
		copy.scroll(direction: direction, rowCount: rowCount)
		return copy
	}
}
