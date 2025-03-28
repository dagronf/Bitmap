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

// MARK: - Drawing

extension Bitmap {
	/// Perform 'block' within a saved GState on a bitmap
	/// - Parameter block: The block to perform with a new graphics state
	@inlinable @inline(__always)
	internal func savingGState(_ block: (CGContext) -> Void) {
		self.bitmapContext.savingGState(block)
	}

	/// Perform drawing actions within a saved GState on a bitmap
	/// - Parameter block: The block to perform within a new graphics state using the bitmap's context
	@inlinable @inline(__always)
	public func draw(_ block: (CGContext) -> Void) {
		self.savingGState(block)
	}

	/// Performs drawing operations on a copy of this bitmap
	/// - Parameter block: The block to perform within a new graphics state using the bitmap's context
	/// - Returns: A new bitmap
	func drawing(_ block: (CGContext) -> Void) throws -> Bitmap {
		try self.makingCopy { copy in
			copy.draw(block)
		}
	}
}
