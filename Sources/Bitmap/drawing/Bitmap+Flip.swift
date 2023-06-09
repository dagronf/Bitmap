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
	@inlinable mutating func flipping(_ flipType: FlipType) throws {
		self = try flipped(flipType)
	}

	/// Create a new bitmap by flipping this bitmap
	func flipped(_ flipType: FlipType) throws -> Bitmap {
		guard let cgImage = self.cgImage else { throw BitmapError.cannotCreateCGImage }
		var newImage = try Bitmap(width: width, height: height)
		newImage.savingGState { context in
			switch flipType {
			case .horizontally:
				context.scaleBy(x: 1, y: -1)
				context.translateBy(x: 0, y: Double(-height))
			case .vertically:
				context.scaleBy(x: -1, y: 1)
				context.translateBy(x: Double(-width), y: 0)
			case .both:
				context.scaleBy(x: -1, y: -1)
				context.translateBy(x: Double(-width), y: Double(-height))
			}
			context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		}
		return newImage
	}
}
