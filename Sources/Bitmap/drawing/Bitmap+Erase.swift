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

public extension Bitmap {
	/// Erase the bitmap (set the image content to all transparent)
	func eraseAll() {
		self.bitmapData.eraseAll()
	}

	/// Erase the content of the path
	/// - Parameters:
	///   - path: The path to erase
	///   - backgroundColor: The background color for the erased path
	func erase(_ path: CGPath, backgroundColor: CGColor? = nil) throws {
		try self.replaceContents(with: try self.erasing(path))
	}

	/// Create a new bitmap by erasing the content of the path
	/// - Parameters:
	///   - path: The path to erase
	///   - backgroundColor: The background color for the erased path
	/// - Returns: The new bitmap
	func erasing(_ path: CGPath, backgroundColor: CGColor? = nil) throws -> Bitmap {
		guard let cgImage = self.cgImage else { throw BitmapError.cannotCreateCGImage }
		let copy = try Bitmap(size: self.size)
		let bounds = copy.bounds
		copy.draw { ctx in
			ctx.addRect(bounds)
			ctx.addPath(path)
			ctx.clip(using: .evenOdd)
			ctx.draw(cgImage, in: bounds)
		}

		if let backgroundColor = backgroundColor {
			copy.fill(path, backgroundColor)
		}
		return copy
	}
}

public extension Bitmap {
	/// Erase the content of the rect
	/// - Parameters:
	///   - rect: The rect to erase
	///   - backgroundColor: The background color for the erased path
	func erase(_ rect: CGRect, backgroundColor: CGColor? = nil) throws {
		try self.erase(rect.path, backgroundColor: backgroundColor)
	}

	/// Create a new bitmap by erasing the content of the rect
	/// - Parameters:
	///   - rect: The rect to erase
	///   - backgroundColor: The background color for the erased path
	/// - Returns: The new bitmap
	func erasing(_ rect: CGRect, backgroundColor: CGColor? = nil) throws -> Bitmap {
		try self.erasing(rect.path, backgroundColor: backgroundColor)
	}
}
