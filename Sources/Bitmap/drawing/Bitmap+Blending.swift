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

import CoreGraphics
import Foundation

// Blend mode support

public extension Bitmap {
	/// Create a new bitmap by blending an image
	/// - Parameters:
	///   - image: The image to blend
	///   - blendMode: The blending mode
	///   - backgroundColor: initial background color for the bitmap
	///   - clippingRects: Clipping rects within the bitmap
	convenience init(
		_ image: ImageRepresentationType,
		blendMode: CGBlendMode,
		backgroundColor: CGColor? = nil,
		clippingRects: [CGRect]? = nil
	) throws {
		let image = try image.imageRepresentation()
		try self.init(width: image.width, height: image.height, backgroundColor: backgroundColor)
		self.draw { ctx in
			ctx.clip(to: [self.bounds])
			ctx.setBlendMode(blendMode)
			ctx.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
		}
	}
}

// MARK: - Operating on the original bitmap

public extension Bitmap {
	/// Blend an image onto this bitmap
	/// - Parameters:
	///   - image: The image to blend
	///   - blendMode: The blending mode
	///   - dest: The rect in which to draw the blended image
	///   - clippingRects: Clipping rects within the bitmap
	/// - Returns: self
	func blend(
		_ image: ImageRepresentationType,
		blendMode: CGBlendMode,
		dest: CGRect? = nil,
		clippingRects: [CGRect]? = nil
	) throws {
		let image = try image.imageRepresentation()
		self.bitmapContext.savingGState { ctx in
			ctx.clip(to: clippingRects ?? [self.bounds])
			ctx.setBlendMode(blendMode)
			ctx.draw(image, in: dest ?? CGRect(origin: .zero, size: image.size))
		}
	}
}

public extension Bitmap {
	/// Blend an image onto this bitmap
	/// - Parameters:
	///   - image: The image to blend
	///   - blendMode: The blending mode
	///   - position: The position to draw the image
	///   - clippingRects: Clipping rects within the bitmap
	/// - Returns: self
	func blend(
		_ image: ImageRepresentationType,
		blendMode: CGBlendMode,
		position: CGPoint,
		clippingRects: [CGRect]? = nil
	) throws {
		let image = try image.imageRepresentation()
		let dest = CGRect(origin: position, size: image.size)
		try self.blend(image, blendMode: blendMode, dest: dest, clippingRects: clippingRects)
	}
}

// MARK: - Operating on a copy of this bitmap

public extension Bitmap {
	/// Create a new bitmap by blending another image onto this image
	/// - Parameters:
	///   - image: The image to blend
	///   - blendMode: The blending mode
	///   - dest: The rect in which to draw the blended image
	///   - clippingRects: Rects to clip within the bitmap
	/// - Returns: A blended bitmap
	func blending(
		_ image: ImageRepresentationType,
		blendMode: CGBlendMode,
		dest: CGRect? = nil,
		clippingRects: [CGRect]? = nil
	) throws -> Bitmap {
		try self.makingCopy { copy in
			try copy.blend(image, blendMode: blendMode, dest: dest, clippingRects: clippingRects)
		}
	}

	/// Create a new bitmap by blending another image onto this image
	/// - Parameters:
	///   - image: The image to blend
	///   - blendMode: The blending mode
	///   - position: The position to draw the image
	///   - clippingRects: Rects to clip within the bitmap
	/// - Returns: A blended bitmap
	func blending(
		_ image: ImageRepresentationType,
		blendMode: CGBlendMode,
		position: CGPoint,
		clippingRects: [CGRect]? = nil
	) throws -> Bitmap {
		try self.makingCopy { copy in
			try copy.blend(image, blendMode: blendMode, position: position, clippingRects: clippingRects)
		}
	}
}
