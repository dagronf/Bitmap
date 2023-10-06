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

#if os(macOS)
import AppKit.NSImage
#else
import UIKit
#endif

/// A bitmap context
///
/// Coordinates start at the bottom left of the image
public struct Bitmap {
	/// The errors thrown
	public enum BitmapError: Error {
		case outOfBounds
		case invalidContext
		case cannotCreateCGImage
		case paddingOrInsetMustBePositiveValue
		case rgbaDataMismatchSize
		case unableToMask
	}

	/// The width of the image in pixels
	public let width: Int
	/// The height of the image in pixels
	public let height: Int
	/// The size of the image (in pixels)
	public var size: CGSize { CGSize(width: self.width, height: self.height) }
	/// The bounds rectangle for the image
	public var bounds: CGRect { CGRect(origin: .zero, size: size) }

	/// The raw RGBA pixel data
	public private(set) var rgbaPixelData: [UInt8]

	/// Create an empty bitmap with transparent background using an RGBA colorspace
	/// - Parameters:
	///   - width: bitmap width
	///   - height: bitmap height
	public init(width: Int, height: Int) throws {
		let dataSize = width * height * 4
		self.rgbaPixelData = [UInt8](repeating: 0, count: Int(dataSize))

		guard
			let ctx = CGContext(
				data: &rgbaPixelData,
				width: width,
				height: height,
				bitsPerComponent: 8,
				bytesPerRow: width * 4,
				space: Bitmap.colorSpace,
				bitmapInfo: Bitmap.bitmapInfo.rawValue
			)
		else {
			throw BitmapError.invalidContext
		}
		self.ctx = ctx
		self.width = width
		self.height = height
	}

	/// Create a bitmap from raw RGBA bytes
	/// - Parameters:
	///   - rgbaData: The raw rgba data
	///   - width: The expected width of the resulting bitmap
	///   - height: The expected height of the resulting bitmap
	init(rgbaData: Data, width: Int, height: Int) throws {
		guard rgbaData.count == (width * height) else { throw BitmapError.rgbaDataMismatchSize }
		self.width = width
		self.height = height
		self.rgbaPixelData = Array(rgbaData)

		guard
			let ctx = CGContext(
				data: &rgbaPixelData,
				width: width,
				height: height,
				bitsPerComponent: 8,
				bytesPerRow: width * 4,
				space: Bitmap.colorSpace,
				bitmapInfo: Bitmap.bitmapInfo.rawValue
			)
		else {
			throw BitmapError.invalidContext
		}
		self.ctx = ctx
	}

	/// Create a transparent bitmap
	/// - Parameter size: The size of the image to create
	public init(size: CGSize) throws {
		try self.init(width: Int(size.width), height: Int(size.height))
	}

	/// Create a bitmap context containing an image
	/// - Parameter image: The initial image contained within the bitmap
	public init(_ image: CGImage) throws {
		try self.init(width: image.width, height: image.height)
		self.draw { ctx in
			ctx.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
		}
	}

	/// Create a bitmap from a copy of a bitmap
	public init(_ bitmap: Bitmap) throws {
		guard let cgi = bitmap.cgImage else { throw BitmapError.cannotCreateCGImage }
		try self.init(cgi)
	}

	/// Create a bitmap of a specified size with a context block for initialization
	public init(size: CGSize, _ setupBlock: (CGContext) -> Void) throws {
		let bitmap = try Bitmap(width: Int(size.width), height: Int(size.height))
		setupBlock(bitmap.ctx)
		self = bitmap
	}


	/// Make a copy of this bitmap
	/// - Returns: A new bitmap
	@inlinable public func copy() throws -> Bitmap {
		try Bitmap(self)
	}

	private static let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
	private static let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

	/// The created image context
	@usableFromInline internal let ctx: CGContext
}

// MARK: - Retrieving the image

public extension Bitmap {
	/// Returns a CGImage representation of this bitmap
	@inlinable var cgImage: CGImage? { self.ctx.makeImage() }
}

// MARK: - Getting/setting pixels

public extension Bitmap {
	/// sets/gets the image pixel at the given row/column
	///
	/// Coordinates start at the bottom left of the image
	subscript(x: Int, y: Int) -> RGBA {
		get {
			self.getPixel(x: x, y: y)
		}
		set {
			let offset = self.byteOffset(x: x, y: y)
			self.rgbaPixelData[offset] = newValue.r
			self.rgbaPixelData[offset + 1] = newValue.g
			self.rgbaPixelData[offset + 2] = newValue.b
			self.rgbaPixelData[offset + 3] = newValue.a
		}
	}

	/// Set the RGBA color of the pixel at (x, y)
	@inlinable mutating func setPixel(x: Int, y: Int, color: RGBA) {
		self[x, y] = color
	}

	/// Returns a 4 byte array slice for the pixel ([R,G,B,A] bytes)
	///
	/// Coordinates start at the bottom left of the image
	@inlinable func getPixelSlice(x: Int, y: Int) -> ArraySlice<UInt8> {
		assert(y < self.height && x < self.width)
		let offset = self.byteOffset(x: x, y: y)
		return self.rgbaPixelData[offset ..< offset + 4]
	}

	/// Get the RGBA color of the pixel at (x, y)
	@inlinable func getPixel(x: Int, y: Int) -> RGBA {
		assert(MemoryLayout<RGBA>.size == 4)
		assert(y < self.height && x < self.width)
		return RGBA(slice: self.getPixelSlice(x: x, y: y))
	}

	/// Returns the pixels in the image as an array of RGBA pixels
	///
	/// (0) is the top left pixel, <max-1> is the bottom right pixel
	@inlinable internal var rawPixels: [RGBA] {
		assert(MemoryLayout<RGBA>.size == 4)
		return self.rgbaPixelData.withUnsafeBytes { ptr in
			Array(ptr.bindMemory(to: RGBA.self))
		}
	}

	/// Returns the base byte offset for the pixel at (x, y)
	@inlinable @inline(__always) internal func byteOffset(x: Int, y: Int) -> Int {
		assert(y < self.height && x < self.width)
		return ((self.height - 1 - y) * (self.width * 4)) + (x * 4)
	}
}
