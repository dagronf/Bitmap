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
	/// Tint this bitmap with a color
	/// - Parameters:
	///   - color: The tinting color
	///   - intensity: The tinting intensity (0 -> 1)
	@inlinable func tint(with color: CGColor, intensity: CGFloat = 1.0) throws {
		try self.replaceContent(with: try self.tinting(with: color, intensity: intensity))
	}
}

public extension Bitmap {
	/// Tint an area within a bitmap with a specific color
	/// - Parameters:
	///   - color: The tint color
	///   - rect: The rect within the bitmap to tint
	///   - intensity: The color intensity (0.0 -> 1.0)
	func tint(with color: CGColor, in rect: CGRect, intensity: CGFloat = 1.0) throws {
		// Crop out the part to be tinted
		let component = try self.cropping(to: rect)

		// Tint this component
		let tinted = try component.tinting(with: color, intensity: intensity)
		guard let ti = tinted.cgImage else { throw BitmapError.cannotCreateCGImage }

		// And draw the tinted part back into the original image
		try self.drawBitmap(ti, in: rect)
	}

	/// Tint an area within a bitmap with a specific color
	/// - Parameters:
	///   - color: The tint color
	///   - rect: The rect within the bitmap to tint
	///   - intensity: The color intensity (0.0 -> 1.0)
	/// - Returns: A new bitmap 
	func tinting(with color: CGColor, in rect: CGRect, intensity: CGFloat = 1.0) throws -> Bitmap {
		try makingCopy { copy in
			try copy.tint(with: color, in: rect, intensity: intensity)
		}
	}
}

#if canImport(CoreImage)

public extension Bitmap {
	/// Returns a new image tinted with a color
	/// - Parameters:
	///   - color: The tint color
	///   - intensity: The tinting intensity (0 -> 1)
	/// - Returns: A new bitmap tinted with the specified color
	func tinting(with color: CGColor, intensity: CGFloat = 1.0) throws -> Bitmap {
		guard
			let filter = CIFilter(
				name: "CIColorMonochrome",
				parameters: [
					"inputImage": self.ciImage as Any,
					"inputColor": CIColor(cgColor: color),
					"inputIntensity": 1.0,
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

	/// Returns a new image tinted with a color
	/// - Parameters:
	///   - color: The tint color
	///   - intensity: The tinting intensity (0 -> 1)
	/// - Returns: A new bitmap tinted with the specified color
	func tinting(with color: CGColor, intensity: CGFloat = 1.0) throws -> Bitmap {
		guard let cgImage = self.cgImage else { throw BitmapError.cannotCreateCGImage }
		let rect = CGRect(origin: .zero, size: size)
		return try Bitmap(size: size) { ctx in
			// draw black background to preserve color of transparent pixels
			ctx.setBlendMode(.normal)
			ctx.setFillColor(.standard.black)
			ctx.fill([rect])

			// Draw the image
			ctx.setBlendMode(.normal)
			ctx.draw(cgImage, in: rect)

			// tint image (losing alpha) - the luminosity of the original image is preserved
			ctx.setBlendMode(.color)
			ctx.setFillColor(color)
			ctx.fill([rect])

			// mask by alpha values of original image
			ctx.setBlendMode(.destinationIn)
			ctx.draw(cgImage, in: rect)
		}
	}
}

#endif
