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

// MARK: [Scaling]

public extension Bitmap {

	/// The type of scaling to apply to an image
	enum ScalingType {
		/// Scale the X and Y axes independently when resizing the image
		case axesIndependent
		/// Scale the X and Y axes equally so that the entire image fills the specified size
		case aspectFill
		/// Sclae the X and Y axes equally so that the entire image fits within the specified size
		case aspectFit
	}

	/// Create a bitmap by scaling to fit a target size
	/// - Parameters:
	///   - image: The image to scale
	///   - scalingType: The type of scaling to perform
	///   - targetSize: The target size for the image
	/// - Returns: The scaled image, or nil if an error occurred
	@inlinable func scalingImage(
		scalingType: ScalingType = .axesIndependent,
		to targetSize: CGSize
	) throws -> Bitmap {
		switch scalingType {
		case .axesIndependent:
			return try self.scaling(axesIndependent: targetSize)
		case .aspectFill:
			return try self.scaling(aspectFill: targetSize)
		case .aspectFit:
			return try self.scaling(aspectFit: targetSize)
		}
	}

	/// Create a bitmap by scaling to fit a target size
	/// - Parameters:
	///   - image: The image to scale
	///   - targetSize: The target size for the image
	/// - Returns: The scaled image, or nil if an error occurred
	func scaling(axesIndependent targetSize: CGSize) throws -> Bitmap {
		guard let image = self.cgImage else { throw BitmapError.cannotCreateCGImage }
		return try Bitmap(size: targetSize) { ctx in
			ctx.draw(image, in: CGRect(origin: .zero, size: targetSize))
		}
	}

	/// Create an image by scaling the provided image to fit the target size
	/// - Parameters:
	///   - image: The image to scale
	///   - targetSize: The target size for the image
	/// - Returns: The scaled image, or nil if an error occurred
	@inlinable func scaling(aspectFit targetSize: CGSize) throws -> Bitmap {
		guard let image = self.cgImage else { throw BitmapError.cannotCreateCGImage }
		return try Bitmap(size: targetSize) { ctx in
			drawImageToFit(in: ctx, image: image, rect: CGRect(origin: .zero, size: targetSize))
		}
	}

	/// Create an image by scaling the provided image to fill the target size
	/// - Parameters:
	///   - image: The image to scale
	///   - targetSize: The target size for the image
	/// - Returns: The scaled image, or nil if an error occurred
	@inlinable func scaling(aspectFill targetSize: CGSize) throws -> Bitmap {
		guard let image = self.cgImage else { throw BitmapError.cannotCreateCGImage }
		return try Bitmap(size: targetSize) { ctx in
			drawImageToFill(in: ctx, image: image, rect: CGRect(origin: .zero, size: targetSize))
		}
	}
}
