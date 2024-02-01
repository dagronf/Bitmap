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

// MARK: - Crop

public extension Bitmap {
	/// Crop this bitmap to the given rect
	/// - Parameter path: The rect to crop
	///
	/// The coordinate system (0, 0) is at the bitmap lower left
	@inlinable func crop(to rect: CGRect) throws {
		try self.assign(try cropping(to: rect))
	}

	/// Create a new bitmap by cropping this bitmap to a rect
	/// - Parameter path: The rect to crop
	/// - Returns: A new bitmap
	///
	/// The coordinate system (0, 0) is at the bitmap lower left
	@inlinable func cropping(to rect: CGRect) throws -> Bitmap {
		// CGRect cropping has zero coordinate at the top left
		let flipped = rect.flippingY(within: self.bounds)
		//let flipped = CGRect(x: rect.minX, y: CGFloat(self.height) - rect.height - rect.minY, width: rect.width, height: rect.height)
		guard let image = self.cgImage?.cropping(to: flipped) else { throw BitmapError.cannotCreateCGImage }
		return try Bitmap(image)
	}

	/// Crop the image to a path
	/// - Parameter path: The path to crop
	///
	/// The coordinate system (0, 0) is at the bitmap lower left
	@inlinable func crop(to path: CGPath) throws {
		try self.assign(try self.cropping(to: path))
	}

	/// Create a new bitmap by cropping this bitmap to the given path
	/// - Parameter path: The path
	/// - Returns: A new bitmap with the clipping path applied
	///
	/// The coordinate system (0, 0) is at the bitmap lower left
	func cropping(to path: CGPath) throws -> Bitmap {
		// Crop to the path bounds
		let newBitmap = try self.cropping(to: path.boundingBoxOfPath)
		let newBounds = newBitmap.bounds

		// Take a snapshot of the cropped image so we can mask out the path
		guard let orig = newBitmap.cgImage else { throw BitmapError.cannotCreateCGImage }

		// Clear the bitmap - we'll reuse it
		newBitmap.eraseAll()

		// Move the path to the origin
		let newPath = CGMutablePath()
		newPath.addPath(path, transform: CGAffineTransform(translationX: -path.boundingBoxOfPath.origin.x,
																			y: -path.boundingBoxOfPath.origin.y))

		// Okay. Now mask the path and re-draw the original image
		newBitmap.draw { ctx in
			ctx.addPath(newPath)
			ctx.clip()
			drawImageInContext(ctx, image: orig, rect: newBounds)
		}

		return newBitmap
	}
}
