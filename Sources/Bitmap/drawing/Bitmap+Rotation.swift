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

public extension Bitmap {
	/// Rotate this image clockwise around its center
	/// - Parameters:
	///   - radians: The rotation angle in radians
	@inlinable mutating func rotated(by radians: CGFloat) throws {
		self = try self.rotating(by: radians)
	}

	/// Create a new image by rotating an image clockwise round its center
	/// - Parameters:
	///   - radians: The rotation angle in radians
	/// - Returns: The rotated image, or nil if an error occurred
	func rotating(by radians: CGFloat) throws -> Bitmap {
		guard let cgImage = self.cgImage else {
			throw BitmapError.cannotCreateCGImage
		}

		let origWidth = CGFloat(width)
		let origHeight = CGFloat(height)
		let origRect = CGRect(origin: .zero, size: CGSize(width: origWidth, height: origHeight))
		let rotatedRect = origRect.applying(CGAffineTransform(rotationAngle: radians))

		var n = try Bitmap(width: Int(rotatedRect.width), height: Int(rotatedRect.height))
		n.draw { ctx in
			ctx.translateBy(x: rotatedRect.size.width * 0.5, y: rotatedRect.size.height * 0.5)
			ctx.rotate(by: -radians)
			ctx.draw(
				cgImage,
				in: CGRect(
					x: -origWidth * 0.5,
					y: -origHeight * 0.5,
					width: origWidth,
					height: origHeight
				)
			)
		}
		return n
	}
}
