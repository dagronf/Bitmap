//
//  Copyright © 2025 Darren Ford. All rights reserved.
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
	/// - Parameters:
	///   - direction: The direction of scrolling to apply
	///   - count: The number of pixels to scroll
	///   - wrapsContent: Should the content wrap when scrolled?
	func scroll(direction: ScrollDirection, count: Int = 1, wrapsContent: Bool = true) {
		// If the row count to scroll is zero, return early
		if count == 0 { return }

		switch direction {
		case .down:
			self.scrollVertically(isScrollingDown: true, count: count, wrapsContent: wrapsContent)
		case .up:
			self.scrollVertically(isScrollingDown: false, count: count, wrapsContent: wrapsContent)
		case .left:
			self.scrollHorizonally(isScrollingRight: false, count: count, wrapsContent: wrapsContent)
		case .right:
			self.scrollHorizonally(isScrollingRight: true, count: count, wrapsContent: wrapsContent)
		}
	}

	/// Create a new bitmap by scrolling the bitmap, wrapping the content around the boundary
	/// - Parameters:
	///   - direction: The direction of scrolling to apply
	///   - count: The number of rows or columns to scroll by
	///   - wrapsContent: Should the content wrap when scrolled?
	/// - Returns: A new image with the original image scrolled
	func scrolling(direction: ScrollDirection, count: Int = 1, wrapsContent: Bool = true) throws -> Bitmap {
		try self.makingCopy { copy in
			copy.scroll(direction: direction, count: count, wrapsContent: wrapsContent)
		}
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
	func scrollVertically(isScrollingDown: Bool, count: Int, wrapsContent: Bool) {
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

		let topSlice = (!wrapsContent && !isScrollingDown) ? Array(repeating: 0, count: splitPosition) : Array(self.rgbaBytes[..<splitPosition])
		let bottomSlice = (!wrapsContent && isScrollingDown) ? Array(repeating: 0, count: self.rgbaBytes.count - splitPosition) : Array(self.rgbaBytes[splitPosition...])

		let all: [UInt8] = bottomSlice + topSlice

		self.bitmapData.setBytes(all)
	}

	func scrollHorizonally(isScrollingRight: Bool, count: Int, wrapsContent: Bool) {
		var result: [UInt8] = []
		let pixelWidth = 4
		let rowWidth = width * pixelWidth
		let zeroed: [UInt8] = Array(repeating: 0, count: rowWidth)
		let zeroedSlice = zeroed[0 ..< rowWidth]
		for y in stride(from: 0, to: height * rowWidth, by: rowWidth) {
			let rowSlice = bitmapData.rgbaBytes[y ..< y + rowWidth]

			let left: ArraySlice<UInt8>
			let right: ArraySlice<UInt8>
			if isScrollingRight {
				left =  rowSlice[rowSlice.startIndex ..< rowSlice.endIndex - (count * 4)]
				right = !wrapsContent ? zeroedSlice[0 ..< (count * 4)] : rowSlice[rowSlice.endIndex - (count * 4) ..< rowSlice.endIndex]
			}
			else { // direction == .left
				left = !wrapsContent ? zeroedSlice[0 ..< (count * 4)] : rowSlice[rowSlice.startIndex ..< rowSlice.startIndex + (count * 4)]
				right = rowSlice[rowSlice.startIndex + (count * 4) ..< rowSlice.endIndex]
			}

			result.append(contentsOf: right)
			result.append(contentsOf: left)
		}
		self.bitmapData.setBytes(result)
	}
}
