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

public extension Bitmap {
	/// Remove transparency from this image
	/// - Parameter backgroundColor: The background color
	@inlinable func removeTransparency(backgroundColor: CGColor = .standard.black) throws {
		try self.assign(try self.removingTransparency(backgroundColor: backgroundColor))
	}

	/// Remove transparency from this image
	/// - Parameter backgroundColor: The background color
	/// - Returns: A new bitmap with the transparency removed
	@inlinable func removeTransparency(backgroundColor: Bitmap.RGBA = .black) throws {
		try self.assign(try self.removingTransparency(backgroundColor: backgroundColor))
	}

	/// Create a new image by removing the transparency information from this image
	/// - Parameter backgroundColor: The background color
	/// - Returns: A new bitmap with the transparency removed
	@inlinable func removingTransparency(backgroundColor: Bitmap.RGBA = .black) throws -> Bitmap {
		try self.removingTransparency(backgroundColor: backgroundColor.cgColor)
	}

	/// Create a new image by removing the transparency information from this image
	/// - Parameter backgroundColor: The background color
	/// - Returns: A new bitmap with transparency removed
	func removingTransparency(backgroundColor: CGColor = .standard.black) throws -> Bitmap {
		let newBitmap = try Bitmap(size: self.size, backgroundColor: backgroundColor)
		try newBitmap.drawBitmap(self, atPoint: .zero)
		return newBitmap
	}
}

public extension Bitmap {
	/// Map a specific color in this bitmap to transparency
	/// - Parameter color: The color to map to transparency
	func mapColorToTransparency(_ color: Bitmap.RGBA, includeTransparency: Bool = false) {
		self.bitmapData.rgbaBytes.withUnsafeMutableBytes { buffer in
			for p in stride(from: 0, to: buffer.count, by: 4) {
				if buffer[p] == color.r,
					buffer[p + 1] == color.g,
					buffer[p + 2] == color.b,
					(includeTransparency == false || buffer[p + 3] == color.a)
				{
					buffer[p] = 0
					buffer[p + 1] = 0
					buffer[p + 2] = 0
					buffer[p + 3] = 0
				}
			}
		}
	}

	/// Create a new bitmap by mapping a specific color in this bitmap to transparency
	/// - Parameter color: The color to map to transparency
	func mappingColorToTransparency(_ color: Bitmap.RGBA) throws -> Bitmap {
		let copy = try self.copy()
		copy.mapColorToTransparency(color)
		return copy
	}
}
