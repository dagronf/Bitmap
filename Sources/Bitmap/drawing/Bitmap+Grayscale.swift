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

#if canImport(CoreImage)
import CoreImage
#endif

public extension Bitmap {
	/// Apply a grayscale filter to this bitmap
	@inlinable func grayscale() throws {
		try self.replaceContent(with: try self.grayscaling())
	}
}

#if canImport(CoreImage)

public extension Bitmap {
	/// Return a grayscale representation of this bitmap
	/// - Returns: A grayscale bitmap
	func grayscaling() throws -> Bitmap {
		guard
			let filter = CIFilter(
				name: "CIPhotoEffectMono",
				parameters: [
					"inputImage": self.ciImage as Any,
				]
			),
			let output = filter.outputImage
		else {
			throw BitmapError.cannotCreateCGImage
		}
		return try Bitmap(output)
	}
}

#else

// MARK: - Non CoreImage routines

public extension Bitmap {
	/// Return a grayscale representation of this bitmap
	/// - Returns: A grayscale bitmap
	func grayscaling() throws -> Bitmap {
		guard let cgImage = self.cgImage else { throw BitmapError.cannotCreateCGImage }

		// Create a grayscale context
		guard let ctx = CGContext(
			data: nil,
			width: width,
			height: height,
			bitsPerComponent: 8,
			bytesPerRow: 0,
			space: CGColorSpaceCreateDeviceGray(),
			bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
		)
		else {
			throw BitmapError.invalidContext
		}

		/// Draw the image into the new context
		let imageRect = CGRect(origin: .zero, size: size)

		/// Draw the image
		ctx.draw(cgImage, in: imageRect)

		ctx.setBlendMode(.destinationIn)
		ctx.clip(to: imageRect, mask: cgImage)

		guard let image = ctx.makeImage() else {
			throw BitmapError.cannotCreateCGImage
		}
		return try Bitmap(image)
	}
}

#endif
