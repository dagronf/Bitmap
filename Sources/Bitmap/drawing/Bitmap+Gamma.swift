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
	/// Adjusts midtone brightness
	/// - Parameter power: The input power. The larger the value, the darker the result
	@inlinable func adjustGamma(power: Double) throws {
		try self.replaceContents(with: try self.adjustingGamma(power: power))
	}
}

#if canImport(CoreImage)

public extension Bitmap {
	/// Adjusts midtone brightness
	/// - Parameter power: The input power. The larger the value, the darker the result
	/// - Returns: A new bitmap
	func adjustingGamma(power: Double) throws -> Bitmap {
		guard
			let filter = CIFilter(
				name: "CIGammaAdjust",
				parameters: [
					"inputImage": self.ciImage as Any,
					"inputPower": power,
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

public extension Bitmap {
	func adjustingGamma(power: Double) throws -> Bitmap {
		throw BitmapError.notImplemented
	}
}

#endif
