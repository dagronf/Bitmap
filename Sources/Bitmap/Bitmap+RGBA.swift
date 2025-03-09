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

extension Bitmap {
	/// An RGBA pixel representation (32-bit)
	public struct RGBA: Equatable, Hashable, Sendable {
		/// Red component (0 -> 255)
		public let r: UInt8
		/// Green component (0 -> 255)
		public let g: UInt8
		/// Blue component (0 -> 255)
		public let b: UInt8
		/// Alpha component (0 -> 255)
		public let a: UInt8

		/// Fractional red component (0.0 -> 1.0)
		@inlinable public var rf: Double { Double(r) / 255.0 }
		/// Fractional green component (0.0 -> 1.0)
		@inlinable public var gf: Double { Double(g) / 255.0 }
		/// Fractional blue component (0.0 -> 1.0)
		@inlinable public var bf: Double { Double(b) / 255.0 }
		/// Fractional alpha component (0.0 -> 1.0)
		@inlinable public var af: Double { Double(a) / 255.0 }

		/// Create an RGBA pixel
		public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
			self.r = r
			self.g = g
			self.b = b
			self.a = a
		}

		/// Create an RGBA pixel using fractional components 0.0 -> 1.0
		///
		/// Clamps values outside the 0.0 ... 1.0 range
		@inlinable public init(rf: Double, gf: Double, bf: Double, af: Double) {
			self.init(
				r: UInt8(255.0 * min(1, max(0, rf))),
				g: UInt8(255.0 * min(1, max(0, gf))),
				b: UInt8(255.0 * min(1, max(0, bf))),
				a: UInt8(255.0 * min(1, max(0, af)))
			)
		}
	}
}

public extension Bitmap.RGBA {
	/// Clear color
	static let clear = Bitmap.RGBA(r: 0, g: 0, b: 0, a: 0)
	/// Black color
	static let black = Bitmap.RGBA(r: 0, g: 0, b: 0, a: 255)
	/// White color
	static let white = Bitmap.RGBA(r: 255, g: 255, b: 255, a: 255)
	/// Red color
	static let red = Bitmap.RGBA(r: 255, g: 0, b: 0, a: 255)
	/// Green color
	static let green = Bitmap.RGBA(r: 0, g: 255, b: 0, a: 255)
	/// Blue color
	static let blue = Bitmap.RGBA(r: 0, g: 0, b: 255, a: 255)
	/// Yellow color
	static let yellow = Bitmap.RGBA(r: 255, g: 255, b: 0, a: 255)
	/// Magenta color
	static let magenta = Bitmap.RGBA(r: 255, g: 0, b: 255, a: 255)
	/// Cyan color
	static let cyan = Bitmap.RGBA(r: 0, g: 255, b: 255, a: 255)
}

public extension Bitmap.RGBA {
	/// Create an RGBA struct from an array of four (4) bytes in the form [R, G, B, A]
	init(rgbaByteComponents comps: [UInt8]) {
		assert(comps.count == 4)
		self = Self.init(r: comps[0], g: comps[1], b: comps[2], a: comps[3])
	}

	/// Create an RGBA struct from an array of four (4) bytes in the form [R, G, B, A]
	@inlinable init(slice: ArraySlice<UInt8>) {
		assert(slice.count == 4)
		let i = slice.startIndex
		self = Self.init(r: slice[i], g: slice[i + 1], b: slice[i + 2], a: slice[i + 3])
	}
}

public extension Bitmap.RGBA {
	/// Create an array of RGBA colors from raw bytes. Array count must be a multiple of 4
	static func from(rgbaArray: [UInt8]) -> [Bitmap.RGBA] {
		assert(MemoryLayout<Bitmap.RGBA>.size == 4)
		assert(rgbaArray.count % 4 == 0)
		return stride(from: rgbaArray.startIndex, to: rgbaArray.endIndex, by: 4).map { index in
			Bitmap.RGBA(r: rgbaArray[index], g: rgbaArray[index + 1], b: rgbaArray[index + 2], a: rgbaArray[index + 3])
		}
	}

	/// Create an array of RGBA colors from raw data. Data count must be a multiple of 4
	static func from(data: Data) -> [Bitmap.RGBA] {
		assert(MemoryLayout<Bitmap.RGBA>.size == 4)
		assert(data.count % 4 == 0)
		return stride(from: data.startIndex, to: data.endIndex, by: 4).map { index in
			Bitmap.RGBA(r: data[index], g: data[index + 1], b: data[index + 2], a: data[index + 3])
		}
	}

	/// Create an array of RGBA colors from raw bytes. Count must be a multiple of 4
	static func from(slice: ArraySlice<UInt8>) -> [Bitmap.RGBA] {
		assert(MemoryLayout<Bitmap.RGBA>.size == 4)
		assert(slice.count % 4 == 0)
		return stride(from: slice.startIndex, to: slice.endIndex, by: 4).map { index in
			Bitmap.RGBA(r: slice[index], g: slice[index + 1], b: slice[index + 2], a: slice[index + 3])
		}
	}
}
