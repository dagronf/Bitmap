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
	/// Invert the colors in this bitmap
	@discardableResult
	func invertColors() -> Bitmap {
		self.bitmapData.rgbaBytes.withUnsafeMutableBytes { buffer in
			for p in stride(from: 0, to: buffer.count, by: 4) {
				buffer[p] = 255 - buffer[p]
				buffer[p + 1] = 255 - buffer[p + 1]
				buffer[p + 2] = 255 - buffer[p + 2]
			}
		}
		return self
	}

	/// Make a copy of this bitmap by inverting its colors
	/// - Returns: A new bitmap
	func invertingColors() throws -> Bitmap {
		try self.copy()
			.invertColors()
	}
}
