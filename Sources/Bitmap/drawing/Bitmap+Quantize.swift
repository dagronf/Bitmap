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

import Foundation
import CoreGraphics

public extension Bitmap {
	/// Return a new bitmap by quanitzing to a black white image
	/// - Parameter midPointValue: The midpoint value (the gray value that defines the midpoint between black and white)
	/// - Returns: A new bitmap
	func quantizingBlackWhite(_ midPointValue: UInt8) throws -> Bitmap {
		let gray = try self.grayscaling()
		for y in (0 ..< self.height) {
			for x in (0 ..< self.width) {
				let value = gray[x, y].r > midPointValue ? 1.0 : 0.0
				gray[x, y] = RGBA(rf: value, gf: value, bf: value, af: 1)
			}
		}
		return gray
	}

	/// Quanitze to a black white image by setting a midpoint value
	/// - Parameter midPointValue: The midpoint value (the gray value that defines the midpoint between black and white)
	@inlinable
	func quantizeBlackWhite(_ midPointValue: UInt8) throws {
		try self.replaceContent(with: try self.quantizingBlackWhite(midPointValue))
	}
}

public extension Bitmap {
	/// Quantize the bitmap to a fixed number of (equally sized) gray buckets
	/// - Parameter bucketCount: The number of gray buckets
	/// - Returns: A new bitmap
	func quantizingGray(bucketCount: UInt8) throws -> Bitmap {
		precondition(bucketCount > 1)
		// Convert to gray
		let gray = try self.grayscaling()

		let bucketSize = UInt8(255.0 / Double(bucketCount))

		for y in (0 ..< self.height) {
			for x in (0 ..< self.width) {
				let orig = gray[x, y].r
				let which = (orig / bucketSize) * bucketSize
				gray[x, y] = RGBA(r: which, g: which, b: which, a: 255)
			}
		}
		return gray
	}

	/// Quantize the bitmap to a fixed number of (equally sized) gray buckets
	/// - Parameter bucketCount: The number of gray buckets
	@inlinable
	func quantizeGray(bucketCount: UInt8) throws {
		try self.replaceContent(with: try self.quantizingGray(bucketCount: bucketCount))
	}
}
