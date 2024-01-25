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

import CoreGraphics
import Foundation

public extension Bitmap {
	/// Punch a transparent hole in this bitmap
	/// - Parameter path: The hole's path
	mutating func punchTransparentHole(path: CGPath) throws {
		self = try self.punchingTransparentHole(path: path)
	}

	/// Punch a transparent hole in this bitmap
	/// - Parameter rect: The rect to punch out
	@inlinable mutating func punchTransparentHole(rect: CGRect) throws {
		try self.punchTransparentHole(path: rect.path)
	}

	/// Create a new bitmap by punching a transparent hole in this bitmap
	/// - Parameter path: The hole's path
	/// - Returns: A new bitmap
	func punchingTransparentHole(path: CGPath) throws -> Bitmap {
		guard let cgImage = self.cgImage else { throw BitmapError.cannotCreateCGImage }
		var copy = try Bitmap(size: self.size)
		let bounds = copy.bounds
		copy.draw { ctx in
			ctx.addRect(bounds)
			ctx.addPath(path)
			ctx.clip(using: .evenOdd)
			drawImageInContext(ctx, image: cgImage, rect: bounds)
		}
		return copy
	}

	/// Create a new bitmap by punching a transparent hole in this bitmap
	/// - Parameter rect: The rect to punch out
	/// - Returns: A new bitmap
	@inlinable mutating func punchingTransparentHole(rect: CGRect) throws -> Bitmap {
		try self.punchingTransparentHole(path: rect.path)
	}
}
