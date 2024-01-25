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

// MARK: - Inset

public extension Bitmap {
	/// Insets the current bitmap
	/// - Parameter value: The amount to inset the bitmap
	@inlinable mutating func inset(_ value: Double) throws {
		self = try self.inset(NSEdgeInsets(top: value, left: value, bottom: value, right: value))
	}

	/// Insets the current bitmap
	@inlinable mutating func insetting(_ edgeInsets: NSEdgeInsets) throws {
		self = try self.inset(edgeInsets)
	}

	/// Create a new image by insetting the current image with transparent pixels
	@inlinable func insetting(_ value: Double) throws -> Bitmap {
		try self.inset(NSEdgeInsets(top: value, left: value, bottom: value, right: value))
	}

	/// Create a new image by insetting the current image within the bitmap
	///
	/// Resulting image will be the same dimension as the original
	///
	/// Uses transparent pixels for the padded areas
	func inset(_ edgeInsets: NSEdgeInsets) throws -> Bitmap {
		guard
			edgeInsets.top >= 0,
			edgeInsets.bottom >= 0,
			edgeInsets.left >= 0,
			edgeInsets.right >= 0
		else {
			throw BitmapError.paddingOrInsetMustBePositiveValue
		}

		guard let cgi = self.cgImage else {
			throw BitmapError.cannotCreateCGImage
		}

		// New bitmap will be the same pixel size as the original
		var newImage = try Bitmap(width: self.width, height: self.height)
		let nw = Double(self.width) - (edgeInsets.left + edgeInsets.right)
		let nh = Double(self.height) - (edgeInsets.top + edgeInsets.bottom)
		newImage.drawImage(
			cgi,
			in: CGRect(
				origin: CGPoint(x: edgeInsets.left, y: edgeInsets.bottom),
				size: CGSize(width: nw, height: nh)
			)
		)
		return newImage
	}
}
