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

public extension Bitmap {
	/// Raw RGBA bitmap information
	struct RGBAData: Sendable, Equatable {
		/// The width of the image in pixels
		public let width: Int
		/// The height of the image in pixels
		public let height: Int
		/// The raw RGBA pixel data
		public internal(set) var rgbaBytes: [UInt8]

		/// The size of the image (in pixels)
		public var size: CGSize { CGSize(width: self.width, height: self.height) }
		/// The bounds rectangle for the image
		public var bounds: CGRect { CGRect(origin: .zero, size: self.size) }

		/// Create a bitmap data from raw RGBA bytes
		/// - Parameters:
		///   - width: The bitmap pixel width
		///   - height: The bitmap pixel height
		///   - rgbaBytes: The raw RGBA bytes array
		public init(width: Int, height: Int, rgbaBytes: [UInt8]) {
			assert(rgbaBytes.count == width * height * 4)
			self.width = width
			self.height = height
			self.rgbaBytes = rgbaBytes
		}

		/// Create an empty bitmap data for a specified width and height
		/// - Parameters:
		///   - width: The width
		///   - height: The height
		public init(width: Int, height: Int) {
			self.width = width
			self.height = height
			self.rgbaBytes = [UInt8](repeating: 0, count: Int(width * height * 4))
		}

		/// Create an empty bitmap data for a specified size
		/// - Parameter size: The size
		@inlinable public init(size: CGSize) {
			self.init(width: Int(size.width), height: Int(size.height))
		}

		/// Create bitmap data from an RGBA pixel array
		/// - Parameters:
		///   - width: The image width
		///   - height: The image height
		///   - pixelsData: The raw pixels array
		public init(width: Int, height: Int, pixelsData: [RGBA]) {
			assert(pixelsData.count == width * height)
			self.width = width
			self.height = height
			self.rgbaBytes = pixelsData.withUnsafeBytes { Array($0) }
		}
	}
}

public extension Bitmap.RGBAData {
	/// sets/gets the image pixel at the given row/column
	///
	/// Coordinates start at the bottom left of the image
	subscript(x: Int, y: Int) -> Bitmap.RGBA {
		get {
			self.getPixel(x: x, y: y)
		}
		set {
			let offset = self.byteOffset(x: x, y: y)
			self.rgbaBytes[offset] = newValue.r
			self.rgbaBytes[offset + 1] = newValue.g
			self.rgbaBytes[offset + 2] = newValue.b
			self.rgbaBytes[offset + 3] = newValue.a
		}
	}

	/// Set the RGBA color of the pixel at (x, y)
	mutating func setPixel(x: Int, y: Int, color: Bitmap.RGBA) {
		assert(x < self.width && y < self.height)
		self[x, y] = color
	}

	/// Get the RGBA color of the pixel at (x, y)
	@inlinable func getPixel(x: Int, y: Int) -> Bitmap.RGBA {
		assert(MemoryLayout<Bitmap.RGBA>.size == 4)
		assert(y < self.height && x < self.width)
		return Bitmap.RGBA(slice: self.getPixelSlice(x: x, y: y))
	}

	/// Returns a 4 byte array slice for the pixel ([R,G,B,A] bytes)
	///
	/// Coordinates start at the bottom left of the image
	@inlinable func getPixelSlice(x: Int, y: Int) -> ArraySlice<UInt8> {
		let offset = self.byteOffset(x: x, y: y)
		return self.rgbaBytes[offset ..< offset + 4]
	}

	/// Returns the base byte offset for the pixel at (x, y)
	@inlinable @inline(__always) internal func byteOffset(x: Int, y: Int) -> Int {
		assert(y < self.height && x < self.width)
		return ((self.height - 1 - y) * (self.width * 4)) + (x * 4)
	}

	/// Returns the row of bytes at the specified row index
	///
	/// NOTE: Given that this image is lower-left coordinates, row 0 is the BOTTOM row of the image
	@inlinable func rowBytes(at y: Int) -> ArraySlice<UInt8> {
		assert(y < self.height)
		let offset = self.byteOffset(x: 0, y: y)
		return self.rgbaBytes[offset ..< offset + (width * 4)]
	}

	/// Returns the row of pixels at the specified row index
	///
	/// NOTE: Given that this image is lower-left coordinates, row 0 is the BOTTOM row of the image
	@inlinable func rowPixels(at y: Int) -> [Bitmap.RGBA] {
		self.rowBytes(at: y).withUnsafeBytes { ptr in
			Array(ptr.bindMemory(to: Bitmap.RGBA.self))
		}
	}

	/// Returns the column of pixels at the specified column index
	///
	/// NOTE: Given that this image is lower-left coordinates, row 0 is the BOTTOM row of the image
	@inlinable func columnPixels(at x: Int) -> [Bitmap.RGBA] {
		assert(x >= 0 && x < self.width)
		var result: [Bitmap.RGBA] = []
		result.reserveCapacity(self.height)
		for y in (0 ..< self.height).reversed() {
			let offset = ((y * self.width) + x) * 4
			let slice = self.rgbaBytes[offset ..< offset + 4]
			let pixel = slice.withUnsafeBytes { ptr in
				ptr.bindMemory(to: Bitmap.RGBA.self)
			}
			result += pixel
		}
		return result
	}

	/// Returns the pixels in the image as an array of RGBA pixels
	///
	/// (0) is the top left pixel, <max-1> is the bottom right pixel
	@inlinable internal var rawPixels: [Bitmap.RGBA] {
		assert(MemoryLayout<Bitmap.RGBA>.size == 4)
		return self.rgbaBytes.withUnsafeBytes { ptr in
			Array(ptr.bindMemory(to: Bitmap.RGBA.self))
		}
	}

	/// Erase the image
	mutating func eraseAll() {
		// The stored CGContext is (effectively) built with a pointer to the array of bytes
		// in order to reduce memory requirements.  As a result, we should not just
		// nuke `rgbaBytes` with a new array - it may invalidate the CGContext
		_ = self.rgbaBytes.withUnsafeMutableBytes { ptr in
			ptr.initializeMemory(as: UInt8.self, repeating: 0)
		}
	}
}

internal extension Bitmap.RGBAData {
	/// Set the raw RGBA bytes for the image.
	/// - Parameter bytes: The image bytes in an RGBA format
	mutating func setBytes(_ bytes: [UInt8]) {
		assert(bytes.count == (self.height * (self.width * 4)))

		// The stored CGContext is (effectively) built with a pointer to the array of bytes
		// in order to reduce memory requirements.  As a result, we should not just
		// nuke `rgbaBytes` with a new array - it may invalidate the CGContext
		self.rgbaBytes.withUnsafeMutableBytes { orig in
			orig.copyBytes(from: bytes)
		}
	}
}
