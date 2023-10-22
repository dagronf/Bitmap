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

import CoreGraphics
import Foundation

import SwiftImageReadWrite

// MARK: - Import

public extension Bitmap {
	/// Load an image from an image format (eg. png data)
	init(imageData: Data) throws {
		let cgImage = try CGImage.load(data: imageData)
		try self.init(cgImage)
	}

	/// Load a bitmap from a file URL
	init(fileURL: URL) throws {
		assert(fileURL.isFileURL)
		let cgImage = try CGImage.load(fileURL: fileURL)
		try self.init(cgImage)
	}
}

// MARK: - Export

public extension Bitmap {
	/// Generate a representation of the bitmap as an image format
	///
	/// Returns `nil` if the bitmap cannot be represented as an image
	var representation: Representation? { Representation(self) }

	/// Representation generator
	struct Representation {
		private let reps: CGImage.ImageRepresentation
		private let bitmap: Bitmap
		fileprivate init?(_ bitmap: Bitmap) {
			guard let reps = bitmap.cgImage?.representation else { return nil }
			self.reps = reps
			self.bitmap = bitmap
		}

		/// Create a png representation of the bitmap
		/// - Parameters:
		///   - dpi: The image's dpi
		/// - Returns: image data
		public func png(dpi: CGFloat) throws -> Data {
			try self.reps.png(dpi: dpi)
		}

		/// Create a png representation of the bitmap
		/// - Parameters:
		///   - scale: The image's scale value
		/// - Returns: image data
		public func png(scale: CGFloat = 1) throws -> Data {
			try self.reps.png(scale: scale)
		}

		/// Create a jpeg representation of the image
		/// - Parameters:
		///   - dpi: The image's dpi
		///   - compression: The compression level to apply (clamped to 0 ... 1)
		/// - Returns: image data
		public func jpeg(dpi: CGFloat, compression: CGFloat? = nil) throws -> Data {
			try self.reps.jpeg(dpi: dpi, compression: compression)
		}

		/// Create a jpeg representation of the image
		/// - Parameters:
		///   - scale: The image's scale value
		///   - compression: The compression level to apply (clamped to 0 ... 1)
		/// - Returns: image data
		public func jpeg(scale: CGFloat = 1, compression: CGFloat? = nil) throws -> Data {
			try self.reps.jpeg(scale: scale, compression: compression)
		}

		/// Create a tiff representation of the image
		/// - Parameters:
		///   - dpi: The image's dpi
		///   - compression: The compression level to apply (clamped to 0 ... 1)
		/// - Returns: image data
		public func tiff(dpi: CGFloat, compression: CGFloat? = nil) throws -> Data {
			try self.reps.tiff(scale: dpi / 72.0, compression: compression)
		}

		/// Create a tiff representation of the image
		/// - Parameters:
		///   - scale: The image's scale value (for retina-type images eg. @2x == 2)
		///   - compression: The compression level to apply (clamped to 0 ... 1)
		/// - Returns: image data
		public func tiff(scale: CGFloat = 1, compression: CGFloat? = nil) throws -> Data {
			try self.reps.tiff(scale: scale, compression: compression)
		}

		/// Create a heic representation of the image
		/// - Parameters:
		///   - scale: The image's scale value (for retina-type images eg. @2x == 2)
		///   - compression: The compression level to apply (clamped to 0 ... 1)
		/// - Returns: image data
		///
		/// Not supported on macOS < 10.13 (throws an error)
		public func heic(dpi: CGFloat, compression: CGFloat? = nil) throws -> Data {
			try self.reps.heic(scale: dpi / 72.0, compression: compression)
		}

		/// Create a heic representation of the image
		/// - Parameters:
		///   - scale: The image's scale value (for retina-type images eg. @2x == 2)
		///   - compression: The compression level to apply (clamped to 0 ... 1)
		/// - Returns: image data
		///
		/// Not supported on macOS < 10.13 (throws an error)
		public func heic(scale: CGFloat = 1, compression: CGFloat? = nil) throws -> Data {
			try self.reps.heic(scale: scale, compression: compression)
		}

		/// Return a P3 representation of this bitmap
		/// - Returns: P3 data
		public func p3() throws -> Data { try __p3(bitmap) }

		/// Return a P6 representation of this bitmap
		/// - Returns: P6 data
		public func p6() throws -> Data { try __p6(bitmap) }
	}
}

// MARK: - PPM support routines

/// Returns a P3 PPM encoding for the bitmap
private func __p3(_ bitmap: Bitmap) throws -> Data {
	let header = "P3\r\n\(bitmap.width) \(bitmap.height)\r\n255\r\n"
	let data = bitmap.rawPixels.flatMap { "\($0.r) \($0.g) \($0.b)\r\n" }
	guard let encoded = (header + data).data(using: .utf8) else { throw Bitmap.BitmapError.cannotConvert }
	return encoded
}

/// Returns a P6 PPM encoding for the bitmap
private func __p6(_ bitmap: Bitmap) throws -> Data {
	var data = Data()
	let header = "P6\n\(bitmap.width) \(bitmap.height)\n255\n"
	data.append(header.data(using: .ascii)!)
	let rawData = bitmap.rawPixels.flatMap { [$0.r, $0.g, $0.b ] }
	data.append(contentsOf: rawData)
	return data
}
