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
import CoreGraphics

// MARK: - Resizing

public extension Bitmap {
	/// Resizes the bitmap around the centroid of the current image, cropping or extending
	/// the current bitmap as required
	/// - Parameter size: The size of the new image
	/// - Returns: A new bitmap
	func resizing(to size: CGSize) throws -> Bitmap {
		var result = try Bitmap(size: size)
		let woffset = (size.width - self.size.width) / 2
		let hoffset = (size.height - self.size.height) / 2
		try result.draw(image: self, atPoint: CGPoint(x: woffset, y: hoffset))
		return result
	}

	/// Resizes the bitmap around the centroid of the current image, cropping or extending
	/// the current bitmap as required
	/// - Parameter size: The new size for the bitmap
	@inlinable mutating func resize(to size: CGSize) throws {
		self = try self.resizing(to: size)
	}
}
