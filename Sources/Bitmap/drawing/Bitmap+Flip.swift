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

// MARK: - Flip

public extension Bitmap {
	/// Flip types
	enum FlipType {
		/// Flip horizontally
		case horizontally
		/// Flip vertically
		case vertically
		/// Flip across both axes
		case both
	}

	/// Flip this bitmap
	/// - Parameter flipType: The type of flipping to apply
	func flip(_ flipType: FlipType) throws {
		guard let cgImage = self.cgImage else { throw BitmapError.cannotCreateCGImage }
		self.eraseAll()

		self.savingGState { ctx in
			// Draw the flipped image
			switch flipType {
			case .horizontally:
				ctx.scaleBy(x: 1, y: -1)
				ctx.translateBy(x: 0, y: Double(-height))
			case .vertically:
				ctx.scaleBy(x: -1, y: 1)
				ctx.translateBy(x: Double(-width), y: 0)
			case .both:
				ctx.scaleBy(x: -1, y: -1)
				ctx.translateBy(x: Double(-width), y: Double(-height))
			}
			ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		}
	}

	/// Create a new bitmap by flipping this bitmap
	/// - Parameter flipType: The type of flipping to apply
	/// - Returns: A new image with the original image flipped
	func flipping(_ flipType: FlipType) throws -> Bitmap {
		try self.makingCopy { copy in
			try copy.flip(flipType)
		}
	}
}
