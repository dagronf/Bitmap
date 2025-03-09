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
import CoreGraphics

// MARK: - Inset

public extension Bitmap {
	/// Inset this bitmap
	/// - Parameter value: The amount to inset the bitmap
	///
	/// The original bitmap size is not affected.
	@inlinable func inset(by value: Double, backgroundColor: CGColor? = nil) throws {
		try self.replaceContents(with: try self.insetting(by: value, backgroundColor: backgroundColor))
	}

	/// Inset this bitmap
	/// - Parameter edgeInsets: Edge insets to apply
	///
	/// The original bitmap size is not affected
	@inlinable func inset(by edgeInsets: NSEdgeInsets, backgroundColor: CGColor? = nil) throws {
		try self.replaceContents(with: try self.insetting(by: edgeInsets, backgroundColor: backgroundColor))
	}

	/// Create a new bitmap by applying insets to this bitmap
	/// - Parameter value: The amount to inset
	/// - Returns: A copy of this bitmap with the inset applied
	@inlinable func insetting(by value: Double, backgroundColor: CGColor? = nil) throws -> Bitmap {
		try self.insetting(
			by: NSEdgeInsets(top: value, left: value, bottom: value, right: value),
			backgroundColor: backgroundColor
		)
	}

	/// Create a new bitmap by applying insets to this bitmap
	/// - Parameters:
	///   - edgeInsets: the padding to apply to each edge
	///   - backgroundColor: The background color to use for the inset areas, or nil for clear
	/// - Returns: A copy of this bitmap with the inset applied
	func insetting(by edgeInsets: NSEdgeInsets, backgroundColor: CGColor? = nil) throws -> Bitmap {
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
		let newImage = try Bitmap(width: self.width, height: self.height)

		let nw = Double(self.width) - (edgeInsets.left + edgeInsets.right)
		let nh = Double(self.height) - (edgeInsets.top + edgeInsets.bottom)
		let imageDestination = CGRect(
			origin: CGPoint(x: edgeInsets.left, y: edgeInsets.bottom),
			size: CGSize(width: nw, height: nh)
		)

		if let backgroundColor = backgroundColor {
			let bounds = newImage.bounds
			newImage.draw { ctx in
				// Clip out the image's destination out of the background fill
				ctx.addRect(bounds)
				ctx.addRect(imageDestination)
				ctx.clip(using: .evenOdd)
				ctx.setFillColor(backgroundColor)
				ctx.fill(bounds)
			}
		}

		return try newImage.drawBitmap(cgi, in: imageDestination)
	}
}
