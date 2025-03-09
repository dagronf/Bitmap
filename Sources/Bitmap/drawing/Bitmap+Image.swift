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

// MARK: - Drawing

public extension Bitmap {
	/// Create a new bitmap by drawing an image on this bitmap
	/// - Parameters:
	///   - bitmap: The image to draw
	///   - rect: The destination rect
	///   - scaling: The scaling method for scaling the image up/down to fit/fill the rect
	/// - Returns: A copy of this bitmap with the new bitmap drawn on
	@inlinable func drawingBitmap(
		_ image: ImageRepresentationType,
		in rect: CGRect,
		scaling: ScalingType = .axesIndependent
	) throws -> Bitmap {
		try self.copy()
			.drawBitmap(image, in: rect, scaling: scaling)
	}

	/// Draw an image onto this image, scaling to fit within the specified rect
	/// - Parameters:
	///   - bitmap: The image to draw
	///   - rect: The destination rect
	///   - scaling: The scaling method for scaling the image up/down to fit/fill the rect
	/// - Returns: self
	@discardableResult
	func drawBitmap(
		_ image: ImageRepresentationType,
		in rect: CGRect,
		scaling: ScalingType = .axesIndependent
	) throws -> Bitmap {
		let image = try image.imageRepresentation()
		drawImageInContext(self.bitmapContext, image: image, rect: rect, scalingType: scaling)
		return self
	}
}

public extension Bitmap {
	/// Draw an image at a point within this bitmap
	/// - Parameters:
	///   - image: The image to draw
	///   - point: The point at which to draw the image
	/// - Returns: self
	@discardableResult
	func drawBitmap(_ image: ImageRepresentationType, atPoint point: CGPoint = .zero) throws -> Bitmap {
		let image = try image.imageRepresentation()
		let bounds = self.bounds
		let dest = CGRect(origin: point, size: image.size)
		self.draw { ctx in
			ctx.clip(to: [bounds])
			ctx.draw(image, in: dest)
		}
		return self
	}

	/// Draw an image at a point within this bitmap, cropping to the bounds of the original image
	/// - Parameters:
	///   - image: The image to draw
	///   - point: The point at which to draw the image
	/// - Returns: A new bitmap
	@inlinable func drawingBitmap(_ image: ImageRepresentationType, atPoint point: CGPoint = .zero) throws -> Bitmap {
		try self.copy()
			.drawBitmap(image, atPoint: point)
	}
}

// MARK: - Global implementations

internal func drawImageInContext(_ ctx: CGContext, image: CGImage, rect: CGRect, scalingType: Bitmap.ScalingType = .axesIndependent) {
	switch scalingType {
	case .axesIndependent:
		ctx.draw(image, in: rect)
	case .aspectFill:
		drawImageToFill(in: ctx, image: image, rect: rect)
	case .aspectFit:
		drawImageToFit(in: ctx, image: image, rect: rect)
	}
}

internal func drawImageToFit(in ctx: CGContext, image: CGImage, rect: CGRect) {
	let origSize = image.size

	// Keep aspect ratio
	var destWidth: CGFloat = 0
	var destHeight: CGFloat = 0
	let widthFloat = origSize.width
	let heightFloat = origSize.height
	if origSize.width > origSize.height {
		destWidth = rect.width
		destHeight = heightFloat * rect.width / widthFloat
	}
	else {
		destHeight = rect.height
		destWidth = widthFloat * rect.height / heightFloat
	}

	if destWidth > rect.width {
		destWidth = rect.width
		destHeight = heightFloat * rect.width / widthFloat
	}

	if destHeight > rect.height {
		destHeight = rect.height
		destWidth = widthFloat * rect.height / heightFloat
	}

	ctx.draw(
		image,
		in: CGRect(
			x: rect.minX + ((rect.width - destWidth) / 2),
			y: rect.minY + ((rect.height - destHeight) / 2),
			width: destWidth,
			height: destHeight
		)
	)
}

internal func drawImageToFill(in ctx: CGContext, image: CGImage, rect: CGRect) {
	let imageSize = image.size

	ctx.saveGState()
	defer { ctx.restoreGState() }

	// Set up a clipping rect
	ctx.clip(to: [rect])

	var destWidth: CGFloat = 0
	var destHeight: CGFloat = 0
	let widthRatio = rect.width / imageSize.width
	let heightRatio = rect.height / imageSize.height

	// Keep aspect ratio
	if heightRatio > widthRatio {
		
		// The width needs to fit exactly the width of the rect
		destHeight = rect.height

		// Scale the height
		destWidth = imageSize.width * heightRatio // (rect.height / imageSize.height)
	}
	else {
		// The height needs to fit exactly the width of the rect
		destHeight = rect.height

		// Scale the width
		destWidth = imageSize.width * (rect.width / imageSize.width)
	}

	ctx.clip(to: [rect])
	ctx.draw(
		image,
		in: CGRect(
			x: rect.minX + ((rect.width - destWidth) / 2),
			y: rect.minY + ((rect.height - destHeight) / 2),
			width: destWidth,
			height: destHeight
		)
	)
}
