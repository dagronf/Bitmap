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

// MARK: - Padding

public extension Bitmap {
	/// Pad the current image by adding pixels on all edges (so the resulting image will be larger)
	@inlinable mutating func padding(_ value: CGFloat, backgroundColor: CGColor? = nil) throws {
		self = try self.padded(value, backgroundColor: backgroundColor)
	}

	/// Pad the current image by adding pixels on all edges (so the image will be larger)
	@inlinable mutating func padding(_ padding: NSEdgeInsets, backgroundColor: CGColor? = nil) throws {
		self = try self.padded(padding, backgroundColor: backgroundColor)
	}

	/// Create a new bitmap by padding the edges of the image with additional pixels
	@inlinable func padded(_ value: Double, backgroundColor: CGColor? = nil) throws -> Bitmap {
		try padded(
			NSEdgeInsets(top: value, left: value, bottom: value, right: value),
			backgroundColor: backgroundColor
		)
	}

	/// Create a new bitmap by padding the edges of the image with transparent pixels
	/// - Parameters:
	///   - edgeInsets: the padding to apply to each edge
	///   - backgroundColor: The background color to use for the padded areas, or nil for clear
	/// - Returns: A new bitmap
	///
	/// Resulting bitmap will be _bigger_ than the original
	func padded(_ edgeInsets: NSEdgeInsets, backgroundColor: CGColor? = nil) throws -> Bitmap {
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

		let nw = Double(self.width) + edgeInsets.left + edgeInsets.right
		let nh = Double(self.height) + edgeInsets.top + edgeInsets.bottom

		var newImage = try Bitmap(width: Int(nw), height: Int(nh))
		if let backgroundColor = backgroundColor {
			newImage.fill(backgroundColor)
		}

		newImage.draw(
			cgi,
			in: CGRect(
				origin: CGPoint(x: edgeInsets.left, y: edgeInsets.bottom),
				size: CGSize(width: self.width, height: self.height)
			)
		)

		return newImage
	}
}
