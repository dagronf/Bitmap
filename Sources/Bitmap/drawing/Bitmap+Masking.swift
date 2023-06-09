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
	/// Mask this image using an image mask
	/// - Parameter maskImage: the mask image
	@inlinable mutating func mask(using maskImage: CGImage) throws {
		let copy = try self.masking(using: maskImage)
		self = copy
	}

	/// Mask this image using an image mask
	/// - Parameter maskBitmap: The mask image
	@inlinable mutating func mask(using maskBitmap: Bitmap) throws {
		let copy = try self.masking(using: maskBitmap)
		self = copy
	}

	/// Mask this bitmap using a mask bitmap
	/// - Parameter maskBitmap: The mask bitmap
	/// - Returns: A new bitmap
	@inlinable func masking(using maskBitmap: Bitmap) throws -> Bitmap {
		guard let origImage = maskBitmap.cgImage else { throw BitmapError.cannotCreateCGImage }
		return try self.masking(using: origImage)
	}

	/// Mask this bitmap using a mask image
	/// - Parameter maskBitmap: The mask image
	/// - Returns: A new bitmap
	func masking(using maskImage: CGImage) throws -> Bitmap {
		guard let origImage = self.cgImage else { throw BitmapError.cannotCreateCGImage }
		let origRect = self.bounds
		var bitmap = try Bitmap(size: origRect.size)
		bitmap.draw { ctx in
			ctx.clip(to: origRect, mask: maskImage)
			ctx.draw(origImage, in: origRect)
		}
		return bitmap
	}
}
