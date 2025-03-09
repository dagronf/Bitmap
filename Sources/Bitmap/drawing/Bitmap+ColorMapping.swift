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

// MARK: - Mapping colors

public extension Bitmap {
	/// Map one color in the bitmap to another color
	/// - Parameters:
	///   - color: The color to replace
	///   - replacementColor: The color to replace with
	///   - includeTransparencyInCheck: If true, the pixel's alpha is used in the comparison check
	/// - Returns: self
	@discardableResult
	func mapColor(
		_ color: Bitmap.RGBA,
		to replacementColor: Bitmap.RGBA,
		includeTransparencyInCheck: Bool = true
	) -> Bitmap {
		self.bitmapData.rgbaBytes.withUnsafeMutableBytes { buffer in
			for p in stride(from: 0, to: buffer.count, by: 4) {
				if buffer[p] == color.r,
					buffer[p + 1] == color.g,
					buffer[p + 2] == color.b,
					(includeTransparencyInCheck == false || (buffer[p + 3] == color.a))
				{
					buffer[p] = replacementColor.r
					buffer[p + 1] = replacementColor.g
					buffer[p + 2] = replacementColor.b
					buffer[p + 3] = replacementColor.a
				}
			}
		}
		return self
	}

	/// Map one color in the bitmap to another color, returning a new bitmap
	/// - Parameters:
	///   - color: The color to replace
	///   - replacementColor: The color to replace with
	///   - includeTransparencyInCheck: If true, the pixel's alpha is used in the comparison check
	/// - Returns: self
	func mappingColor(
		_ color: Bitmap.RGBA,
		to replacementColor: Bitmap.RGBA,
		includeTransparencyInCheck: Bool = true
	) throws -> Bitmap {
		try self.copy()
			.mapColor(color, to: replacementColor, includeTransparencyInCheck: includeTransparencyInCheck)
	}
}
