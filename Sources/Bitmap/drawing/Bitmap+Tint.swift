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
	/// Tint an area within a bitmap with a specific color
	mutating func tint(with color: CGColor, in rect: CGRect, keepingAlpha: Bool = true) throws {
		// Cropping occurs from the start of the image data - ie. the top left
		// Our coordinate system is from bottom left.
		var converted = rect
		converted.origin.y = CGFloat(self.height) - rect.minY - rect.height

		// Crop out the part to be tinted
		let component = try self.crop(to: converted)

		// Tint this component
		let tinted = try component.tinting(with: color, keepingAlpha: keepingAlpha)
		guard let ti = tinted.cgImage else { throw BitmapError.cannotCreateCGImage }

		// And draw the tinted part back into the original image
		self.draw(ti, in: rect)
	}

	/// Tint this bitmap with a color
	/// - Parameters:
	///   - color: The tinting color
	///   - keepingAlpha: If true, keeps alpha information from the original image
	@inlinable mutating func tint(with color: CGColor, keepingAlpha: Bool = true) throws {
		self = try self.tinting(with: color, keepingAlpha: keepingAlpha)
	}

	/// Returns a new image tinted with a color
	/// - Parameters:
	///   - color: The tint color
	///   - keepingAlpha: If true, transparency is maintained
	/// - Returns: A new bitmap tinted with the specified color
	func tinting(with color: CGColor, keepingAlpha: Bool = true) throws -> Bitmap {
		guard let cgImage = self.cgImage else { throw BitmapError.cannotCreateCGImage }
		let rect = CGRect(origin: .zero, size: size)
		return try Bitmap(size: size) { ctx in
			// draw black background to preserve color of transparent pixels
			ctx.setBlendMode(.normal)
			ctx.setFillColor(.black)
			ctx.fill([rect])

			// Draw the image
			ctx.setBlendMode(.normal)
			ctx.draw(cgImage, in: rect)

			// tint image (losing alpha) - the luminosity of the original image is preserved
			ctx.setBlendMode(.color)
			ctx.setFillColor(color)
			ctx.fill([rect])

			if keepingAlpha {
				// mask by alpha values of original image
				ctx.setBlendMode(.destinationIn)
				ctx.draw(cgImage, in: rect)
			}
		}
	}

	/// Return a grayscape version of this bitmap
	/// - Parameter keepingAlpha: If true, transparency is maintained
	/// - Returns: A grayscale bitmap
	func grayscale(keepingAlpha: Bool = true) throws -> Bitmap {
		guard let cgImage = self.cgImage else { throw BitmapError.cannotCreateCGImage }

		// Create a grayscale context
		guard let ctx = CGContext(
			data: nil,
			width: width,
			height: height,
			bitsPerComponent: 8,
			bytesPerRow: 0,
			space: CGColorSpaceCreateDeviceGray(),
			bitmapInfo: keepingAlpha ? CGImageAlphaInfo.premultipliedLast.rawValue : CGImageAlphaInfo.none.rawValue
		)
		else {
			throw BitmapError.invalidContext
		}

		/// Draw the image into the new context
		let imageRect = CGRect(origin: .zero, size: size)

		/// Draw the image
		ctx.draw(cgImage, in: imageRect)

		if keepingAlpha {
			ctx.setBlendMode(.destinationIn)
			ctx.clip(to: imageRect, mask: cgImage)
		}

		guard let image = ctx.makeImage() else {
			throw BitmapError.cannotCreateCGImage
		}
		return try Bitmap(image)
	}
}
