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

// MARK: - Padding

public extension Bitmap {
	/// Pad the current image by adding pixels on all edges (so the resulting image will be larger)
	/// - Parameters:
	///   - value: The amount to pad the edges of the bitmap
	///   - backgroundColor: The color to use for the extended edges, or `nil` for transparent
	@discardableResult @inlinable
	func pad(by value: CGFloat, backgroundColor: CGColor? = nil) throws -> Bitmap {
		try self.replaceContent(with: try self.padding(by: value, backgroundColor: backgroundColor))
		return self
	}

	/// Pad the current image by adding pixels on all edges (so the image will be larger)
	/// - Parameters:
	///   - padding: The padding to apply to each edge of the bitmap
	///   - backgroundColor: The color to use for the extended edges, or `nil` for transparent
	@discardableResult @inlinable
	func pad(by padding: NSEdgeInsets, backgroundColor: CGColor? = nil) throws -> Bitmap {
		try self.replaceContent(with: try self.padding(by: padding, backgroundColor: backgroundColor))
		return self
	}

	/// Create a new bitmap by padding the edges of the image with additional pixels
	/// - Parameters:
	///   - value: The amount to pad the edges of the bitmap
	///   - backgroundColor: The color to use for the extended edges, or `nil` for transparent
	/// - Returns: A new bitmap
	@inlinable func padding(by value: Double, backgroundColor: CGColor? = nil) throws -> Bitmap {
		try padding(
			by: NSEdgeInsets(top: value, left: value, bottom: value, right: value),
			backgroundColor: backgroundColor
		)
	}

	/// Create a new bitmap by padding the edges of the image with transparent pixels
	/// - Parameters:
	///   - edgeInsets: the padding to apply to each edge
	///   - backgroundColor: The background color to use for the padded areas, or nil for clear
	/// - Returns: A new bitmap
	func padding(by edgeInsets: NSEdgeInsets, backgroundColor: CGColor? = nil) throws -> Bitmap {
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

		let imageDestination = CGRect(
			origin: CGPoint(x: edgeInsets.left, y: edgeInsets.bottom),
			size: CGSize(width: self.width, height: self.height)
		  )

		let newImage = try Bitmap(width: Int(nw), height: Int(nh))
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
