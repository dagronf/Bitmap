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

/// A bitmap
///
/// Coordinates start at the bottom left of the image, always in the sRGB colorspace
public struct Bitmap {
	/// The errors thrown
	public enum BitmapError: Error {
		case outOfBounds
		case invalidContext
		case cannotCreateCGImage
		case paddingOrInsetMustBePositiveValue
		case rgbaDataMismatchSize
		case unableToMask
		case cannotFilter
		case cannotConvertColorSpace
		case cannotConvert
	}

	/// Raw bitmap information
	public internal(set) var bitmapData: Bitmap.RGBAData

	/// The raw RGBA byte data for the bitmap
	public var rgbaBytes: [UInt8] { bitmapData.rgbaBytes }

	/// The width of the image in pixels
	@inlinable public var width: Int { bitmapData.width }
	/// The height of the image in pixels
	@inlinable public var height: Int { bitmapData.height }
	/// The size of the image (in pixels)
	public var size: CGSize { bitmapData.size }
	/// The bounds rectangle for the image
	public var bounds: CGRect { bitmapData.bounds }

	/// Create a bitmap from raw bitmap data
	/// - Parameter bitmapData: The bitmap data
	public init(_ rgbaBitmapData: Bitmap.RGBAData) throws {
		self.bitmapData = rgbaBitmapData
		guard
			let ctx = CGContext(
				data: &bitmapData.rgbaBytes,
				width: bitmapData.width,
				height: bitmapData.height,
				bitsPerComponent: 8,
				bytesPerRow: bitmapData.width * 4,
				space: Bitmap.colorSpace,
				bitmapInfo: Bitmap.bitmapInfo.rawValue
			)
		else {
			throw BitmapError.invalidContext
		}
		self.ctx = ctx
	}

	/// Create an empty bitmap with transparent background using an RGBA colorspace
	/// - Parameters:
	///   - width: bitmap width
	///   - height: bitmap height
	///   - backgroundColor: The background color for the bitmap (defaults to transparent)
	public init(width: Int, height: Int, backgroundColor: CGColor? = nil) throws {
		let bitmapData = Bitmap.RGBAData(width: width, height: height)
		try self.init(bitmapData)
		if let backgroundColor = backgroundColor {
			self.fill(backgroundColor)
		}
	}

	/// Create a transparent bitmap
	/// - Parameters:
	///   - size: The size of the image to create
	///   - backgroundColor: The background color for the bitmap (defaults to transparent)
	@inlinable public init(size: CGSize, backgroundColor: CGColor? = nil) throws {
		try self.init(width: Int(size.width), height: Int(size.height), backgroundColor: backgroundColor)
	}

	/// Create a bitmap from raw RGBA bytes
	/// - Parameters:
	///   - rgbaBytes: Raw rgba data (array of R,G,B,A bytes)
	///   - width: The expected width of the resulting bitmap
	///   - height: The expected height of the resulting bitmap
	public init(rgbaBytes: [UInt8], width: Int, height: Int) throws {
		guard rgbaBytes.count == (width * height * 4) else { throw BitmapError.rgbaDataMismatchSize }
		let bitmapData = Bitmap.RGBAData(width: width, height: height, rgbaBytes: rgbaBytes)
		try self.init(bitmapData)
	}

	/// Create a bitmap from raw RGBA bytes
	/// - Parameters:
	///   - rgbaData: The raw rgba data as R,G,B,A bytes
	///   - width: The expected width of the resulting bitmap
	///   - height: The expected height of the resulting bitmap
	@inlinable public init(rgbaData: Data, width: Int, height: Int) throws {
		try self.init(rgbaBytes: Array(rgbaData), width: width, height: height)
	}

	/// Create a bitmap containing an image
	/// - Parameter image: The initial image contained within the bitmap
	public init(_ image: CGImage) throws {
		try self.init(width: image.width, height: image.height)
		self.draw { ctx in
			ctx.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
		}
	}

	/// Create a bitmap of a specified size with a context block for initialization
	public init(size: CGSize, _ setupBlock: (CGContext) -> Void) throws {
		let bitmap = try Bitmap(width: Int(size.width), height: Int(size.height))
		setupBlock(bitmap.ctx)
		self = bitmap
	}

	/// Create a bitmap by copying another bitmap
	@inlinable public init(_ bitmap: Bitmap) throws {
		try self.init(bitmap.bitmapData)
	}

	/// Load a bitmap from an image asset
	/// - Parameter name: The name of the image asset
	public init(named name: String) throws {
		guard let cgi = PlatformImage(named: name)?.cgImage else { throw BitmapError.cannotCreateCGImage }
		try self.init(cgi)
	}

	// Private

	private static let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
	private static let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

	/// The created image context
	@usableFromInline internal let ctx: CGContext
}

extension Bitmap: Equatable {
	/// Check if two bitmaps are equal
	public static func == (lhs: Bitmap, rhs: Bitmap) -> Bool {
		lhs.bitmapData == rhs.bitmapData
	}
}

public extension Bitmap {
	/// Make a copy of this bitmap
	/// - Returns: A new bitmap
	@inlinable func copy() throws -> Bitmap {
		try Bitmap(self.bitmapData)
	}

	/// Erase the bitmap (set the image content to all transparent)
	mutating func eraseAll() {
		self.bitmapData.eraseAll()
	}
}

// MARK: - Retrieving the image

public extension Bitmap {
	/// Returns a CGImage representation of this bitmap
	@inlinable var cgImage: CGImage? { self.ctx.makeImage() }
}

// MARK: - Getting/setting pixels

public extension Bitmap {
	/// sets/gets the image pixel at the given column, row
	///
	/// Coordinates start at the bottom left (0, 0) of the image
	subscript(x: Int, y: Int) -> RGBA {
		get { self.bitmapData[x, y] }
		set { self.bitmapData[x, y] = newValue }
	}

	/// Set the RGBA color of the pixel at (x, y)
	///
	/// Coordinates start at the bottom left (0, 0) of the image
	mutating func setPixel(x: Int, y: Int, color: RGBA) {
		self.bitmapData.setPixel(x: x, y: y, color: color)
	}

	/// Set the RGBA color of the pixel in the bitmap
	/// - Parameter pixel: The pixel to set, in bottom left coordinates
	@inlinable @inline(__always) mutating func setPixel(_ pixel: Bitmap.Pixel) {
		self.setPixel(x: pixel.x, y: pixel.y, color: pixel.color)
	}

	/// Set the RGBA color of the pixel at (x, y), assuming (0, 0) is at the bottom left of the bitmap
	///
	/// Coordinate is assumed to have its origin at the bottom left
	mutating func setPixel(_ coordinate: Bitmap.Coordinate, color: RGBA) {
		self.bitmapData.setPixel(x: coordinate.x, y: coordinate.y, color: color)
	}

	/// Returns a 4 byte array slice for the pixel ([R,G,B,A] bytes)
	///
	/// Coordinates start at the bottom left (0, 0) of the image
	@inlinable @inline(__always) func getPixelSlice(x: Int, y: Int) -> ArraySlice<UInt8> {
		self.bitmapData.getPixelSlice(x: x, y: y)
	}

	/// Returns a 4 byte array slice for the pixel ([R,G,B,A] bytes), assuming (0, 0) is at the bottom left of the bitmap
	///
	/// Coordinates start at the bottom left (0, 0) of the image
	@inlinable @inline(__always) func getPixelSlice(_ coordinate: Bitmap.Coordinate) -> ArraySlice<UInt8> {
		self.bitmapData.getPixelSlice(x: coordinate.x, y: coordinate.y)
	}

	/// Get the RGBA color of the pixel at (x, y).
	///
	/// Coordinates start at the bottom left (0, 0) of the image
	@inlinable @inline(__always) func getPixel(x: Int, y: Int) -> RGBA {
		self.bitmapData.getPixel(x: x, y: y)
	}

	/// Get the RGBA color of the pixel at (x, y), assuming (0, 0) is at the bottom left of the bitmap
	///
	/// Coordinates start at the bottom left (0, 0) of the image
	@inlinable @inline(__always) func getPixel(_ coordinate: Bitmap.Coordinate) -> RGBA {
		self.bitmapData.getPixel(x: coordinate.x, y: coordinate.y)
	}

	/// Returns the pixels in the image as an array of RGBA pixels
	///
	/// (0) is the top left pixel, <max-1> is the bottom right pixel
	@inlinable @inline(__always) internal var rawPixels: [RGBA] {
		self.bitmapData.rawPixels
	}
}

public extension Bitmap {
	/// Return the pixel coordinates exactly matching the specified color, assuming (0, 0) is at the bottom left of the bitmap
	/// - Parameter color: The color
	/// - Returns: An array of pixel coordinates
	func coordinatesMatching(_ color: RGBA) -> [Bitmap.Coordinate] {
		assert(MemoryLayout<RGBA>.size == 4)
		assert(self.rgbaBytes.count % 4 == 0)
		return stride(from: 0, to: self.rgbaBytes.count, by: 4).compactMap { index in
			let sl = Array(self.rgbaBytes[index ..< index + 4])
			assert(sl.count == 4)
			if sl[0] == color.r, sl[1] == color.g, sl[2] == color.b, sl[3] == color.a {
				let pIndex = index / 4
				let x: Int = pIndex % self.width
				let y: Int = self.height - (pIndex / self.width) - 1
				return Coordinate(x: x, y: y)
			}
			return nil
		}
	}
}

public extension Bitmap {
	/// Return an array of raw pixels for this bitmap
	/// - Parameter topLeft: If true, returns coordinates are returned setting (0, 0) at the bottom left,
	///                      otherwise pixels are returned using (0, 0) in the top left
	/// - Returns: An array of pixels
	func pixels(bottomLeft: Bool = true) -> [Bitmap.Pixel] {
		assert(MemoryLayout<RGBA>.size == 4)
		assert(self.rgbaBytes.count % 4 == 0)
		return stride(from: 0, to: self.rgbaBytes.count, by: 4).map { index in
			let sl = self.rgbaBytes[index ..< index + 4]
			let pIndex = index / 4
			let x: Int = pIndex % self.width
			let y: Int = bottomLeft ? self.height - (pIndex / self.width) - 1 : pIndex / self.width
			return Pixel(x: x, y: y, color: RGBA(slice: sl))
		}
	}
}
