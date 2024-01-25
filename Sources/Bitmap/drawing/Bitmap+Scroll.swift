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

/// Based on work by [BenedictSt](https://github.com/BenedictSt)
/// See PR [here](https://github.com/dagronf/Bitmap/pull/1)

import Foundation

// MARK: - Scroll

public extension Bitmap {
	/// Scroll directions
	enum ScrollDirection {
		/// Scroll down
		case down
		/// Scroll up
		case up
		/// Scroll left
		case left
		/// Scroll right
		case right
	}

	/// Scroll the bitmap, wrapping the content around the boundary
	/// - Parameter direction: The direction of scrolling to apply
	/// - Parameter count: The number of rows to scroll
	func scroll(direction: ScrollDirection, count: Int = 1) {
		// If the row count to scroll is zero, return early
		if count == 0 { return }

		switch direction {
		case .down:
			self.scrollVertically(isScrollingDown: true, count: count)
		case .up:
			self.scrollVertically(isScrollingDown: false, count: count)
		case .left:
			self.scrollHorizonally(isScrollingRight: false, count: count)
		case .right:
			self.scrollHorizonally(isScrollingRight: true, count: count)
		}
	}

	/// Create a new bitmap by scrolling the bitmap, wrapping the content around the boundary
	/// - Parameters:
	///   - direction: The direction of scrolling to apply
	///   - count: The number of rows or columns to scroll by
	/// - Returns: A new image with the original image scrolled
	func scrolling(direction: ScrollDirection, count: Int = 1) throws -> Bitmap {
		let copy = try self.copy()
		copy.scroll(direction: direction, count: count)
		return copy
	}
}

// MARK: - Zero point

public extension Bitmap {
	/// Reorient the bitmap around the new coordinate
	/// - Parameters:
	///   - x: The new x-coordinate to reorient to x=0
	///   - y: The new y-coordinate to reorient to y=0
	func zeroPoint(x: Int, y: Int) {
		assert(x >= 0 && x < self.width)
		assert(y >= 0 && y < self.height)
		self.scroll(direction: .left, count: x)
		self.scroll(direction: .down, count: y)
	}

	/// Create a new bitmap by reorienting this bitmap around the new coordinate
	/// - Parameters:
	///   - x: The new x-coordinate to reorient to x=0
	///   - y: The new y-coordinate to reorient to y=0
	func zeroingPoint(x: Int, y: Int) throws -> Bitmap {
		let copy = try self.copy()
		copy.zeroPoint(x: x, y: y)
		return copy
	}
}

private extension Bitmap {
	func scrollVertically(isScrollingDown: Bool, count: Int) {
		assert(count >= 1)
		assert(count < self.height)

		let splitSize = self.width * 4 * count
		let splitPosition: Int
		if isScrollingDown {
			splitPosition = self.rgbaBytes.count - splitSize
		}
		else {
			splitPosition = splitSize
		}

		let topSlice = Array(self.rgbaBytes[..<splitPosition])
		let bottomSlice = Array(self.rgbaBytes[splitPosition...])
		let all: [UInt8] = bottomSlice + topSlice

		self.bitmapData.setBytes(all)
	}

	func scrollHorizonally(isScrollingRight: Bool, count: Int = 1) {
		var result: [UInt8] = []
		let pixelWidth = 4
		let rowWidth = width * pixelWidth
		for y in stride(from: 0, to: height * rowWidth, by: rowWidth) {
			let rowSlice = bitmapData.rgbaBytes[y ..< y + rowWidth]

			let left: ArraySlice<UInt8>
			let right: ArraySlice<UInt8>
			if isScrollingRight {
				left = rowSlice[rowSlice.startIndex ..< rowSlice.endIndex - (count * 4)]
				right = rowSlice[rowSlice.endIndex - (count * 4) ..< rowSlice.endIndex]
			}
			else { // direction == .left
				left = rowSlice[rowSlice.startIndex ..< rowSlice.startIndex + (count * 4)]
				right = rowSlice[rowSlice.startIndex + (count * 4) ..< rowSlice.endIndex]
			}
			result.append(contentsOf: right)
			result.append(contentsOf: left)
		}
		self.bitmapData.setBytes(result)
	}
}
