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

public extension Bitmap {
	/// A bitmap coordinate
	///
	/// Note that the coordinate itself does not define its origin.
	struct Coordinate: Equatable, Comparable, Hashable {
		/// x coordinate
		public let x: Int
		/// y coordinate
		public let y: Int
		/// Create
		public init(x: Int, y: Int) {
			self.x = x
			self.y = y
		}
		/// Sort from 0,0 to width, height to get consistent ordering
		public static func < (lhs: Bitmap.Coordinate, rhs: Bitmap.Coordinate) -> Bool {
			if lhs.y < rhs.y { return true }
			if lhs.y > rhs.y { return false }
			return lhs.x < rhs.x
		}
	}

	/// A color with a coordinate.
	///
	/// Note that the coordinate itself does not define its origin.
	struct Pixel: Equatable {
		/// The coordinate within the associated bitmap
		public let point: Coordinate
		/// The color of the pixel
		public let color: RGBA

		/// x coordinate
		@inlinable public var x: Int { self.point.x }
		/// y coordinate
		@inlinable public var y: Int { self.point.y }

		/// Create a pixel
		/// - Parameters:
		///   - x: The x-coordinate
		///   - y: The y-coordinate
		///   - color: The pixel's RGBA color
		public init(x: Int, y: Int, color: RGBA) {
			self.point = Coordinate(x: x, y: y)
			self.color = color
		}
	}
}
