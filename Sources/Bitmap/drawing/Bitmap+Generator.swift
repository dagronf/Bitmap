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

#if canImport(CoreImage)

import Foundation
import CoreGraphics
import CoreImage

public extension Bitmap {
	/// Create a bitmap containing a checkerboard pattern
	/// - Parameters:
	///   - width: The bitmap width
	///   - height: The bitmap height
	///   - center: The center point for the pattern
	///   - checkSize: The size of the check
	///   - color0: odd color
	///   - color1: even color
	/// - Returns: A bitmap containing a checkerboard pattern
	static func Checkerboard(
		width: Int,
		height: Int,
		center: CGPoint? = nil,
		checkSize: CGFloat = 20,
		color0: CGColor = .black,
		color1: CGColor = .white
	) throws -> Bitmap {
		var bitmap = try Bitmap(width: width, height: height)
		let center = center ?? CGPoint(x: 150.0, y: 150.0)
		guard
			let filter = CIFilter(
				name: "CICheckerboardGenerator",
				parameters: [
					"inputCenter": CIVector(cgPoint: center),
					"inputColor0": CIColor(cgColor: color0),
					"inputColor1": CIColor(cgColor: color1),
					"inputWidth": checkSize,
					"inputSharpness": 1.0,
				]
			),
			let check = filter.outputImage,
			let cgImage = CIContext().createCGImage(check, from: bitmap.bounds)
		else {
			throw BitmapError.cannotFilter
		}
		bitmap.drawImage(cgImage, atPoint: .zero)
		return bitmap
	}
}

#endif
