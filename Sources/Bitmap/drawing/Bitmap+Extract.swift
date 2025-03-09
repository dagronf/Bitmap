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
	/// Extract the content of the path into a new Bitmap
	/// - Parameters:
	///   - path: The clip path
	///   - clipToPath: If true, resize the resulting image to fit the clip path bounds
	/// - Returns: A new bitmap containing the contents of the clip path
	func extracting(_ path: CGPath, clipToPath: Bool = false) throws -> Bitmap {
		guard let cgImage = self.cgImage else { throw BitmapError.cannotCreateCGImage }
		let result = try Bitmap(size: self.size)
		result.clip(to: path) { ctx in
			ctx.draw(cgImage, in: self.bounds)
		}

		if clipToPath {
			try result.crop(to: path.boundingBoxOfPath)
		}

		return result
	}

	/// Extract the content of a rect into a new Bitmap
	/// - Parameters:
	///   - rect: The clip rect
	///   - clipToPath: If true, resize the resulting image to fit the clip path bounds
	/// - Returns: A new bitmap containing the contents of the clip path
	@inlinable func extracting(_ rect: CGRect, clipToPath: Bool = false) throws -> Bitmap {
		try self.extracting(CGPath(rect: rect, transform: nil), clipToPath: clipToPath)
	}

	/// Extract the content of the path into a new Bitmap
	/// - Parameters:
	///   - path: The clip path
	///   - clipToPath: If true, resize the resulting image to fit the clip path bounds
	@inlinable func extract(_ path: CGPath, clipToPath: Bool = false) throws {
		try self.replaceContents(with: self.extracting(path, clipToPath: clipToPath))
	}

	/// Extract the content of a rect into a new Bitmap
	/// - Parameters:
	///   - rect: The clip rect
	///   - clipToPath: If true, resize the resulting image to fit the clip path bounds
	@inlinable func extract(_ rect: CGRect, clipToPath: Bool = false) throws {
		try self.replaceContents(with: self.extracting(rect, clipToPath: clipToPath))
	}
}
