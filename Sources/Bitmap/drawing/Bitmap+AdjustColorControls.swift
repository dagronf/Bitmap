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

// MARK: - CoreImage routines

public extension Bitmap {
	/// Adjust saturation, brightness, and contrast values.
	/// - Parameters:
	///   - saturation: The amount of saturation to apply. The larger the value, the more saturated the result.
	///   - brightness: The amount of brightness to apply. The larger the value, the brighter the result.
	///   - contrast: The amount of contrast to apply. The larger the value, the more contrast in the resulting image.
	@inlinable func adjustColorControls(
		saturation: Double = 1.0,
		brightness: Double = 0.0,
		contrast: Double = 1.0
	) throws {
		try self.replaceContent(
			with: try self.adjustingColorControls(
				saturation: saturation,
				brightness: brightness,
				contrast: contrast
			)
		)
	}

	/// Adjust saturation, brightness, and contrast values.
	/// - Parameters:
	///   - saturation: The amount of saturation to apply. The larger the value, the more saturated the result.
	///   - brightness: The amount of brightness to apply. The larger the value, the brighter the result.
	///   - contrast: The amount of contrast to apply. The larger the value, the more contrast in the resulting image.
	/// - Returns: A new bitmap
	func adjustingColorControls(
		saturation: Double = 1.0,
		brightness: Double = 0.0,
		contrast: Double = 1.0
	) throws -> Bitmap {
		guard
			let filter = CIFilter(
				name: "CIColorControls",
				parameters: [
					"inputImage": self.ciImage as Any,
					"inputSaturation": 1.0,
					"inputBrightness": 0.0,
					"inputContrast": 1.0,
				]
			),
			let output = filter.outputImage
		else {
			throw BitmapError.cannotCreateCGImage
		}
		return try Bitmap(output)
	}
}

#endif  // canImport(CoreImage)
