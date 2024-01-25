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

#if canImport(CoreImage)

import CoreImage
//import CIFilterFactory

// MARK: - CoreImage routines

public extension Bitmap {
	/// Tint this bitmap with a color
	/// - Parameters:
	///   - color: The tinting color
	///   - intensity: The tinting intensity (0 -> 1)
	@inlinable mutating func tint(with color: CGColor, intensity: CGFloat = 1.0) throws {
		self = try self.tinting(with: color, intensity: intensity)
	}

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

public extension Bitmap {
	/// Apply a grayscale filter to this bitmap
	@inlinable mutating func grayscale() throws {
		self = try self.grayscaling()
	}

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

public extension Bitmap {
	/// Adjusts midtone brightness
	/// - Parameter power: The input power. The larger the value, the darker the result
	@inlinable mutating func adjustGamma(power: Double) throws {
		self = try self.adjustingGamma(power: power)
	}

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

public extension Bitmap {
	/// Adjust saturation, brightness, and contrast values.
	/// - Parameters:
	///   - saturation: The amount of saturation to apply. The larger the value, the more saturated the result.
	///   - brightness: The amount of brightness to apply. The larger the value, the brighter the result.
	///   - contrast: The amount of contrast to apply. The larger the value, the more contrast in the resulting image.
	@inlinable mutating func adjustColorControls(
		saturation: Double = 1.0,
		brightness: Double = 0.0,
		contrast: Double = 1.0
	) throws {
		self = try self.adjustingColorControls(saturation: saturation, brightness: brightness, contrast: contrast)
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
//			let filter = CIFF.ColorControls(
//				inputImage: self.ciImage,
//				saturation: saturation,
//				brightness: brightness,
//				contrast: contrast),
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
	/// Apply a grayscale filter to this bitmap
	@inlinable mutating func grayscale() throws {
		self = try self.grayscaling()
	}

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

public extension Bitmap {
	/// Tint this bitmap with a color
	/// - Parameters:
	///   - color: The tinting color
	///   - intensity: The tinting intensity (0 -> 1)
	@inlinable mutating func tint(with color: CGColor, intensity: CGFloat = 1.0) throws {
		self = try self.tinting(with: color, intensity: intensity)
	}

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
			ctx.setFillColor(.black)
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

#endif  // canImport(CoreImage)

// MARK: - Common

public extension Bitmap {
	/// Tint an area within a bitmap with a specific color
	/// - Parameters:
	///   - color: The tint color
	///   - rect: The rect within the bitmap to tint
	///   - intensity: The color intensity (0.0 -> 1.0)
	func tinting(with color: CGColor, in rect: CGRect, intensity: CGFloat = 1.0) throws -> Bitmap {
		var copy = try self.copy()
		try copy.tint(with: color, in: rect, intensity: intensity)
		return copy
	}

	/// Tint an area within a bitmap with a specific color
	/// - Parameters:
	///   - color: The tint color
	///   - rect: The rect within the bitmap to tint
	///   - intensity: The color intensity (0.0 -> 1.0)
	mutating func tint(with color: CGColor, in rect: CGRect, intensity: CGFloat = 1.0) throws {
		// Cropping occurs from the start of the image data - ie. the top left
		// Our coordinate system is from bottom left.
		var converted = rect
		converted.origin.y = CGFloat(self.height) - rect.minY - rect.height

		// Crop out the part to be tinted
		let component = try self.cropping(to: converted)

		// Tint this component
		let tinted = try component.tinting(with: color, intensity: intensity)
		guard let ti = tinted.cgImage else { throw BitmapError.cannotCreateCGImage }

		// And draw the tinted part back into the original image
		self.drawImage(ti, in: rect)
	}
}

public extension Bitmap {
	/// Remove transparency
	/// - Parameter backgroundColor: The background color
	@inlinable mutating func removeTransparency(backgroundColor: CGColor = .black) throws {
		self = try self.removingTransparency(backgroundColor: backgroundColor)
	}

	/// Remove transparency
	/// - Parameter backgroundColor: The background color
	/// - Returns: A new bitmap with transparency removed
	func removingTransparency(backgroundColor: CGColor = .black) throws -> Bitmap {
		var newBitmap = try Bitmap(size: self.size)
		newBitmap.fill(backgroundColor)
		try newBitmap.drawBitmap(self, atPoint: .zero)
		return newBitmap
	}
}
