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
	/// Perform a drawing operation clipped to a path
	/// - Parameters:
	///   - clippingPath: The path to clip to
	///   - drawBlock: The drawing operation(s)
	@available(*, deprecated, renamed: "clip", message: "clipped had been renamed to clip")
	func clipped(to clippingPath: CGPath, _ drawBlock: (CGContext) -> Void) {
		self.clip(to: clippingPath, drawBlock)
	}

	/// Perform a drawing operation in this bitmap clipped to a path
	/// - Parameters:
	///   - clippingPath: The path to clip to
	///   - drawBlock: The drawing operation(s)
	func clip(to clippingPath: CGPath, _ drawBlock: (CGContext) -> Void) {
		self.savingGState { ctx in
			ctx.addPath(clippingPath)
			ctx.clip()
			drawBlock(ctx)
		}
	}

	/// Perform a clipped drawing operation on a copy of this bitmap
	/// - Parameters:
	///   - clippingPath: The path to clip to
	///   - drawBlock: The drawing operation(s)
	/// - Returns: A bitmap
	@inlinable func clipping(to clippingPath: CGPath, _ drawBlock: (CGContext) -> Void) throws -> Bitmap {
		let copy = try self.copy()
		copy.clip(to: clippingPath, drawBlock)
		return copy
	}
}
